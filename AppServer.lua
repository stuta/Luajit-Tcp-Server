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

local ProFi = require 'ProFi'
--ProFi:setGetTimeMethod( microSeconds )
local useProfilier=false

local port = tonumber(arg[1]) or 5001
local debug = tonumber(arg[2]) or 0
local timeout = tonumber(arg[3]) or 2
local closeConnection = tonumber(arg[4]) or 0
local debugPrintChars = tonumber(arg[5]) or 40
print("default usage: lj AppServer.lua 5001 0 2 0 40")
print("port="..port.." debug="..debug.." timeout="..timeout.." closeConnection="..closeConnection.." debugPrintChars="..debugPrintChars)
print("debug=-1 means that program will be profilied until 10 000 polls has happened")
timeout = timeout * 1000  -- milliseconds to seconds

useProfilier = debug < 0

--[[	If timeout is greater than zero, it specifies a maximum interval (in milliseconds) to wait for any file
     	descriptor to become ready.  If timeout is zero, then poll() will return without blocking. If the value
     	of timeout is -1, the poll blocks indefinitely.]]

--[[POLLPRI	Priority data may be read without blocking. This flag is not supported by the Microsoft Winsock provider.]]
local client_events = bit.bor(C.POLLIN) --, C.POLLPRI)
local listen_events = bit.bor(C.POLLIN) --, C.POLLPRI) --, C.POLLOUT)
local buflen = 16384


local answerStart = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: "
local answerEnd = "\r\nConnection: close\r\n\r\n"

local sendbuflen = buflen + #answerStart + 10 + #answerEnd -- buflen + length of headers + 10 bytes for content length
-- print("sendbuflen:"..sendbuflen)
--local maxContentLengthNumbers = 5 -- 16384 is 5 digits
--local contentLengthPos = #answerStart
local recvbuf,recvbuf_ptr = createBuffer(buflen)
local sendbuf,sendbuf_ptr = createBuffer(sendbuflen)

local answerCount = 0
local pollInCount = 0
local pollOutCount = 0
local pollCloseCount = 0
local pollErrCount = 0

local totalBytesReceived = 0
local totalBytesSent = 0
local receiveFlags = 0
local sendFlags = 0


print("..Lua tcp server waiting on: http://127.0.0.1:"..port)
print()

-- http://beej.us/guide/bgnet/output/html/multipage/syscalls.html#bind
local listen_socket = tcp_listen(port)
-- Accept a client socketlocal
print("Waiting for client to connect to server socket number: " .. listen_socket)

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

local function close(socket)
  if socket < 1 then
  	print("-*-ERR: close socket: "..socket)
  end
	poll_remove_fd(socket)
	tcp_close(socket)
end

local function answer(socket)
	answerCount = answerCount + 1
	local show = answerCount%500 == 0
	if show then
	  print("answer: "..answerCount..".")
	end
	result = socket_recv(socket, recvbuf_ptr, buflen, receiveFlags)
	if result > 0 then
		totalBytesReceived = totalBytesReceived + result
		if debug >= 2 then
			print(" -- Bytes received: ", result.." / "..totalBytesReceived.." total")
			print(" -- Data  received: \n\n", string.sub(ffi.string(recvbuf_ptr) ,1 ,debugPrintChars))
			print()
		end
		local send_result = socket_send(socket, sendbuf_ptr, content_len, sendFlags) -- send answer buffer

		if debug >= 3 then print(" -- sendbuf_ptr:\n"..ffi.string(sendbuf_ptr).."\n") end
		--print(" -- send_result / content_len: "..send_result.." / "..content_len)
		if send_result < 0 then
			socket_cleanup(socket, send_result, "socket_send failed with error: ")
		elseif send_result > 0 then
			totalBytesSent = totalBytesSent + tonumber(send_result)
		end
		if closeConnection > 0 then
			close(socket)
		end
		--print(" -- Bytes sent: ", send_result.." / "..totalBytesSent.." total")
	elseif result == 0 then
		print(" -- nothing received...")
	else
		print(" -- socket_recv failed with error: "..result)
		close(socket)
		--socket_cleanup(socket, result, "socket_recv failed with error: ")
	end
end

function out_callback(socket)
	if debug > 0 then print("out_callback: ", socket) end
	-- runs this function when you can write out
	pollOutCount = pollOutCount + 1
end

function close_callback(socket)
	if debug > 0 then print("close_callback: ", socket) end
	-- runs this function when you can write out
	close(socket)
	pollCloseCount = pollCloseCount + 1
end

function error_callback(socket, event_text)
	print("*-*ERR: error_callback: "..event_text..", fd="..socket)
	-- runs this function when you can write out
	if event_text == "POLLNVAL" then
		close(socket)
	else -- event_text == "POLLERR"
		close(socket)
		-- socket_cleanup(socket, 0, "error_callback: "..event_text)
	end
	pollErrCount = pollErrCount + 1
end

function in_callback(socket)
	if socket == listen_socket then
		repeat
			local client_socket = tcp_accept(socket)
			if client_socket > 0 then
				poll_add_fd(client_socket, client_events)
				if debug > 0 then print("  -- new client, ip:port = "..tcp_address(client_socket)) end
			end
		until client_socket < 1
	else
		answer(socket)
	end
	pollInCount = pollInCount + 1
end

-- set poll timeout, callbacks and sockets
poll_debug_set(debug)
poll_timeout_set(timeout)

poll_in_callback_set(in_callback)
poll_out_callback_set(out_callback)
poll_close_callback_set(close_callback)
poll_error_callback_set(error_callback)

poll_add_fd(listen_socket, listen_events) -- add listen socket to poll arrays

--local pollMaxEventCount = 0
local loopCount = 0
if useProfilier then ProFi:start() end
repeat
	loopCount = loopCount + 1
	local ret = poll_poll()
	--[[local key = io.read(0)
	if key == "q" then
		print("do you want to quit?")
		key = waitKeyPressed()
		if key == "y" then break end
	end]]
until useProfilier and loopCount > 10000
if useProfilier then ProFi:stop() end

close(listen_socket)

print()
print(" -- AppServer.lua STATS -- ")
print()
print("answerCount:          "..answerCount)
print("poll_fd_count:        "..poll_fd_count())
if poll_fd_count() > 0 then
	poll_remove_all(tcp_close)
end
--print("poll_max_event_count: "..pollMaxEventCount)
print("pollCount:            "..poll_poll_count())
print("pollInCount:          "..pollInCount)
print("pollOutCount:         "..pollOutCount)
print("pollCloseCount:       "..pollCloseCount)
print("pollErrCount:         "..pollErrCount)
print("fd add/remove count:  "..poll_fd_add_count().."/"..poll_fd_remove_count())
print("totalBytesReceived:   "..totalBytesReceived)
print("totalBytesSent:       "..totalBytesSent)
if useProfilier then
	ProFi:writeReport("AppServer.txt")
	os.execute("edit AppServer.txt")
end

print()
print(" -- AppServer.lua end -- ")
print()


local function answer_echo(socket)

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

end
