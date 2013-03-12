--  ThreadTest.lua
print()
print(" -- SocketTest.lua start -- ")
print()

local arg = {...}
dofile "socket.lua"
local ffi = require("ffi")
local C = ffi.C


-- windows
local buflen = 512
local recvbuflen = buflen
local port = 5001

local INVALID_SOCKET, SOCKET_ERROR
if isWin then
	INVALID_SOCKET = ffi.new("SOCKET", -1)
else
	INVALID_SOCKET = -1
end
SOCKET_ERROR 				= -1	-- 0xffffffff

local err = socket_initialize()
if err ~= 0 then
	socket_cleanup(nil, err, "ERROR in socket_initialize(): ")
end

local recvbuf = createBufferVariable(256)
-- Create a SOCKET for connecting to server
ListenSocket = socket_socket(C.AF_INET, C.SOCK_STREAM, C.IPPROTO_TCP)
if ListenSocket == INVALID_SOCKET then
		socket_cleanup(nil, ListenSocket, "socket_socket failed with error: ")
		return 1
end

local on = ffi.new("int32_t[1]", 1)
-- print("on[0]", on[0])
local rc = socket_setsockopt(ListenSocket, C.SOL_SOCKET, C.SO_REUSEADDR, on, ffi.sizeof(on))

-- Setup the TCP listening socket

local addr = ffi.new("struct sockaddr_in[1]")
addr[0].sin_family = C.AF_INET
addr[0].sin_addr.s_addr = C.INADDR_ANY -- does not work in win without changing in_addr.S_addr to in_addr.s_addr
addr[0].sin_port = socket_htons(port)
-- C.inet_aton("127.0.0.1", addr[0].sin_addr) -- test this

local sockaddr = ffi.cast("struct sockaddr *", addr)
print(addr, sockaddr) -- ffi.cast("struct sockaddr *", addr)
result = socket_bind(ListenSocket, sockaddr, ffi.sizeof(addr))
if result < 0 then
	socket_cleanup(ListenSocket, result, "socket_bind failed with error: ")
	return 1
end

result = socket_listen(ListenSocket, 64) --C.SOMAXCONN
if result < 0 then
	socket_cleanup(ListenSocket, result, "socket_listen failed with error: ")
end

-- Accept a client socketlocal
print("Waiting for client to connect to server socket: " .. ListenSocket)

client_addr = ffi.new("struct sockaddr_in[1]")
client_addr_ptr = ffi.cast("struct sockaddr *", client_addr)
local client_addr_size = ffi.new("int32_t[1]")
client_addr_size[0] = ffi.sizeof(client_addr)
local ClientSocket = socket_accept(ListenSocket, client_addr_ptr, client_addr_size)
-- local ClientSocket = socket_accept(ListenSocket, nil, nil)
if ClientSocket < 0 then
	socket_cleanup(ListenSocket, ClientSocket, "socket_accept failed with error: ")
end
print("socket accepted: " .. ClientSocket, client_addr_ptr, client_addr_size, client_addr_size[0])
print("client  address: " .. client_addr[0].sin_family, client_addr[0].sin_port, client_addr[0].sin_addr, client_addr[0].sin_zero[0]) -- client_addr[0].sin_len not in win

-- http://stackoverflow.com/questions/4282292/convert-struct-in-addr-to-text
local ai = ffi.new("struct addrinfo[1]")
local ai_ptr = ffi.cast("struct addrinfo *", ai)
local ai_hdl = ffi.cast("struct addrinfo **", ai)
local hints = ffi.new("struct addrinfo[1]")
local hints_ptr = ffi.cast("struct addrinfo *", hints)
local AF_UNSPEC 		= 0 -- unspecified
hints[0].ai_family = AF_UNSPEC
hints[0].ai_socktype = C.SOCK_STREAM
local err = C.getaddrinfo("127.0.0.1", "http", hints_ptr, ai_hdl) -- C.getaddrinfo("8.8.8.8", "http", hints, ai)
print("getaddrinfo: ", err, ai, ai[0], ai_ptr, ai_ptr[0], ai_ptr.ai_addrlen, ai_ptr.ai_addr, ai_ptr.ai_canonname)
-- getnameinfo

