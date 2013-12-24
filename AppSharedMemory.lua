--  AppSharedMemory.lua

local arg = {...}
local ffi = require("ffi")

local util = require "lib_util"
local numStringLength = util.numStringLength

local shm = require "lib_shared_memory"
local mmapStatusInWait = shm.mmapStatusInWait
local mmapInRead = shm.mmapInRead
local mmapOutWrite = shm.mmapOutWrite

local ProFi = require 'ProFi'
ProFi:setGetTimeMethod( util.microSeconds )
local useProfilier=false

-- local pos = 0
local readData = "--- not read yet ---" -- this is the length of a input buffer
local readDataLen = string.len(readData)
local readData_c = util.cstr(readData)

local sendData = "--- not sent yet ---"
local sendDataLen = string.len(sendData)
local sendData_c = util.cstr(sendData)

print()
print(" -- AppSharedMemory.lua START -- ")

if util.isLinux then
	print()
	print(" *** AppSharedMemory.lua needs to be run with 'sudo' in Linux *** ")
	print()
end

local isServer, isClient
if arg[1] == "s" then
	isServer = true
elseif arg[1] == "c" then
	isServer = false
else
	print()
	print("param 1 MUST be c(lient) or s(erver), is set to server")
	print()
	isServer = true --os.exit() -- not inside host app!
end
isClient = not isServer

if isServer then
	print(" -- this is shared mem Server -- ")
else
	print(" -- this is shared mem Client -- ")
end
print(" -- jit.version: " .. jit.version)


local arg2 = tonumber(arg[2]) or 0
print("parameter 2 (use changing send data = 1): "..arg2)
local arg2abs = math.abs(arg2)
local useSetData = arg2abs == 1 or false
local useReply = arg[3] == "r" or true --arg2abs==1 or arg2abs==4
local bigLoops = tonumber(arg[4]) or 1
local	loopCount = tonumber(arg[5]) or 5000000
if arg2 < 0 then
	useProfilier=true
	loopCount = loopCount / 200
	--ProFi:start()
end
if not jit.version then -- plain Lua
	loopCount = loopCount / 100
end

local function argPrint()
	if useSetData then
		print("change data in every loop: TRUE")
	else
		print("change data in every loop: FALSE")
	end
	if useReply then
		print("read reply (2-way communication): TRUE")
	else
		print("read reply (2-way communication): FALSE")
	end
end
argPrint()

local fileNameTest = "TestShm_test.shm"
local fileNameS = "TestShm_srv.shm"
local fileNameC = "TestShm_cli.shm" --"AppSharedMemory-c.shm"
local sendBufferSize, readBufferSize
local i
local bufferSize = 4096 -- in windows this is 65536
local timer
local connectSleepMs = 500
local statusIdx = 0
local sentCount = 0
local readCount = 0

-- status
local base64char = {[0]='A',[1]='B',[2]='C',[3]='D',[4]='E',[5]='F',[6]='G',[7]='H',[8]='I',[9]='J',[10]='K',[11]='L',[12]='M',[13]='N',[14]='O',[15]='P',[16]='Q',[17]='R',[18]='S',[19]='T',[20]='U',[21]='V',[22]='W',[23]='X',[24]='Y',[25]='Z',[26]='a',[27]='b',[28]='c',[29]='d',[30]='e',[31]='f',[32]='g',[33]='h',[34]='i',[35]='j',[36]='k',[37]='l',[38]='m',[39]='n',[40]='o',[41]='p',[42]='q',[43]='r',[44]='s',[45]='t',[46]='u',[47]='v',[48]='w',[49]='x',[50]='y',[51]='z',[52]='0',[53]='1',[54]='2',[55]='3',[56]='4',[57]='5',[58]='6',[59]='7',[60]='8',[61]='9',[62]='-',[63]='_'}
local base64ascii = {}
for i = 0, 63 do
	base64ascii[i] = string.byte(base64char[i])
	--io.write(base64char[i]..base64ascii[i].." ")
end
print()


--i = shm.mmapOutCreate(fileNameTest, bufferSize)
--if i > bufferSize then bufferSize = i end -- test windows buffersize, in win7 is 65536, not 4096
--readBufferSize = shm.mmapInConnect(fileNameTest, bufferSize)
--readBufferSize = shm.mmapInDisonnect(fileNameTest)
--i = shm.mmapOutDestroy(fileNameTest)


