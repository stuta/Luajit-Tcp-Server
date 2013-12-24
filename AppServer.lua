--  AppServer.lua

print()
print(" -- AppServer.lua start -- ")
print()

local arg = {...}
local ffi = require("ffi")
local C = ffi.C

print()
print("-- AppServer start --")
if jit then
	print(jit.version)
else
	print(_VERSION)
end
print()

local util = require "lib_util"
local socket = require "lib_socket"
local tcp = require "lib_tcp"
local poll = require "lib_poll"
local bit = require("bit")
local floor = math.floor

local ProFi, profilierEndCount

local port = tonumber(arg[1]) or 5001
local debug_level = tonumber(arg[2]) or 0
local timeout = tonumber(arg[3]) or 2
local closeConnection = tonumber(arg[4]) or 0
local debug_levelPrintChars = tonumber(arg[5]) or 200
local prevPollEmpty = false
local useProfilier = debug_level < 0
if useProfilier then
	useProfilier = debug_level
end

print("default usage: lj AppServer.lua 5001 0 2 0 40")
print("port="..port.." debug_level="..debug_level.." timeout="..timeout.." closeConnection="..closeConnection.." debug_levelPrintChars="..debug_levelPrintChars)
print("debug_level=-1 means that program will be profilied until 10 000 polls has happened")
print("useProfilier: "..tostring(useProfilier))
timeout = timeout * 1000  -- milliseconds to seconds


--[[	If timeout is greater than zero, it specifies a maximum interval (in milliseconds) to wait for any file
     	descriptor to become ready.  If timeout is zero, then poll() will return without blocking. If the value
     	of timeout is -1, the poll blocks indefinitely.]]

--[[POLLPRI	Priority data may be read without blocking. This flag is not supported by the Microsoft Winsock provider.]]
local client_events = bit.bor(C.POLLIN) --, C.POLLPRI)
local listen_events = bit.bor(C.POLLIN) --, C.POLLPRI) --, C.POLLOUT)
local buflen = 16384
local sendbuflen = buflen
local recvbuf,recvbuf_ptr = util.createBuffer(buflen)
local sendbuf,sendbuf_ptr = util.createBuffer(sendbuflen)

--local answerStart = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: "
--local answerEnd = "\r\nConnection: close\r\n\r\n"
--local content = "<html><body>Hello World!</body></html>"

