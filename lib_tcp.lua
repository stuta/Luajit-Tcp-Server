--  lib_tcp.lua
<<<<<<< HEAD
print()
print(" -- lib_tcp.lua start -- ")
print()
=======
>>>>>>> Win XP socket working, tcp library. Linux  AppSharedMemory.lua works with 'sudo'.

dofile "lib_socket.lua"
local arg = {...}
local ffi = require("ffi")
local C = ffi.C

<<<<<<< HEAD
local buflen = 200
local recvbuflen = buflen
local recvbuf,recvbuf_ptr = createBuffer(buflen)
local port = 5001
print("..Lua tcp server waiting on: 127.0.0.1:"..port)
print()

local INVALID_SOCKET, SOCKET_ERROR
if isWin then
	INVALID_SOCKET = ffi.new("SOCKET", -1)
else
	INVALID_SOCKET = -1
end
SOCKET_ERROR 				= -1	-- 0xffffffff
=======

local sendBufSize, receiveBufSize = 65536, 65536
local tcpNoDelay = 1
>>>>>>> Win XP socket working, tcp library. Linux  AppSharedMemory.lua works with 'sudo'.

local err = socket_initialize()
if err ~= 0 then
	socket_cleanup(nil, err, "ERROR in socket_initialize(): ")
end

--[[
-- FIX: with this code: http://beej.us/guide/bgnet/output/html/multipage/syscalls.html#bind
local addr = ffi.new("struct sockaddr_in")
addr.sin_family = C.AF_INET
addr.sin_addr.s_addr = C.INADDR_ANY -- does not work in win without changing in_addr.S_addr to in_addr.s_addr
addr.sin_port = socket_htons(port)
-- C.inet_aton("127.0.0.1", addr.sin_addr) -- test this
]]

<<<<<<< HEAD
-- http://beej.us/guide/bgnet/output/html/multipage/syscalls.html#bind
local res = ffi.new("struct addrinfo*[1]")
local hints = ffi.new("struct addrinfo")

hints.ai_family = C.AF_INET -- DOES NOT work in windows: AF_UNSPEC,  AF_UNSPEC == use IPv4 or IPv6, whichever
hints.ai_socktype = C.SOCK_STREAM
hints.ai_protocol = C.IPPROTO_TCP
hints.ai_flags = bit.bor(C.AI_PASSIVE) -- fill in my IP for me
local host = nil -- binding, can be nil
local serv = tostring(port)
local err = socket_getaddrinfo(host, serv, hints, res)
if err ~= 0 then
	print("  -- sock.getaddrinfo error: '"..socket_errortext(err).."'")
	os.exit()
end

-- Create a SOCKET for connecting to server
-- print(res[0].ai_family, res[0].ai_socktype, res[0].ai_protocol) -- this MUST be same as next line
-- print(C.AF_INET, C.SOCK_STREAM, C.IPPROTO_TCP)

ListenSocket = socket_socket(res[0].ai_family, res[0].ai_socktype, res[0].ai_protocol) -- C.AF_INET, C.SOCK_STREAM, C.IPPROTO_TCP)
if ListenSocket == INVALID_SOCKET then
		socket_cleanup(nil, ListenSocket, "socket_socket failed with error: ")
		return 1
end

-- Setup the TCP listening socket
local on = ffi.new("int32_t[1]", 1)
local on_c = ffi.cast("char *", on)
local rc = socket_setsockopt(ListenSocket, C.SOL_SOCKET, C.SO_REUSEADDR, on_c, ffi.sizeof(on))

--[[
local sockaddr = ffi.cast("struct sockaddr *", addr)
print(addr, sockaddr) -- ffi.cast("struct sockaddr *", addr)
result = socket_bind(ListenSocket, sockaddr, ffi.sizeof(addr))
]]
result = socket_bind(ListenSocket, res[0].ai_addr, res[0].ai_addrlen)
if result < 0 then
	socket_cleanup(ListenSocket, result, "socket_bind failed with error: ")
end

result = socket_listen(ListenSocket, 64) --C.SOMAXCONN
if result < 0 then
	socket_cleanup(ListenSocket, result, "socket_listen failed with error: ")
end

-- Accept a client socketlocal
print("Waiting for client to connect to server socket number: " .. ListenSocket)
print("Point your brorser to 127.0.0.1:"..port.." and do refresh TWICE.")

client_addr = ffi.new("struct sockaddr_in[1]")
client_addr_ptr = ffi.cast("struct sockaddr *", client_addr)
local client_addr_size = ffi.new("int32_t[1]")
client_addr_size[0] = ffi.sizeof(client_addr)
local ClientSocket = socket_accept(ListenSocket, client_addr_ptr, client_addr_size)
if ClientSocket < 0 then
	socket_cleanup(ListenSocket, ClientSocket, "socket_accept failed with error: ")
end
local rc = socket_setsockopt(ClientSocket, C.SOL_SOCKET, C.SO_REUSEADDR, on_c, ffi.sizeof(on))
socket_close(ListenSocket) -- not needed anymore
print()

