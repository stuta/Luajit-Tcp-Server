--  TestSocket.lua
print()
print(" -- TestSocket.lua start -- ")
print()

dofile "lib_tcp.lua"
local arg = {...}
local ffi = require("ffi")
local C = ffi.C

local port = 5001
local buflen = 16384
local recvbuflen = buflen
local recvbuf,recvbuf_ptr = createBuffer(buflen)
print("..Lua tcp server waiting on: 127.0.0.1:"..port)
print()

-- http://beej.us/guide/bgnet/output/html/multipage/syscalls.html#bind
local ListenSocket = tcp_listen(port)

-- Accept a client socketlocal
print("Waiting for client to connect to server socket number: " .. ListenSocket)
print("Point your brorser to 127.0.0.1:"..port.." and do refresh 3 times (or more).")

local ClientSocket,client_addr_ptr = tcp_accept(ListenSocket)

print("client ip:port = "..tcp_address(ClientSocket)) -- servInfo is post number
print()

-- Receive until the peer shuts down the connection
local totalBytesReceived = 0
local totalBytesSent = 0
local receiveFlags = 0
local sendFlags = 0

repeat
	result = socket_recv(ClientSocket, recvbuf_ptr, recvbuflen, receiveFlags)
	if result > 0 then
		totalBytesReceived = totalBytesReceived + result
		print(" *** Bytes received: ", result.." / "..totalBytesReceived.." total")
		print(" *** Data  received: \n\n", ffi.string(recvbuf_ptr))
		print()
		print()
		-- Echo the buffer back to the sender
		local send_result = socket_send(ClientSocket, recvbuf_ptr, result, sendFlags)
		if send_result < 0 then
			socket_cleanup(ClientSocket, send_result, "socket_send failed with error: ")
		end
		totalBytesSent = totalBytesSent + tonumber(send_result)
		print(" *** Bytes sent: ", send_result.." / "..totalBytesSent.." total")
	elseif result == 0 then
		print(" *** Connection closing...")
	else
		socket_cleanup(ClientSocket, result, "socket_recv failed with error: ")
	end
until result <= 0

tcp_close(ClientSocket)
tcp_close(ListenSocket)

-- shutdown the connection since we're done
result = socket_shutdown(ClientSocket, C.SD_SEND)
if result < 0 and result ~= -1 then
		socket_cleanup(ClientSocket, result, "shutdown failed with error: ")
end

-- cleanup
socket_close(ClientSocket)
socket_cleanup()


print()
print(" -- TestSocket.lua end -- ")
print()