--[[ APACHE:
local answerStart = [ [HTTP/1.1 200 OK
Date: Thu, 28 Mar 2013 19:43:20 GMT
Server: Manage/0.1.00 (Unix) DAV/2 mod_ssl/2.2.22 OpenSSL/0.9.8r
Content-Location: index.html.en
Vary: negotiate
TCN: choice
Last-Modified: Thu, 26 Jul 2012 17:55:03 GMT
ETag: "bd9c3-2c-4c5bf4b80cbc0"
Accept-Ranges: bytes
Content-Length: ]]
--[[ APACHE:
local answerEnd = [ [

Content-Type: text/html
Content-Language: en

]] -- do not remove empty lines inside [[ ]]

-- nginx: (Connection: Close ?)
local answerStart = [[HTTP/1.1 200 OK
Server: masrv/0.1.0
Date: Thu, 28 Mar 2013 22:16:09 GMT
Content-Type: text/html
Connection: Keep-Alive
Content-Length: ]]
local answerEnd = [[

Last-Modified: Wed, 21 Sep 2011 14:34:51 GMT
Accept-Ranges: bytes

]]  -- do not remove empty lines inside [[ ]]

answerEnd = answerEnd:gsub("\n", "\r\n")
answerStart = answerStart:gsub("\n", "\r\n")
local content = [[<html><body><h1>It works - stuta!</h1></body></html>]]
content = content:gsub("\n", "\r\n") -- is this needed?

local content_len = #content
local header = answerStart..tostring(content_len)..answerEnd
content = header..content
local content_len = #content
ffi.copy(sendbuf_ptr, util.cstr(content), content_len) -- copy header to answer buffer


local answerCount = 0
local pollInCount = 0
local pollOutCount = 0
local pollCloseCount = 0
local pollErrCount = 0

local totalBytesReceived = 0
local totalBytesSent = 0
local receiveFlags = 0
local sendFlags = 0

print("..Lua tcp server waiting on: http://127.0.0.1:"..port.."/")
print()

-- http://beej.us/guide/bgnet/output/html/multipage/syscalls.html#bind
local listen_socket = tcp.listen(port)
-- Accept a client socketlocal
print("Waiting for client to connect to server socket number: " .. listen_socket)

local function close(sock)
  if sock < 1 then
  	print("-*-ERR: close socket: "..sock)
  end
	poll.remove_fd(sock)
	tcp.close(sock)
end


local function print_to_same_line(txt)
	io.write("\r"..txt) -- "\r" goes to start of current console line
	io.flush()
end

local function skip(idx, skip)
	return idx - floor(idx/skip)*skip
end

local printToSameLine = false
local function answer(sock)
	answerCount = answerCount + 1
	-- a % b == a - math.floor(a/b)*b
	--if answerCount % 500 == 0 then
	if skip(answerCount, 20000) == 0 then
		if prevPollEmpty then
			prevPollEmpty = false
			print() -- not jit optimized?
		end
		printToSameLine = true
	  print_to_same_line("answer: "..answerCount) -- format_num(answerCount, 0)
	end
	local result = socket.recv(sock, recvbuf_ptr, buflen, receiveFlags)
	if result > 0 then
		totalBytesReceived = totalBytesReceived + result
		if debug_level >= 2 then
			print(" -- Bytes received: ", result.." / "..totalBytesReceived.." total")
			print(" -- Data  received: \n", string.sub(ffi.string(recvbuf_ptr) ,1 ,debug_levelPrintChars))
			print()
		end
		local send_result = socket.send(sock, sendbuf_ptr, content_len, sendFlags) -- send answer buffer

		if debug_level >= 3 then print(" -- sendbuf_ptr:\n"..ffi.string(sendbuf_ptr).."\n") end
		--print(" -- send_result / content_len: "..send_result.." / "..content_len)
		if send_result < 0 then
			socket.cleanup(sock, send_result, "socket.send failed with error: ")
		elseif send_result > 0 then
			totalBytesSent = totalBytesSent + tonumber(send_result)
		end
		if closeConnection > 0 then
			close(sock)
		end
		--print(" -- Bytes sent: ", send_result.." / "..totalBytesSent.." total")
	elseif result == 0 then
		print(" -- nothing received, socked was closed")
		close(sock)
	else
		print(" -- socket.recv failed with error: "..result)
		close(sock)
		--socket.cleanup(sock, result, "socket.recv failed with error: ")
	end
end

function out_callback(sock)
	if debug_level > 0 then print("out_callback: ", sock) end
	-- runs this function when you can write out
	pollOutCount = pollOutCount + 1
end

function close_callback(sock)
	if debug_level > 0 then print("close_callback: ", sock) end
	-- runs this function when you can write out
	close(sock)
	pollCloseCount = pollCloseCount + 1
end

function error_callback(sock, event_text)
	print("*-*ERR: error_callback: "..event_text..", fd="..sock)
	-- runs this function when you can write out
	if event_text == "POLLNVAL" then
		close(sock)
	else -- event_text == "POLLERR"
		close(sock)
		-- socket.cleanup(sock, 0, "error_callback: "..event_text)
	end
	pollErrCount = pollErrCount + 1
end

function in_callback(sock)
	if sock == listen_socket then
		repeat
			local client_socket = tcp.accept(sock)
			if client_socket > 0 then
				poll.add_fd(client_socket, client_events)
				if debug_level > 0 then print("  -- new client, ip:port = "..tcp.address(client_socket)) end
			end
		until client_socket < 1
	else
		answer(sock)
	end
	pollInCount = pollInCount + 1
end

-- set poll timeout, callbacks and sockets
poll.debug_level_set(debug_level)
poll.timeout_set(timeout)

poll.in_callback_set(in_callback)
poll.out_callback_set(out_callback)
poll.close_callback_set(close_callback)
poll.error_callback_set(error_callback)

poll.add_fd(listen_socket, listen_events) -- add listen socket to poll arrays


local function print_poll()
	if printToSameLine then
		printToSameLine = false
		print()
	end
	if prevPollEmpty then --and isWin then
		print_to_same_line(poll.poll_count()..". poll, fd count="..poll.fd_count())
	else
		prevPollEmpty = true
		print(poll.poll_count()..". poll, fd count="..poll.fd_count())
	end
end

if useProfilier==-1 then 
	profilierEndCount = 250000
	ProFi = require("jit.p")
	local options = "fi1"
	local output = "AppServer.txt"
	ProFi.start(options, output)
elseif useProfilier==-2 then 
	profilierEndCount = 600000
	ProFi = require 'ProFi'
	--ProFi:setGetTimeMethod( microSeconds )
	ProFi:start() 
end
repeat
	local ret = poll.poll()
	if ret == 0 then
		print_poll()
	end
until useProfilier and pollInCount > profilierEndCount

if useProfilier then
	if useProfilier==-1 then
		ProFi.stop()
	elseif useProfilier==-2 then
		ProFi:stop() 
		ProFi:writeReport("AppServer.txt")
	end
	os.execute("edit AppServer.txt")
end

close(listen_socket)

print()
print(" -- AppServer.lua STATS -- ")
print()
print("answerCount:          "..answerCount)
print("poll.fd_count:        "..poll.fd_count())
if poll.fd_count() > 0 then
	poll.remove_all(tcp.close)
end
print("pollCount:            "..poll.poll_count())
print("pollInCount:          "..pollInCount)
print("pollOutCount:         "..pollOutCount)
print("pollCloseCount:       "..pollCloseCount)
print("pollErrCount:         "..pollErrCount)
print("fd add/remove count:  "..poll.fd_add_count().."/"..poll.fd_remove_count())
print("totalBytesReceived:   "..totalBytesReceived)
print("totalBytesSent:       "..totalBytesSent)


print()
print(" -- AppServer.lua end -- ")
print()


local function answer_echo(sock)
	-- old test code, not in use
	local content_len = result --#content -- result
	local header = answerStart..tostring(content_len + #htmlEnd)..answerEnd..answerCount..".\r\n"
	local header_len = #header
	ffi.copy(sendbuf_ptr, util.cstr(header), header_len) -- copy header to answer buffer
	local buffer_ptr = getOffsetPointer(sendbuf, header_len)

	ffi.copy(buffer_ptr, recvbuf_ptr, content_len) -- copy content to answer buffer
	content_len = content_len + header_len
	buffer_ptr = getOffsetPointer(sendbuf, content_len)
	ffi.copy(buffer_ptr, util.cstr(htmlEnd), #htmlEnd) -- copy header to answer buffer
	content_len = content_len + #htmlEnd
	local send_result = socket.send(sock, sendbuf_ptr, content_len, sendFlags) -- send answer buffer
end
