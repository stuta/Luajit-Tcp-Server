--  SignalTest_bad.lua

--[[
	NOTE!
	- this code crashes after few thousand signals because of re-entrant problems in signalHandler()
	- see: 
]]

print()
print(" -- SignalTest_bad.lua start -- ")
print()

local arg = {...}
local ffi = require("ffi")
local C = ffi.C
dofile "ffi_def_signal.lua"

local signalCatchCount = 0
local prsToSignal = tonumber(arg[1]) or 0
local signalSendCount = tonumber(arg[2]) or 1000

local pid = C.getpid()
print("pid : "..pid)

local function signalHandler()
	signalCatchCount = signalCatchCount + 1
	print("signalHandler(): "..signalCatchCount)
end

local function signalHandlerSet(signal, signalHandlerFunc)
	C.signal(signal, signalHandlerFunc)
end

local function signalSend(prsToSignal, signal)
	C.kill(prsToSignal, signal)
end

local function signalPause()
	C.pause()
end

if prsToSignal == 0 then
	print("signal repeat start")
	signalHandlerSet(SIGUSR1, signalHandler)
	local i = 0
	repeat
		i = i + 1
		print("signalHandlerSet() start: "..i)
		--print("signalPause()")
		signalPause()
	until false
	print("signal repeat after")
	C.kill(pid, SIGUSR1) -- will cause signalCatch() to run
	print("signal end")
else
	for i=1,signalSendCount do
		print("signalSend(prsToSignal, SIGUSR1) start: "..i)
		signalSend(prsToSignal, SIGUSR1)
		yield() --nanosleep(1) --	sleep(0)
	end 
	--C.kill(prsToSignal, SIGINT)
end

print()
print(" -- SignalTest_bad.lua end -- ")
print()

