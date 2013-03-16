--  TestSocket.lua
print()
print(" -- TestSocket.lua start -- ")
print()

dofile "lib_socket.lua"
local arg = {...}
local ffi = require("ffi")
local C = ffi.C

local buflen = 1024
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
print("Waiting for client to connect to server socket: #" .. ListenSocket)
print("Point your brorser to 127.0.0.1:"..port.." and do refresh TWICE.")

client_addr = ffi.new("struct sockaddr_in[1]")
client_addr_ptr = ffi.cast("struct sockaddr *", client_addr)
local client_addr_size = ffi.new("int32_t[1]")
client_addr_size[0] = ffi.sizeof(client_addr)
local ClientSocket = socket_accept(ListenSocket, client_addr_ptr, client_addr_size)
if ClientSocket < 0 then
	socket_cleanup(ListenSocket, ClientSocket, "socket_accept failed with error: ")
end
socket_close(ListenSocket) -- not needed anymore
print()

print("socket accepted: " .. ClientSocket, client_addr_ptr, client_addr_size, client_addr_size[0])
print("client address : " .. client_addr[0].sin_family, client_addr[0].sin_port, client_addr[0].sin_addr, client_addr[0].sin_zero[0]) -- client_addr[0].sin_len not in win

-- http://stackoverflow.com/questions/4282292/convert-struct-in-addr-to-text
-- http://www.freelists.org/post/luajit/FFI-pointers-to-pointers,1
-- https://gist.github.com/neomantra/2644943

-- local ai = ffi.new("struct addrinfo[1]")
local ai_array = ffi.new("struct addrinfo *[1]")
-- ai_array[0] = ffi.cast("struct addrinfo *", ai)
local hints = ffi.new("struct addrinfo[1]")
hints[0].ai_family = C.AF_INET -- AF_UNSPEC
hints[0].ai_socktype = C.SOCK_STREAM

--local err = socket_getaddrinfo("127.0.0.1", nil, nil, ai_array) -- C.getaddrinfo("8.8.8.8", "http", hints, ai)
--[[
print("getaddrinfo1: ", err, ai_array, ai_array[0])
print("getaddrinfo2: ", ai_array[0].ai_addrlen, ai_array[0].ai_addr, ai_array[0].ai_canonname)
print("getaddrinfo3: ", err, ai, ai[0])
print("getaddrinfo4: ", ai[0].ai_addrlen, ai[0].ai_addr, ai[0].ai_canonname)
print()
]]

local hostname = createBuffer(C.NI_MAXHOST)
local servInfo = createBuffer(C.NI_MAXSERV)
local dwRetval = socket_getnameinfo(client_addr_ptr, ffi.sizeof(client_addr), hostname, C.NI_MAXHOST, servInfo, C.NI_MAXSERV, 0)
if dwRetval ~= 0 then
	socket_cleanup("socket_getnameinfo failed with error: "..dwRetval..". "..socket_errortext(errnum))
end
print("client ip:port : "..ffi.string(hostname)..":"..ffi.string(servInfo)) -- servInfo is post number
print()


-- Receive until the peer shuts down the connection
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
print(" -- TestSocket.lua end -- ")
print()
