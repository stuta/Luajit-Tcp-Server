--  TestSignal.lua
print()
print("-- TestSignal.lua start -- ")
print()

dofile "lib_signal.lua"
local arg = {...}
local ffi = require("ffi")
local C = ffi.C

local prsToSignal = tonumber(arg[1]) or 0
local signalSendCount = tonumber(arg[2]) or 1000
local useProfilier = arg[3] == "p"
local kill = arg[3] == "k"

local ProFi
if useProfilier then
	ProFi = require 'ProFi' -- https://gist.github.com/perky/2838755
	ProFi:setGetTimeMethod( seconds )
end

-- http://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/man2/kevent.2.html
-- http://mikeash.com/pyblog/friday-qa-2011-04-01-signal-handling.html
-- /System/Library/Frameworks/Kernel.framework/Versions/A/Headers/sys/event.h
-- https://bitbucket.org/armatys/perun/src/8fbf90836865/lua/perun/init.lua
--[[
http://pubs.opengroup.org/onlinepubs/000095399/functions/sigwait.html
http://stackoverflow.com/questions/2963283/sigwait-in-linux-fedora-13-vs-os-x
]]


local pid = processId()
print("pid : "..pid)

if kill then
	print("killing process : "..prsToSignal)
	signalSend(prsToSignal, SIGQUIT) -- try easy
	sleep(100)
	signalSend(prsToSignal, SIGKILL) -- force kill after wait
	os.exit()
end

-- main test loop
timer = seconds()
if useProfilier then ProFi:start() end
if prsToSignal == 0 then
	--signalHandlerSet(set, SIGUSR1)
	local sig,set = signalHandlerSet(0) -- 0 = wait for all signals or ctrl-c will not work
	print("signal repeat start")
	local i = 0
	io.write("signalHandlerSet() start: ".. i+1 .."\n") -- io.write is jitted, print() isn't
	repeat
		i = i + 1
    signalWait(set, sig)
    if sig[0] == SIGUSR1 then
    	if i < 10 or i % 5000 == 0 then
				io.write(format_num(i, 0)..". *** Got SIGUSR1 ***\n") -- io.write is jitted, print() isn't
			end
		else
			io.write(" *** Got unexpected signal: "..sig[0]..". "..signalName(sig[0]).." ***\n")
    	io.flush()
			break
    end
	until false
	print("signal repeat after")
	signalSend(pid, SIGUSR1) -- will cause 'own' signalCatch() to run
	print("signal end")
else
	for i=1,signalSendCount do
		if i % (signalSendCount/5) == 0 or i <= 2 or i > signalSendCount - 2 then
			io.write("signalSend(prsToSignal, SIGUSR1) start: "..format_num(i, 0).."\n")
			io.flush()
		end
		signalSend(prsToSignal, SIGUSR1)
		yield() --yield() --nanosleep(200) --	sleep(0)
	end
end

local timeUsed = seconds(timer)
if useProfilier then ProFi:stop() end

print()
print(" ..for loop=1, " .. format_num( signalSendCount, 0 ) .. " time: " .. format_num(timeUsed, 6) .. " sec")
print(" ..for loop: " .. format_num( signalSendCount/timeUsed, 0 ) .. " loop / sec")
print(" ..latency : " .. format_num( (timeUsed*1000*1000*1000) / signalSendCount, 0 ) .. " ns / msg")

if useProfilier then
	ProFi:writeReport("TestSignalReport.txt")
	os.execute("edit TestSignalReport.txt") -- edit needs win version
end

print()
print("-- TestSignal.lua end -- ")
print()
