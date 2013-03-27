--  AppServer.lua
print()
print(" -- AppServer.lua start -- ")
print()

dofile "lib_tcp.lua"
dofile "lib_poll.lua"
local arg = {...}
local ffi = require("ffi")
local C = ffi.C
local bit = require("bit")

local timeout = 2*1000 -- 2000 ms = 2 sec
--[[	If timeout is greater than zero, it specifies a maximum interval (in milliseconds) to wait for any file
     	descriptor to become ready.  If timeout is zero, then poll() will return without blocking. If the value
     	of timeout is -1, the poll blocks indefinitely.]]

local client_events = bit.bor(C.POLLIN)
local listen_events = bit.bor(C.POLLIN, C.POLLOUT)
local port = 5001
local buflen = 16384


local answerStart = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: "
local answerEnd = "\r\nConnection: close\r\n\r\n"

local sendbuflen = buflen + #answerStart + 10 + #answerEnd -- buflen + length of headers + 10 bytes for content length
print("sendbuflen:"..sendbuflen)
--local maxContentLengthNumbers = 5 -- 16384 is 5 digits
--local contentLengthPos = #answerStart
local recvbuf,recvbuf_ptr = createBuffer(buflen)
local sendbuf,sendbuf_ptr = createBuffer(sendbuflen)

local answerCount = 0
local pollCount = 0
local pollInCount = 0
local pollOutCount = 0
local pollCloseCount = 0
local pollErrCount = 0

local totalBytesReceived = 0
local totalBytesSent = 0
local receiveFlags = 0
local sendFlags = 0


print("..Lua tcp server waiting on: 127.0.0.1:"..port)
print()

-- http://beej.us/guide/bgnet/output/html/multipage/syscalls.html#bind
local listen_socket = tcp_listen(port)
-- Accept a client socketlocal
print("Waiting for client to connect to server socket number: " .. listen_socket)
print("Point your brorser to 127.0.0.1:"..port.." and do refresh 3 times (or more).")

--[[local client_socket = tcp_accept(listen_socket)
print("client ip:port = "..tcp_address(client_socket))
print()]]

-- local htmlEnd = "<html><body><pre></pre></body></html>"
local content = "<html><body>Hello World!</body></html>"
local content_len = #content -- result
local header = answerStart..tostring(content_len)..answerEnd
content = header..content
local content_len = #content
ffi.copy(sendbuf_ptr, cstr(content), content_len) -- copy header to answer buffer

local function answer(socket)
	answerCount = answerCount + 1
	local show = answerCount%500 == 0
	if show then
	  print("answer: "..answerCount..".")
	end
	result = socket_recv(socket, recvbuf_ptr, buflen, receiveFlags)
	if result > 0 then
		totalBytesReceived = totalBytesReceived + result
		--[[print(" -- Bytes received: ", result.." / "..totalBytesReceived.." total")
		print(" -- Data  received: \n\n", ffi.string(recvbuf_ptr))
		print()
		print()]]
		-- Echo the buffer back to the sender
		--local send_result = socket_send(socket, recvbuf_ptr, result, sendFlags)

		local send_result = socket_send(socket, sendbuf_ptr, content_len, sendFlags) -- send answer buffer

		--print(" -- send_result / content_len: "..send_result.." / "..content_len)
		if send_result < 0 then
			socket_cleanup(socket, send_result, "socket_send failed with error: ")
		elseif send_result == content_len then
			poll_remove_fd(socket)
			tcp_close(socket)
		else
			poll_remove_fd(socket)
			tcp_close(socket)
		end
		if send_result > 0 then
			totalBytesSent = totalBytesSent + tonumber(send_result)
		end
		--print(" -- Bytes sent: ", send_result.." / "..totalBytesSent.." total")
	elseif result == 0 then
		print(" -- nothing received...")
	else
		poll_remove_fd(socket)
		tcp_close(socket)
		print(" -- socket_recv failed with error: "..result)
		--socket_cleanup(socket, result, "socket_recv failed with error: ")
	end
end

function out_callback(socket)
	print("out_callback: ", socket)
	-- runs this function when you can write out
	pollOutCount = pollOutCount + 1
end

function close_callback(socket)
	print("close_callback: ", socket)
	-- runs this function when you can write out
	poll_remove_fd(socket)
	tcp_close(socket) --socket_cleanup(socket, 0, "")
	pollCloseCount = pollCloseCount + 1
end

