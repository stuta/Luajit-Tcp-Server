--  lib_socket.lua
module(..., package.seeall)

local ffi = require("ffi")
local C = ffi.C
local util = require("lib_util")
local bit = require("bit")

local lshift = bit.lshift
local rshift = bit.rshift
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local bswap = bit.bswap

local s
if util.isWin then
	--require "win_socket"
	ffi.cdef[[
		int WSAPoll(LPWSAPOLLFD fdArray, ULONG fds, INT timeout);
	]]
	s = ffi.load("ws2_32")
else
	-- unix
	s = C
end
local err_prefix = "  SOCKET ERROR: "
function error_prefix_text_set(errTxt)
	err_prefix = errTxt
end

if util.isWin then
	INVALID_SOCKET = ffi.new("SOCKET", -1)
else
	INVALID_SOCKET = -1
end
SOCKET_ERROR	= -1	-- 0xffffffff

local function MAKEWORD(low,high)
	return bor(low , lshift(high , 8))
end

local function LOWBYTE(word)
	return band(word, 0xff)
end

local function HIGHBYTE(word)
	return band(rshift(word,8), 0xff)
end

if util.isWin then
	function errortext(err)
		return util.win_errortext(err)
	end
	function initialize()
		local wsadata
		--if is64bit then
		--	wsadata = ffi.new("WSADATA64[1]")
		--else
		wsadata = ffi.new("WSADATA[1]")
		--end
		local wVersionRequested = ffi.cast("WORD", MAKEWORD(2, 2))
    local err = s.WSAStartup(wVersionRequested, wsadata)
    if err ~= 0 then
			print(err_prefix.."WSAStartup failed with error code: "..err)
    elseif s.WSAGetLastError() ~= 0 then
			print(err_prefix.."WSAStartup failed with error code: "..s.WSAGetLastError())
    end
    --print(err_prefix.."WSAStartup: ".. err)
		return err -- err,wsadata[0]
	end
	function poll(fdArray, fds, timeout)
		return s.WSAPoll(fdArray, fds, timeout)
	end
	function close(socket)
		local socket_c = ffi.cast("int", socket)
		return s.closesocket(socket_c)
	end
	function cleanup(socket, errnum, errtext)
		-- get WSAGetLastError() before close and WSACleanup
		local wsa_err_num = s.WSAGetLastError()
		local	wsa_err_text = errortext(wsa_err_num)
		if errnum and errnum ~= -1 and errnum ~= wsa_err_num then
			wsa_err_text = errortext(wsa_err_num)..", WSAGetLastError: "..tonumber(wsa_err_num)..". "..wsa_err_text
		end
		if socket then
			close(socket)
		end
		s.WSACleanup()
		if errtext and #errtext > 0 then
			error(err_prefix..errtext.."("..tonumber(errnum)..") "..wsa_err_text)
		end
	end
	function inet_ntop(family, pAddr, strptr)
		-- win XP: http://memset.wordpress.com/2010/10/09/inet_ntop-for-win32/
		local srcaddr = ffi.new("struct sockaddr_in") --ffi.cast("struct sockaddr_in *", pAddr)
		ffi.copy(srcaddr.sin_addr, pAddr, ffi.sizeof(srcaddr.sin_addr))
		srcaddr.sin_family = family
		local len = ffi.new("unsigned long[1]", ffi.sizeof(strptr))
    local ret = s.WSAAddressToStringA(ffi.cast("struct sockaddr *", srcaddr), ffi.sizeof("struct sockaddr"), nil, strptr, len)
    if ret ~= 0 then
   		print(err_prefix.."WSAAddressToString failed with error: "..tonumber(ret))
      return nil
    end
    return strptr
  end
	function set_nonblock(socket, arg)
		local arg_c = ffi.new("int[1]")
		arg_c[0] = arg
		return s.ioctlsocket(socket, FIONBIO, arg_c) -- FIONBIO in win_socket.lua
	end

  