hostname = getOffsetPointer(createBufferVariable(C.NI_MAXHOST), 0)
servInfo = getOffsetPointer(createBufferVariable(C.NI_MAXSERV), 0)
local dwRetval = C.getnameinfo(client_addr_ptr, client_addr_ptr.sa_len, hostname, C.NI_MAXHOST, servInfo, C.NI_MAXSERV, 0)
-- eorks: ffi.sizeof(client_addr) --client_addr_ptr.sa_len

--print("client  address: ",ffi.string(hostname[0])) -- .. ffi.string(servInfo[0]))
print("client  address: ", dwRetval, hostname, ffi.string(hostname)) -- .. ffi.string(servInfo[0]))
print("client  address: ", ffi.string(C.gai_strerror(dwRetval)), servInfo, ffi.string(servInfo))

hostname2 = getOffsetPointer(createBufferVariable(C.NI_MAXHOST), 0)
servInfo2 = getOffsetPointer(createBufferVariable(C.NI_MAXSERV), 0)
local dwRetval = C.getnameinfo(ai_ptr.ai_addr, ai_ptr.ai_addrlen, hostname2, C.NI_MAXHOST, servInfo2, C.NI_MAXSERV, 0)
print("getaddrinfo  address: ", dwRetval, hostname2, ffi.string(hostname2)) -- .. ffi.string(servInfo[0]))
print("getaddrinfo  address: ", ffi.string(C.gai_strerror(dwRetval)), servInfo2, ffi.string(servInfo2))
--C.freeaddrinfo(ai_ptr)

--[[ struct sockaddr_in
		uint8_t	sin_len;
		sa_family_t	sin_family;
		in_port_t	sin_port;
		struct	in_addr sin_addr;
		char		sin_zero[8];
		]]
-- No longer need server socket
socket_close(ListenSocket)

-- Receive until the peer shuts down the connection
local recvbuf_ptr = ffi.new("uint8_t[?]", 4096) --getOffsetPointer(recvbuf, 0)
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

-- ============================================

--[[
local sockfd = socket_socket(C.AF_INET, C.SOCK_STREAM, C.IPPROTO_TCP)
if sockfd < 0 then
	socket_cleanup()
	error("ERROR opening socket")
end

-- Initialize socket structure
local serv_addr 	= ffi.new("struct addrinfo[1]")
local cli_addr 	= ffi.new("struct addrinfo[1]")

local portno = 5001
serv_addr[0].sin_family = C.AF_INET
serv_addr[0].sin_addr.s_addr = C.INADDR_ANY
serv_addr[0].sin_port = socket_htons(portno)

-- Now bind the host address using bind() call.
if socket_bind(sockfd, ffi.cast("struct sockaddr *", serv_addr), ffi.sizeof(serv_addr)) < 0 then
	socket_cleanup()
	error("ERROR on binding")
end

hints.ai_family = PF_UNSPEC
hints.ai_socktype = SOCK_STREAM
hints.ai_flags = AI_PASSIVE
error = getaddrinfo(nil, "http", &hints, &res0)
if error
			 errx(1, "%s", gai_strerror(error))
			 /*NOTREACHED*/
end

 s[nsock] = socket(res->ai_family, res->ai_socktype, res->ai_protocol)
 if s[nsock] < 0
				 cause = "socket"
				 continue
 end

 if bind(s[nsock], res->ai_addr, res->ai_addrlen) < 0


-- Now start listening for the clients, here process will
-- go in sleep mode and will wait for the incoming connection
socket_listen(sockfd, 5)

-- Accept actual connection from the client
local newsockfd = socket_accept(sockfd, ffi.cast("struct sockaddr *", cli_addr), clilen)
if newsockfd < 0 then
	socket_cleanup()
	error("ERROR on accept")
end

-- If connection is established then start communicating
print("C.read")
local n = socket_read(newsockfd, buffer[0], 255)
if n < 0 then
	socket_cleanup()
	error("ERROR reading from socket: "..tonumber(n))
end
print("Here is the message: %s\n", ffi.string(buffer[0]))

-- Write a response to the client
n = socket_write(newsockfd, "I got your message", 18)
if n < 0 then
	socket_cleanup()
	error("ERROR writing to socket")
end
socket_cleanup()
--]]

print()
print(" -- SocketTest.lua end -- ")
print()
