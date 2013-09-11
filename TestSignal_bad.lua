--  TestSignal_bad.lua

--[[
	NOTE!
	- this code crashes after few thousand signals because of re-entrant problems in signalHandler()
	- http://mikeash.com/pyblog/friday-qa-2011-04-01-signal-handling.html
]]

print()
print(" -- TestSignal_bad.lua start -- ")
print()

local arg = {...}
local util = require "lib_util"
local sig = require "lib_signal"
local ffi = require "ffi"
local C = ffi.C

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
	sig.signalHandlerSet(SIGUSR1, signalHandler)
	local i = 0
	repeat
		i = i + 1
		print("signalHandlerSet() start: "..i)
		--print("signalPause()")
		sig.signalPause()
	until false
	print("signal repeat after")
	C.kill(pid, SIGUSR1) -- will cause signalCatch() to run
	print("signal end")
else
	for i=1,signalSendCount do
		print("signalSend(prsToSignal, SIGUSR1) start: "..i)
		sig.signalSend(prsToSignal, SIGUSR1)
		util.yield() --nanosleep(0, 1) --	sleep(0)
	end
	--C.kill(prsToSignal, SIGINT)
end

print()
print(" -- TestSignal_bad.lua end -- ")
print()

