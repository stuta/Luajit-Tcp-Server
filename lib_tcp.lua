--  lib_tcp.lua
module(..., package.seeall)

local ffi = require("ffi")
local C = ffi.C
local socket = require "lib_socket"

-- INVALID_SOCKET here, in lib_socket.lua or in C?
local INVALID_SOCKET, SOCKET_ERROR
if isWin then
	INVALID_SOCKET = ffi.new("SOCKET", -1)
else
	INVALID_SOCKET = -1
end
SOCKET_ERROR 				= -1	-- 0xffffffff

local sendBufSize, receiveBufSize = 65536, 65536
local tcpNoDelay = 1

local err = socket.initialize()
if err ~= 0 then
	socket.cleanup(nil, err, "ERROR in socket.initialize(): ")
end

--[[
-- FIX: with this code: http://beej.us/guide/bgnet/output/html/multipage/syscalls.html#bind
local addr = ffi.new("struct sockaddr_in")
addr.sin_family = C.AF_INET
addr.sin_addr.s_addr = C.INADDR_ANY -- does not work in win without changing in_addr.S_addr to in_addr.s_addr
addr.sin_port = socket.htons(port)
-- C.inet_aton("127.0.0.1", addr.sin_addr) -- test this
]]

function listen(port)
	-- http://beej.us/guide/bgnet/output/html/multipage/syscalls.html#bind
	local res = ffi.new("struct addrinfo*[1]")
	local hints = ffi.new("struct addrinfo")

	hints.ai_family = C.AF_INET -- DOES NOT work in windows: AF_UNSPEC,  AF_UNSPEC == use IPv4 or IPv6, whichever
	hints.ai_socktype = C.SOCK_STREAM
	hints.ai_protocol = C.IPPROTO_TCP
	hints.ai_flags = bit.bor(C.AI_PASSIVE) -- fill in my IP for me
	local host = nil -- binding, can be nil
	local serv = tostring(port)
	local err = socket.getaddrinfo(host, serv, hints, res)
	if err ~= 0 then
		print("  -- sock.getaddrinfo error: '"..socket.errortext(err).."'")
		os.exit()
	end
	-- Create a SOCKET for connecting to server
	local listen_socket = socket.socket(res[0].ai_family, res[0].ai_socktype, res[0].ai_protocol)
	--[[if res[0].ai_family ~= C.AF_INET or res[0].ai_socktype ~= C.SOCK_STREAM or res[0].ai_protocol~= C.IPPROTO_TCP then
		-- socket.socket(C.AF_INET, C.SOCK_STREAM, C.IPPROTO_TCP)
		socket.cleanup(nil, listen_socket, "socket.socket types are incorrect: ")
		return -1
	end]]
	if listen_socket == INVALID_SOCKET then
			socket.cleanup(nil, listen_socket, "socket.socket failed with error: ")
			return -1
	end

	-- Setup the TCP listening socket
	local result
	-- SO_REUSEADDR, set reuse address for listen socket before bind
	result = socket.setsockopt(listen_socket, C.SOL_SOCKET, C.SO_REUSEADDR, 1)
	if result ~= 0 then
		socket.cleanup(listen_socket, result, "socket.setsockopt SO_REUSEADDR failed with error: ")
	end

	-- set to non-blocking mode
	local result
	result = socket.set_nonblock(listen_socket, 1)
	if result ~= 0 then
		socket.cleanup(listen_socket, result, "socket.set_nonblock (set to non-blocking mode) failed with error: ")
	end

	-- SO_USELOOPBACK, use always loopback when possible
	if not isWin then -- SO_USELOOPBACK is not supported by windows
		result = socket.setsockopt(listen_socket, C.SOL_SOCKET, C.SO_USELOOPBACK, 1)
		if result ~= 0 then
			socket.cleanup(listen_socket, result, "socket.setsockopt SO_USELOOPBACK failed with error: ")
		end
	end

	-- SO_SNDBUF, send buffer size
	result = socket.setsockopt(listen_socket, C.SOL_SOCKET, C.SO_SNDBUF, sendBufSize)
	if result ~= 0 then
		socket.cleanup(listen_socket, result, "socket.setsockopt SO_SNDBUF failed with error: ")
	end

	-- SO_RCVBUF, reveive buffer size
	result = socket.setsockopt(listen_socket, C.SOL_SOCKET, C.SO_RCVBUF, receiveBufSize)
	if result ~= 0 then
		socket.cleanup(listen_socket, result, "socket.setsockopt SO_RCVBUF failed with error: ")
	end

	-- TCP_NODELAY, tcp-nodelay to 1
	result = socket.setsockopt(listen_socket, C.SOL_SOCKET, C.TCP_NODELAY, tcpNoDelay)
	if result ~= 0 then
		socket.cleanup(listen_socket, result, "socket.setsockopt TCP_NODELAY failed with error: ")
	end

	-- bind
	result = socket.bind(listen_socket, res[0].ai_addr, res[0].ai_addrlen)
	if result ~= 0 then
		socket.cleanup(listen_socket, result, "socket.bind failed with error: ")
	end
	-- listen
	result = socket.listen(listen_socket, C.SOMAXCONN)
	if result ~= 0 then
		socket.cleanup(listen_socket, result, "socket.listen failed with error: ")
	end
	return listen_socket
