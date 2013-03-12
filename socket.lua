--  thread.lua
dofile "util.lua"
local ffi = require("ffi")
local C = ffi.C

if isWin then
	--require "win_socket"
	local s = ffi.load("ws2_32")

	function socket_initialize()
		local wsadata_typename
		if is64bit then
			wsadata_typename = "WSADATA64"
		else
			wsadata_typename = "WSADATA"
		end
		local wVersionRequested = MAKEWORD(2, 2)
		local dataarrayname = string.format("%s[1]", wsadata_typename)
		local wsadata = ffi.new(dataarrayname)
    local err = s.WSAStartup(wVersionRequested, wsadata)
		wsadata = wsadata[0]
		return err,wsadata
	end
	function socket_shutdown(socket, how)
		return s.shutdown(socket, how)
	end
	function socket_close(socket)
		return s.closesocket(socket)
	end
	function socket_cleanup(socket, errnum, errtext)
		local last_wsa_err_num = s.WSAGetLastError()
		local last_wsa_err_txt = last_wsa_err_num
		--http://msdn.microsoft.com/en-us/library/windows/desktop/ms679351(v=vs.85).aspx
		--[[local last_wsa_err_txt = FormatMessage()
			FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER |
            FORMAT_MESSAGE_FROM_SYSTEM,
            NULL,
            err,
            0,
            (LPTSTR)&s,
            0,
            NULL)
      ]]
		if socket then
			socket_close(socket)
		end
		s.WSACleanup()
		if errtext and #errtext > 0 then
			error(errtext.."("..errnum..") "..last_wsa_err_txt)
		end
	end
	function socket_htons(num)
		return s.htons(num)
	end
	function socket_socket(domain, type_, protocol)
		return s.socket(domain, type_, protocol)
	end
	function socket_bind(socket, sockaddr ,addrlen)
		return s.bind(socket, sockaddr ,addrlen)
	end
	function socket_listen(socket, backlog)
		return s.listen(socket, backlog)
	end
	function socket_accept(socket, sockaddr ,addrlen)
		return s.accept(socket, sockaddr ,addrlen)
	end
	function socket_recv(socket, buffer, length, flags)
		return s.recv(socket, buffer, length, flags)
	end
	function socket_send(socket, buffer, length, flags)
		return s.send(socket, buffer, length, flags)
	end
	function socket_setsockopt(socket, level, option_name, option_value, option_len)
		return s.setsockopt(socket, level, option_name, option_value, option_len)
	end
	function socket_getsockopt(socket, level, option_name, option_value, option_len)
		return s.getsockopt(socket, level, option_name, option_value, option_len)
	end

else
	-- unix

	function socket_initialize()
		return 0,nil -- for win compatibilty
	end
	function socket_shutdown(socket, how)
		return C.shutdown(socket, how)
	end
	function socket_close(socket)
		return C.close(socket)
	end
	function socket_cleanup(socket, errnum, errtext)
		local last_err_text = "" --s.WSAGetLastError()
		if socket then
			socket_close(socket)
		end
		--s.WSACleanup()
		if errtext and #errtext > 0 then
			error(errtext.."("..tonumber(errnum)..") "..last_err_text)
		end
	end
	function socket_htons(num)
		return C.htons(num)
	end
	function socket_socket(domain, type_, protocol)
		return C.socket(domain, type_, protocol)
	end
	function socket_bind(domain, type_, protocol)
		return C.bind(domain, type_, protocol)
	end
	function socket_listen(socket, backlog)
		return C.listen(socket, backlog)
	end
	function socket_accept(socket, sockaddr ,addrlen)
		return C.accept(socket, sockaddr ,addrlen)
	end
	function socket_recv(socket, buffer, length, flags)
		return C.recv(socket, buffer, length, flags)
	end
	function socket_send(socket, buffer, length, flags)
		return C.send(socket, buffer, length, flags)
	end
	function socket_setsockopt(socket, level, option_name, option_value, option_len)
		return C.setsockopt(socket, level, option_name, option_value, option_len)
	end
	function socket_getsockopt(socket, level, option_name, option_value, option_len)
		return C.getsockopt(socket, level, option_name, option_value, option_len)
	end

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