print("socket accepted: " .. ClientSocket, client_addr_ptr, client_addr_size, client_addr_size[0])
print("client address : " .. client_addr[0].sin_family, client_addr[0].sin_port, client_addr[0].sin_addr, client_addr[0].sin_zero[0])

-- http://stackoverflow.com/questions/4282292/convert-struct-in-addr-to-text
-- http://www.freelists.org/post/luajit/FFI-pointers-to-pointers,1
-- https://gist.github.com/neomantra/2644943

local hostname = createBuffer(C.NI_MAXHOST)
local servInfo = createBuffer(C.NI_MAXSERV)
local dwRetval = socket_getnameinfo(client_addr_ptr, ffi.sizeof(client_addr), hostname, C.NI_MAXHOST, servInfo, C.NI_MAXSERV, 0)
if dwRetval ~= 0 then
	socket_cleanup("socket_getnameinfo failed with error: "..dwRetval..". "..socket_errortext(errnum))
end
print("client ip:port : "..ffi.string(hostname)..":"..ffi.string(servInfo)) -- servInfo is post number
print()


-- Receive until the peer shuts down the connection
print(ClientSocket)
print(recvbuflen)
repeat
	result = socket_recv(ClientSocket, recvbuf_ptr, recvbuflen, 0)
	if result > 0 then
		print(" *** Bytes received: ", result)
		print(" *** Data  received: \n\n", ffi.string(recvbuf_ptr))
		print()
		print()
		-- Echo the buffer back to the sender
		local send_result = socket_send( ClientSocket, recvbuf_ptr, result, 0 )
		if send_result < 0 then
			socket_cleanup(ClientSocket, send_result, "socket_send failed with error: ")
		end
		print(" *** Bytes sent: ", send_result)
	elseif result == 0 then
		print(" *** Connection closing...")
	else
		socket_cleanup(ClientSocket, result, "socket_recv failed with error: ")
	end
until result <= 0

-- shutdown the connection since we're done
result = socket_shutdown(ClientSocket, C.SD_SEND)
if result < 0 then
		socket_cleanup(ClientSocket, result, "shutdown failed with error: ")
end

-- cleanup
socket_close(ClientSocket)
socket_cleanup()


print()
print(" -- lib_tcp.lua end -- ")
print()
=======
function tcp_listen(port)
	-- http://beej.us/guide/bgnet/output/html/multipage/syscalls.html#bind
	local res = ffi.new("struct addrinfo*[1]")
	local hints = ffi.new("struct addrinfo")

	hints.ai_family = C.AF_INET -- DOES NOT work in windows: AF_UNSPEC,  AF_UNSPEC == use IPv4 or IPv6, whichever
	hints.ai_socktype = C.SOCK_STREAM
	hints.ai_protocol = C.IPPROTO_TCP
	hints.ai_flags = bit.bor(C.AI_PASSIVE) -- fill in my IP for me
	local host = nil -- binding, can be nil
	local serv = tostring(port)
	local err = socket_getaddrinfo(host, serv, hints, res)
	if err ~= 0 then
		print("  -- sock.getaddrinfo error: '"..socket_errortext(err).."'")
		os.exit()
	end
	-- Create a SOCKET for connecting to server
	local ListenSocket = socket_socket(res[0].ai_family, res[0].ai_socktype, res[0].ai_protocol)
	--[[if res[0].ai_family ~= C.AF_INET or res[0].ai_socktype ~= C.SOCK_STREAM or res[0].ai_protocol~= C.IPPROTO_TCP then
		-- socket_socket(C.AF_INET, C.SOCK_STREAM, C.IPPROTO_TCP)
		socket_cleanup(nil, ListenSocket, "socket_socket types are incorrect: ")
		return -1
	end]]
	if ListenSocket == INVALID_SOCKET then
			socket_cleanup(nil, ListenSocket, "socket_socket failed with error: ")
			return -1
	end

	-- Setup the TCP listening socket
	local result
	-- SO_REUSEADDR, set reuse address for listen socket before bind
	result = socket_setsockopt(ListenSocket, C.SOL_SOCKET, C.SO_REUSEADDR, 1)
	if result ~= 0 then
		socket_cleanup(ListenSocket, result, "socket_setsockopt SO_REUSEADDR failed with error: ")
	end
	-- bind
	result = socket_bind(ListenSocket, res[0].ai_addr, res[0].ai_addrlen)
	if result ~= 0 then
		socket_cleanup(ListenSocket, result, "socket_bind failed with error: ")
	end
	-- listen
	result = socket_listen(ListenSocket, C.SOMAXCONN)
	if result ~= 0 then
		socket_cleanup(ListenSocket, result, "socket_listen failed with error: ")
	end
	return ListenSocket
end