else
	-- unix
	function errortext(err)
		return ffi.string(C.gai_strerror(err))
	end
	function initialize()
		return 0 -- for win compatibilty
	end
	function poll(fds, nfds, timeout)
		return s.poll(fds, nfds, timeout)
	end
	function close(socket)
		return s.close(socket)
	end
	function cleanup(socket, errnum, errtext)
		if socket then
			close(socket)
		end
		--s.WSACleanup()
		if errtext and #errtext > 0 then
			error(err_prefix..errtext.."("..tonumber(errnum)..") "..errortext(errnum))
		end
	end
	function inet_ntop(family, pAddr, strptr)
		return s.inet_ntop(family, pAddr, strptr, ffi.sizeof(strptr))
	end
	function set_nonblock(socket, arg)
		local flags = s.fcntl(socket, s.F_GETFL, 0);
		if flags < 0 then return flags end
		if arg ~= 0 then
			flags = bit.bor(flags, s.O_NONBLOCK)
		else
			flags = bit.band(flags, bit.bnot(s.O_NONBLOCK))
		end
		return s.fcntl(socket, s.F_SETFL, ffi.new("int", flags))
	end
end

function shutdown(socket, how)
	return s.shutdown(socket, how)
end
function htons(num)
	return s.htons(num)
end
function socket(domain, type_, protocol)
	return s.socket(domain, type_, protocol)
end
function bind(socket, sockaddr ,addrlen)
	return s.bind(socket, sockaddr ,addrlen)
end
function listen(socket, backlog)
	return s.listen(socket, backlog)
end
function connect(socket, sockaddr ,address_len)
	return s.connect(socket, sockaddr ,address_len)
end
function accept(socket, sockaddr ,addrlen)
	return s.accept(socket, sockaddr ,addrlen)
end
function recv(socket, buffer, length, flags)
	return tonumber(s.recv(socket, buffer, length, flags))
end
function send(socket, buffer, length, flags)
	return tonumber(s.send(socket, buffer, length, flags))
end
function getsockopt(socket, level, option_name, option_value, option_len)
	return s.getsockopt(socket, level, option_name, option_value, option_len)
end
function setsockopt(socket, level, option_name, option_value)
	--local arg_c = ffi.new("uint32_t[1]", option_value)
	local arg_c = ffi.new("int[1]", option_value)
	local option_len = ffi.sizeof(arg_c)
	--return s.setsockopt(socket, level, option_name, ffi.cast("void *", arg_c), option_len)
	return s.setsockopt(socket, level, option_name, arg_c, option_len)
end
function getnameinfo(sa, salen, host, hostlen, serv, servlen, flags)
	return s.getnameinfo(sa, salen, host, hostlen, serv, servlen, flags)
end

function getaddrinfo(hostname, servname, hints, res)
  return s.getaddrinfo(hostname, servname, hints, res)
end
function getpeername(socket, name, namelen)
	return s.getpeername(socket, name, namelen)
end
function ntohs(netshort)
	return s.ntohs(netshort)
end