-- both client and server will crate send file
if( isServer ) then
	-- delete client send buffer
	--i = shm.mmapOutCreate(fileNameC , bufferSize)
	--print(" ..shm.mmapOutCreate result is: " .. i)
	--i = shm.mmapOutDestroy(fileNameC)
	--print(" ..shm.mmapOutCreate result is: " .. i)

	sendBufferSize = shm.mmapOutCreate(fileNameS , bufferSize)
else
	sendBufferSize = shm.mmapOutCreate(fileNameC , bufferSize * 2)
end
print(" ..shm.mmapOutCreate result is: " .. sendBufferSize)

if( sendBufferSize < bufferSize )	then
	print("sendBufferSize < bufferSize")
	os.exit() -- not inside host app!
end

-- both client and server will connect
timer = util.seconds()
repeat
	if( isServer ) then
		readBufferSize = shm.mmapInConnect(fileNameC, bufferSize * 2)
		if util.seconds(timer) > 2 then
			print(" ..server shm.mmapInConnect to "..fileNameC.." result is: " .. readBufferSize)
			timer = util.seconds()
		end
	else
		readBufferSize = shm.mmapInConnect(fileNameS, bufferSize)
		if util.seconds(timer) > 2 then
			print(" ..client shm.mmapInConnect to "..fileNameS.." result is: " .. readBufferSize)
			timer = util.seconds()
		end
	end
	if( readBufferSize < bufferSize ) then
		util.sleep(connectSleepMs)
	end
until readBufferSize > 0


local function send_data_set(loop)
	if loop == 0 then -- init all
		if isServer then
			sendData = "srv-"
		else
			sendData = "cli-"
		end
		sendData = sendData .. string.rep("0", string.len(tostring(loopCount)))
			-- loopCount is max number, fill with as many zeroes, for ex 22000 -> 00000
		sendDataLen = string.len(sendData)
		sendData_c = util.cstr(sendData)

		readDataLen = sendDataLen
	else
		local loopStr = tostring(loop)
		local numCount = numStringLength(loop)
		for idx=1,numCount do
			local cidx = sendDataLen - numCount + idx - 1
			sendData_c[cidx] = string.byte(string.sub(loopStr, idx, idx))
		end
	end
end

local function statusIdxAdd()
	statusIdx = statusIdx + 1
	if statusIdx > 63 then statusIdx = 0 end
end

local status_to_wait_char
local function send_data(loop)
	local doPrint = loop % (loopCount/5) == 0 or loop < 3 or loop > loopCount-2

	if doPrint then
		-- print(loop..". send_data() before, shm.mmapInStatus / shm.mmapOutStatus / wait: "
		-- 	..string.char(shm.mmapInStatus())..string.char(shm.mmapOutStatus()).." "..base64char[statusIdx])
		status_to_wait_char = base64char[statusIdx]
	end

	mmapStatusInWait(base64ascii[statusIdx])
	statusIdxAdd()

	local status = mmapOutWrite(base64ascii[statusIdx], 0, sendData_c, sendDataLen )
	sentCount = sentCount + 1
	if doPrint then
		print(loop..". sent_data, shm.mmapInStatus, shm.mmapOutStatus, wait: "..ffi.string(sendData_c, sendDataLen).."  "
			..string.char(shm.mmapInStatus())..string.char(shm.mmapOutStatus())..status_to_wait_char) -- ..base64char[statusIdx]
		if isServer then
			print()
		end
	end
	if status ~= 0 then
			print()
			print("BREAK: send_data failed with error: " .. status)
	end
	return status
end


local function read_data(loop)
	local doPrint = loop % (loopCount/5) == 0 or loop < 3 or loop > loopCount-2
	if doPrint then
		-- print(loop..". read_data() before, shm.mmapInStatus / shm.mmapOutStatus / wait: "
		-- 	..string.char(shm.mmapInStatus())..string.char(shm.mmapOutStatus()).." "..base64char[statusIdx])
		status_to_wait_char = base64char[statusIdx]
	end

	statusIdxAdd()
	mmapStatusInWait(base64ascii[statusIdx])

	local status = mmapInRead(base64ascii[statusIdx], 0, readData_c, readDataLen)
	readCount = readCount + 1
	if doPrint then
	  local readDataIn = ffi.string(readData_c, readDataLen)
		print(loop..". read_data, shm.mmapInStatus, shm.mmapOutStatus, wait: "..readDataIn.."  "
			..string.char(shm.mmapInStatus())..string.char(shm.mmapOutStatus())..status_to_wait_char) -- ..base64char[statusIdx]
		if isClient  then
			print()
		end
	end
	if status ~= 0 then
			print()
			print("BREAK: read_data failed with error: " .. status)
	end
	return status