function tcp_accept(ListenSocket)
	-- Accept a client socket
	client_addr = ffi.new("struct sockaddr_in[1]") -- "struct sockaddr_in[1]"
	client_addr_ptr = ffi.cast("struct sockaddr *", client_addr)
	local client_addr_size = ffi.new("int[1]")
	client_addr_size[0] = ffi.sizeof("struct sockaddr")
	local ClientSocket = socket_accept(ListenSocket, client_addr_ptr, client_addr_size)

	local ClientSocket = socket_accept(ListenSocket, client_addr_ptr, client_addr_size)
	if ClientSocket < 0 then
		socket_cleanup(ListenSocket, ClientSocket, "socket_accept failed with error: ")
	end
	-- SO_SNDBUF, send buffer size
	result = socket_setsockopt(ClientSocket, C.SOL_SOCKET, C.SO_SNDBUF, sendBufSize)
	if result ~= 0 then
		socket_cleanup(ClientSocket, result, "socket_setsockopt SO_SNDBUF failed with error: ")
	end
	-- SO_RCVBUF, reveive buffer size
	result = socket_setsockopt(ClientSocket, C.SOL_SOCKET, C.SO_RCVBUF, receiveBufSize)
	if result ~= 0 then
		socket_cleanup(ClientSocket, result, "socket_setsockopt SO_RCVBUF failed with error: ")
	end
	-- TCP_NODELAY, tcp-nodelay to 1
	result = socket_setsockopt(ClientSocket, C.SOL_SOCKET, C.TCP_NODELAY, tcpNoDelay)
	if result ~= 0 then
		socket_cleanup(ClientSocket, result, "socket_setsockopt TCP_NODELAY failed with error: ")
	end
	-- SO_USELOOPBACK, use always loopback when possible
	if not isWin then -- SO_USELOOPBACK is not supported by windows
		result = socket_setsockopt(ClientSocket, C.SOL_SOCKET, C.SO_USELOOPBACK, 1)
		if result ~= 0 then
			socket_cleanup(ClientSocket, result, "socket_setsockopt SO_USELOOPBACK failed with error: ")
		end
	end

	--[[ -- set to blocking mode
	local result
	result = socket_ioctlsocket(ListenSocket, FIONBIO, 1)
	if result ~= 0 then
		socket_cleanup(ListenSocket, result, "socket_ioctlsocket (set to blocking mode) failed with error: ")
	end
	]]

	return ClientSocket --,client_addr_ptr
end

function tcp_address(socket)
	local addr = ffi.new("struct sockaddr_storage")
	local len = ffi.new("unsigned int[1]")
	len[0] = ffi.sizeof(addr) --ffi.sizeof("struct sockaddr")
	socket_getpeername(socket, ffi.cast("struct sockaddr *", addr), len)
	-- deal with both IPv4 and IPv6:
	local ipstr, port
	if addr.ss_family == C.AF_INET then
			ipstr = ffi.new("char[?]", C.INET_ADDRSTRLEN)
			local s = ffi.cast("struct sockaddr_in *", addr)
			port = socket_ntohs(s.sin_port)
			socket_inet_ntop(C.AF_INET, s.sin_addr, ipstr)
	else  -- C.AF_INET6
			ipstr = ffi.new("char[?]", C.INET6_ADDRSTRLEN)
			local s = ffi.cast("struct sockaddr_in6 *", addr)
			port = socket_ntohs(s.sin6_port)
			socket_inet_ntop(C.AF_INET6, s.sin6_addr, ipstr)
	end
	return ffi.string(ipstr)..":"..port --ffi.string(port)
	--[[
	-- http://stackoverflow.com/questions/4282292/convert-struct-in-addr-to-text
	-- http://www.freelists.org/post/luajit/FFI-pointers-to-pointers,1
	-- https://gist.github.com/neomantra/2644943

	local hostname = createBuffer(C.NI_MAXHOST)
	local servInfo = createBuffer(C.NI_MAXSERV)
	local result = socket_getnameinfo(client_addr_ptr, ffi.sizeof("struct sockaddr_in"), hostname, C.NI_MAXHOST, servInfo, C.NI_MAXSERV, 0)
	if result ~= 0 then
		socket_cleanup(socket, result, "socket_getnameinfo failed with error: ")
	end
	--print("client ip:port : "..ffi.string(hostname)..":"..ffi.string(servInfo)) -- servInfo is post number
	return ffi.string(hostname)..":"..ffi.string(servInfo)
	]]
end

function tcp_close(ListenSocket)
	socket_close(ListenSocket) -- not needed anymore
end

local conn_wait_polltype = 0
local conn_wait_fd = {}
local conn_wait_event = {}
local conn_wait_revent = {}
function tcp_conn_wait_options_set(opts)
	conn_wait = 0 -- 0=select, 1=poll, 2=kqueue/iocp/epoll
end

function tcp_conn_wait_options_set(opts)
	wait_polltype = 0 -- 0=select, 1=poll, 2=kqueue/iocp/epoll
end

function tcp_conn_wait()
	--socket_poll(wait_opt.) -- not needed anymore
end

>>>>>>> Win XP socket working, tcp library. Linux  AppSharedMemory.lua works with 'sudo'.