function error_callback(socket, event_text)
	print("error_callback: "..event_text, socket)
	-- runs this function when you can write out
	poll_remove_fd(socket)
	if event_text == "POLLNVAL" then
		tcp_close(socket) --socket_cleanup(socket, 0, "")
	else
		socket_cleanup(socket, 0, "error_callback: "..event_text)
	end
	pollErrCount = pollErrCount + 1
end

function in_callback(socket)
	if socket == listen_socket then
		repeat
			local client_socket = tcp_accept(socket)
			if client_socket > 0 then
				poll_add_fd(client_socket, client_events)
				-- print(" -- new client, ip:port = "..tcp_address(client_socket))
			end
		until client_socket < 1
	else
		answer(socket)
	end
	pollInCount = pollInCount + 1
end

-- set poll timeout, callbacks and sockets
poll_timeout_set(timeout)

poll_in_callback_set(in_callback)
poll_out_callback_set(out_callback)
poll_close_callback_set(close_callback)
poll_error_callback_set(error_callback)

poll_add_fd(listen_socket, listen_events) -- add listen socket to poll arrays

local pollMaxEventCount = 0
repeat
	pollCount = pollCount + 1
	--[[local show = pollCount%500 == 0
	if show then
		print("poll: "..pollCount..". ") --io.write("poll: "..pollCount..". "); io.flush()
	end]]
	local ret = poll_poll()
	--if ret > pollMaxEventCount then pollMaxEventCount = ret end
	--[[if show then
		print("ret="..ret)
	end]]
until false -- and pollCount > 200 or pollInCount > 100 -- or ctrl-C or some keypressed quit?

poll_remove_fd(listen_socket)
tcp_close(listen_socket)

print()
print(" -- AppServer.lua STATS -- ")
print()
print("answerCount:          "..answerCount)
print("poll_fd_count:        "..poll_fd_count())
if poll_fd_count() > 0 then
	poll_remove_all(tcp_close)
end
print("poll_max_event_count: "..pollMaxEventCount)
print("pollCount:            "..pollCount)
print("pollInCount:          "..pollInCount)
print("pollOutCount:         "..pollOutCount)
print("pollCloseCount:       "..pollCloseCount)
print("pollErrCount:         "..pollErrCount)
print("totalBytesReceived:   "..totalBytesReceived)
print("totalBytesSent:       "..totalBytesSent)

print()
print(" -- AppServer.lua end -- ")
print()


local function answer_echo(socket)
	answerCount = answerCount + 1
	--print("answer: ", socket)
	result = socket_recv(socket, recvbuf_ptr, buflen, receiveFlags)
	if result > 0 then
		totalBytesReceived = totalBytesReceived + result
		--[[print(" -- Bytes received: ", result.." / "..totalBytesReceived.." total")
		print(" -- Data  received: \n\n", ffi.string(recvbuf_ptr))
		print()
		print()]]
		-- Echo the buffer back to the sender
		--local send_result = socket_send(socket, recvbuf_ptr, result, sendFlags)

		local content_len = result --#content -- result
		local header = answerStart..tostring(content_len + #htmlEnd)..answerEnd..answerCount..".\r\n"
		local header_len = #header
		--print(" -- header     : "..header)
		ffi.copy(sendbuf_ptr, cstr(header), header_len) -- copy header to answer buffer
		local buffer_ptr = getOffsetPointer(sendbuf, header_len)

		ffi.copy(buffer_ptr, recvbuf_ptr, content_len) -- copy content to answer buffer
		content_len = content_len + header_len
		buffer_ptr = getOffsetPointer(sendbuf, content_len)
		ffi.copy(buffer_ptr, cstr(htmlEnd), #htmlEnd) -- copy header to answer buffer
		content_len = content_len + #htmlEnd
		--print(" -- sendbuf_ptr:\n"..ffi.string(sendbuf_ptr))
		local send_result = socket_send(socket, sendbuf_ptr, content_len, sendFlags) -- send answer buffer
		--print(" -- send_result / content_len: "..send_result.." / "..content_len)
		if send_result < 0 then
			socket_cleanup(socket, send_result, "socket_send failed with error: ")
		elseif send_result == content_len then
			poll_remove_fd(socket)
			tcp_close(socket)
		else
			poll_remove_fd(socket)
			tcp_close(socket)
		end
		if send_result > 0 then
			totalBytesSent = totalBytesSent + tonumber(send_result)
		end
		print(" -- Bytes sent: ", send_result.." / "..totalBytesSent.." total")
	elseif result == 0 then
		print(" -- nothing received...")
	else
		socket_cleanup(socket, result, "socket_recv failed with error: ")
	end
end