--[[
int l_socket_set_nonblock(LSocketFD sock, bool val) {
#ifdef __WINDOWS__
	unsigned long flag = val;
	return ioctlsocket(sock, FIONBIO, &flag);
#else
	int flags;
	flags = fcntl(sock, F_GETFL);
	if(flags < 0) return flags;
	if(val) {
		flags |= O_NONBLOCK;
	} else {
		flags &= ~(O_NONBLOCK);
	}
	return fcntl(sock, F_SETFL, flags);
#endif
}

int l_socket_set_close_on_exec(LSocketFD sock, bool val) {
#ifdef __WINDOWS__
	return 0;
#else
	int flags;
	flags = fcntl(sock, F_GETFD);
	if(flags < 0) return flags;
	if(val) {
		flags |= FD_CLOEXEC;
	} else {
		flags &= ~(FD_CLOEXEC);
	}
	return fcntl(sock, F_SETFD, flags);
#endif
}

int l_socket_get_option(LSocketFD sock, int level, int opt, void *val, socklen_t *len) {
	return getsockopt(sock, level, opt, val, len);
}

int l_socket_set_option(LSocketFD sock, int level, int opt, const void *val, socklen_t len) {
	return setsockopt(sock, level, opt, val, len);
}

int l_socket_get_int_option(LSocketFD sock, int level, int opt, int *val) {
	socklen_t len = sizeof(*val);
	return l_socket_get_option(sock, level, opt, val, &len);
}

int l_socket_set_int_option(LSocketFD sock, int level, int opt, int val) {
	return l_socket_set_option(sock, level, opt, &val, sizeof(val));
}

int l_socket_pair(int type, int flags, LSocketFD sv[2]) {
	type |= flags;
#ifdef __WINDOWS__
	/* TODO: use TCP sockets. */
	errno = EAFNOSUPPORT;
	return -1;
#else
	return socketpair(AF_UNIX, type, 0, sv);
#endif
}

LSocketFD l_socket_open(int domain, int type, int protocol, int flags) {
	type |= flags;
	return socket(domain, type, protocol);
}

LSocketFD l_socket_close_internal(LSocketFD sock) {
#ifdef __WINDOWS__
	return closesocket(sock);
#else
	return close(sock);
#endif
}

int l_socket_shutdown(LSocketFD sock, int how) {
	return shutdown(sock, how);
}

int l_socket_connect(LSocketFD sock, LSockAddr *addr) {
	return connect(sock, L_SOCKADDR_TO_CONST_ADDR_AND_LEN(addr));
}

int l_socket_bind(LSocketFD sock, LSockAddr *addr) {
	return bind(sock, L_SOCKADDR_TO_CONST_ADDR_AND_LEN(addr));
}

int l_socket_listen(LSocketFD sock, int backlog) {
	return listen(sock, backlog);
}

int l_socket_get_sockname(LSocketFD sock, LSockAddr *addr) {
	MAKE_TEMP_ADDR(tmp1);
	int rc;

	rc = getsockname(sock, GET_TEMP_ADDR_AND_PTR_LEN(tmp1));
	if(rc == 0) {
		L_SOCKADDR_FILL_FROM_TEMP(addr, tmp1);
	}
	return rc;
}

int l_socket_get_peername(LSocketFD sock, LSockAddr *addr) {
	MAKE_TEMP_ADDR(tmp1);
	int rc;

	rc = getpeername(sock, GET_TEMP_ADDR_AND_PTR_LEN(tmp1));
	if(rc == 0) {
		L_SOCKADDR_FILL_FROM_TEMP(addr, tmp1);
	}
	return rc;
}

LSocketFD l_socket_accept(LSocketFD sock, LSockAddr *peer, int flags) {
	MAKE_TEMP_ADDR(tmp1);
#ifdef __WINDOWS__
	LSocketFD rc;
	if(peer != NULL) {
		rc = accept(sock, GET_TEMP_ADDR_AND_PTR_LEN(tmp1));
		if(rc == 0) {
			L_SOCKADDR_FILL_FROM_TEMP(peer, tmp1);
		}
	} else {
		rc = accept(sock, NULL, NULL);
	}
	if(rc == INVALID_SOCKET) {
		return rc;
	}
	if((flags & SOCK_NONBLOCK) == SOCK_NONBLOCK) {
		l_socket_set_nonblock(rc, 1);
	}
	return rc;
#else
	if(peer != NULL) {
		LSocketFD rc;
		rc = accept4(sock, GET_TEMP_ADDR_AND_PTR_LEN(tmp1), flags);
		if(rc == 0) {
			L_SOCKADDR_FILL_FROM_TEMP(peer, tmp1);
		}
		return rc;
	}
	return accept4(sock, NULL, NULL, flags);
#endif
}

int l_socket_send(LSocketFD sock, const void *buf, size_t len, int flags) {
	return send(sock, buf, len, flags);
}

int l_socket_recv(LSocketFD sock, void *buf, size_t len, int flags) {
	return recv(sock, buf, len, flags);
}
--]]
