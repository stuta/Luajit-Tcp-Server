--  TestSocket.lua
print()
print(" -- TestSocket.lua start -- ")
print()


local arg = {...}
local util = require "lib_util"
local tcp = require "lib_tcp"
local socket = require "lib_socket"
local ffi = require("ffi")
local C = ffi.C

local port = 5001
local buflen = 16384
local recvbuflen = buflen
local recvbuf,recvbuf_ptr = util.createBuffer(buflen)
print("..Lua tcp server waiting on: 127.0.0.1:"..port)
print()

-- http://beej.us/guide/bgnet/output/html/multipage/syscalls.html#bind
local ListenSocket = tcp.listen(port)

-- Accept a client socketlocal
print("Waiting for client to connect to server socket number: " .. ListenSocket)
print("Point your brorser to 127.0.0.1:"..port.." and do refresh 3 times (or more).")

local ClientSocket,client_addr_ptr = tcp.accept(ListenSocket)

print("client ip:port = "..tcp.address(ClientSocket)) -- servInfo is post number
print()

-- Receive until the peer shuts down the connection
local totalBytesReceived = 0
local totalBytesSent = 0
local receiveFlags = 0
local sendFlags = 0

repeat
	result = socket.recv(ClientSocket, recvbuf_ptr, recvbuflen, receiveFlags)
	if result > 0 then
		totalBytesReceived = totalBytesReceived + result
		print(" *** Bytes received: ", result.." / "..totalBytesReceived.." total")
		print(" *** Data  received: \n\n", ffi.string(recvbuf_ptr))
		print()
		print()
		-- Echo the buffer back to the sender
		local send_result = socket.send(ClientSocket, recvbuf_ptr, result, sendFlags)
		if send_result < 0 then
			socket.cleanup(ClientSocket, send_result, "socket.send failed with error: ")
		end
		totalBytesSent = totalBytesSent + tonumber(send_result)
		print(" *** Bytes sent: ", send_result.." / "..totalBytesSent.." total")
	elseif result == 0 then
		print(" *** Connection closing...")
	else
		socket.cleanup(ClientSocket, result, "socket.recv failed with error: ")
	end
until result <= 0

tcp.close(ClientSocket)
tcp.close(ListenSocket)

-- shutdown the connection since we're done
result = socket.shutdown(ClientSocket, C.SD_SEND)
if result < 0 and result ~= -1 then
		socket.cleanup(ClientSocket, result, "shutdown failed with error: ")
end

-- cleanup
socket.close(ClientSocket)
socket.cleanup()


print()
print(" -- TestSocket.lua end -- ")
print()