end

function accept(listen_socket)
	-- Accept a client socket
	client_addr = ffi.new("struct sockaddr_in[1]") -- "struct sockaddr_in[1]"
	client_addr_ptr = ffi.cast("struct sockaddr *", client_addr)
	local client_addr_size = ffi.new("int[1]")
	client_addr_size[0] = ffi.sizeof("struct sockaddr")
	local client_socket = socket.accept(listen_socket, client_addr_ptr, client_addr_size)
	if client_socket < 0 then
		return client_socket -- poll error, ok
		--socket.cleanup(listen_socket, client_socket, "socket.accept failed with error: ")
	end

	--[[
	-- SO_SNDBUF, send buffer size
	result = socket.setsockopt(client_socket, C.SOL_SOCKET, C.SO_SNDBUF, sendBufSize)
	if result ~= 0 then
		socket.cleanup(client_socket, result, "socket.setsockopt SO_SNDBUF failed with error: ")
	end

	-- SO_RCVBUF, reveive buffer size
	result = socket.setsockopt(client_socket, C.SOL_SOCKET, C.SO_RCVBUF, receiveBufSize)
	if result ~= 0 then
		socket.cleanup(client_socket, result, "socket.setsockopt SO_RCVBUF failed with error: ")
	end

	-- TCP_NODELAY, tcp-nodelay to 1
	result = socket.setsockopt(client_socket, C.SOL_SOCKET, C.TCP_NODELAY, tcpNoDelay)
	if result ~= 0 then
		socket.cleanup(client_socket, result, "socket.setsockopt TCP_NODELAY failed with error: ")
	end
	]]

	return client_socket --,client_addr_ptr
end

function address(sock)
	local addr = ffi.new("struct sockaddr_storage")
	local len = ffi.new("unsigned int[1]")
	len[0] = ffi.sizeof(addr) --ffi.sizeof("struct sockaddr")
	socket.getpeername(sock, ffi.cast("struct sockaddr *", addr), len)
	-- deal with both IPv4 and IPv6:
	local ipstr, port
	if addr.ss_family == C.AF_INET then
			ipstr = ffi.new("char[?]", C.INET_ADDRSTRLEN)
			local s = ffi.cast("struct sockaddr_in *", addr)
			port = socket.ntohs(s.sin_port)
			socket.inet_ntop(C.AF_INET, s.sin_addr, ipstr)
	else  -- C.AF_INET6
			ipstr = ffi.new("char[?]", C.INET6_ADDRSTRLEN)
			local s = ffi.cast("struct sockaddr_in6 *", addr)
			port = socket.ntohs(s.sin6_port)
			socket.inet_ntop(C.AF_INET6, s.sin6_addr, ipstr)
	end
	return ffi.string(ipstr)..":"..port --ffi.string(port)
	--[[
	-- http://stackoverflow.com/questions/4282292/convert-struct-in-addr-to-text
	-- http://www.freelists.org/post/luajit/FFI-pointers-to-pointers,1
	-- https://gist.github.com/neomantra/2644943

	local hostname = createBuffer(C.NI_MAXHOST)
	local servInfo = createBuffer(C.NI_MAXSERV)
	local result = socket.getnameinfo(client_addr_ptr, ffi.sizeof("struct sockaddr_in"), hostname, C.NI_MAXHOST, servInfo, C.NI_MAXSERV, 0)
	if result ~= 0 then
		socket.cleanup(socket, result, "socket.getnameinfo failed with error: ")
	end
	--print("client ip:port : "..ffi.string(hostname)..":"..ffi.string(servInfo)) -- servInfo is post number
	return ffi.string(hostname)..":"..ffi.string(servInfo)
	]]
end


local conn_wait_polltype = 0
local conn_wait_fd = {}
local conn_wait_event = {}
local conn_wait_revent = {}

function close(sock)
	socket.close(sock) -- not needed anymore
end

function conn_wait_options_set(opts)
	conn_wait = 0 -- 0=select, 1=poll, 2=kqueue/iocp/epoll
end

function conn_wait_options_set(opts)
	wait_polltype = 0 -- 0=select, 1=poll, 2=kqueue/iocp/epoll
end

function conn_wait()
	--socket.poll(wait_opt.) -- not needed anymore
end