end

shm.mmapAddressSet()
send_data_set(0)
shm.mmapStatusOutSet(base64ascii[0]-1) -- ascii(65-1) = "@"
print("mmapStatusInWait()")
mmapStatusInWait(base64ascii[0]-1) -- wait for other partner to set same value
util.sleep(connectSleepMs+200) -- must be bigger than connectSleepMs so that another process can catch us
  -- give another time to wait base64ascii[0]-1 and set base64ascii[0]
shm.mmapStatusOutSet(base64ascii[0]) -- ascii(65) = "A"- we are ready for loop


timer = util.seconds()
if useProfilier then ProFi:start() end

 -- server starts with send and does not wait last
 -- client starts with reply

local bigloop = 0
--local runtime = util.seconds()
repeat
	bigloop = bigloop + 1
	for loop=1, loopCount do


		if isServer or (useReply and loop > 1) then

			if useSetData then
				if isClient and useReply then
					sendData_c = readData_c
				else
					send_data_set(loop)
				end
			end

			if send_data(loop) ~= 0 then break end
		end

		if isClient or useReply then
			if read_data(loop) ~= 0 then break end
			--if readDataIn ~= nil and sendData ~= nil then
				--if tonumber(readDataIn) ~= tonumber(sendData)-1 then io.write(" -- FAIL") end
			--end
		end
	end

	if isClient and useReply then -- after loop answer last call to server
		sendData_c = readData_c
		send_data(loopCount+1)
	end
	print()
	print("*** loopCount total: "..util.format_num(bigloop * loopCount, 0))
	print()
until bigloop >= bigLoops --util.seconds(runtime) >= 60*60*2 -- 5 hours -- 60*60*5
loopCount = bigloop * loopCount

if useProfilier then ProFi:stop() end
local timeUsed = util.seconds(timer)
local msgCount = sentCount + readCount
print()
print(" ..for loop=1, " .. util.format_num( loopCount, 0 ) .. " write+read time: " .. util.format_num( timeUsed, 4 ) .. " sec")
print(" ..sentCount: " .. util.format_num( sentCount, 0 ) .. ", readCount: " .. util.format_num( readCount, 0 )
	.. ", messageCount: " .. util.format_num( msgCount, 0 ))
print(" ..for loop: " .. util.format_num( loopCount/timeUsed, 0 ) .. " loop / sec")
print(" ..for loop: " .. util.format_num( msgCount/timeUsed, 0 ) ..  " msg  / sec")
print(" ..for loop: " .. util.format_num( (timeUsed*1000*1000*1000) / msgCount, 0 )  .. " ns / msg")
print(" ..latency : " .. util.format_num( (timeUsed*1000*1000*1000) / loopCount, 0 ) .. " ns / msg")
print(" ..for loop max message len: " .. sendDataLen)
print(" ..status read wait count  : " .. util.format_num( shm.mmapWaitCount(), 0 ))
argPrint()

print()

local filename
if( isServer ) then
	filename = fileNameC
else
	filename = fileNameS
end
i = shm.mmapInDisconnect(filename)
print(" ..shm.mmapInDisconnect("..filename..") result is: " .. i)

util.sleep(500) -- wait for another to disconnect before shm.mmapOutDestroy()

--i =  shm.mmapOutFlush()
--print(" ..shm.mmapOutFlush() result is: " .. i)

if( isServer ) then
	filename = fileNameS
else
	filename = fileNameC
end
i = shm.mmapOutDestroy(filename)
print(" ..shm.mmapOutDestroy("..filename..") result is: " .. i)

--[[
-- delete client send file too
i = shm.mmapOutCreate(fileNameC , bufferSize)
print(" ..shm.mmapOutCreate(fileNameC , bufferSize) result is: " .. i)
i = shm.mmapOutDestroy(fileNameC)
print(" ..shm.mmapOutDestroy(fileNameC) result is: " .. i)
]]

if useProfilier then
	if isServer then
		ProFi:writeReport("SharedMemReport2Srv.txt")
		os.execute("edit SharedMemReport2Srv.txt")
	else
		ProFi:writeReport("SharedMemReport2Cli.txt")
		os.execute("edit SharedMemReport2Cli.txt")
	end
end
print(" -- AppSharedMemory.lua end -- ")
print()
