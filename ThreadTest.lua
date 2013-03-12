--  ThreadTest.lua
print()
print(" -- ThreadTest.lua start -- ")
print()

local arg = {...}
dofile "thread.lua"
local ffi = require("ffi")
local C = ffi.C
--dofile "ffi_def_signal.lua"


--[[
NOTES
       POSIX.1 allows an implementation wide freedom in choosing the type used to
       represent a thread ID; for example, representation using either an
       arithmetic type or a structure is permitted.  Therefore, variables of type
       pthread_t can't portably be compared using the C equality operator (==);
       use pthread_equal(3) instead.

       Thread identifiers should be considered opaque: any attempt to use a thread
       ID other than in pthreads calls is nonportable and can lead to unspecified
       results.

       Thread IDs are only guaranteed to be unique within a process.  A thread ID
       may be reused after a terminated thread has been joined, or a detached
       thread has terminated.

       The thread ID returned by threadSelf() is not the same thing as the
       kernel thread ID returned by a call to gettid(2).
]]

local thread_id = threadSelf()
print("Main thread_id: "..thread_id..", os: "..ffi.os)

-- http://www.freelists.org/post/luajit/How-to-create-another-lua-State-in-pthread,1
-- https://github.com/hnakamur/luajit-examples/blob/master/pthread/thread1.lua

-- define thread runner code, it MUST contain "thread_entry_address" -global variable
luaCode = [[
	dofile "thread.lua"
	local ffi = require("ffi")
	
	local function thread_entry(arg_ptr)
		-- local arg = tonumber(ffi.cast('intptr_t', ffi.cast('void *', arg_ptr))) -- if arg is number
		local arg = ffi.string(arg_ptr) -- if arg is cstr
		local thread_id = threadSelf()
		print("Hello from another Lua state, arg: "..arg..", thread_id: "..thread_id)
		repeat
			sleep(1) --yield() --nanosleep(20)
		until true
		print("Quit Lua state, arg: "..arg..", thread_id: "..thread_id)
		if arg == "Argument for threadA" then
			threadExit(51)
		else
			threadExit(12)
		end
	end
	
	thread_entry_address = threadFuncToAddress(thread_entry) 
	-- threadFuncToAddress() returns thread_entry-function address as Lua number
	-- thread_entry func can be named as you please, but "thread_entry_address" global 
	-- variable must exist (or change also luaStateCreate() -function)
	
]]
	
-- create a separate Lua state first
-- define a callback function in *that* created state
local luaStateA,func_ptr = luaStateCreate(luaCode)
-- then use pthread_create() from the original state, passing the callback address of the other state
local threadA = luaThreadCreate(func_ptr, cstr("Argument for threadA"))
local threadAId = threadToId(threadA)
print("threadA: "..threadAId..", funcPtr: "..tostring(func_ptr))

local luaStateB,func_ptr = luaStateCreate(luaCode)
local threadB = luaThreadCreate(func_ptr, cstr("Argument for threadB"))
local threadBId = threadToId(threadB)
print("threadB: "..threadBId.." funcPtr: "..tostring(func_ptr))

local function signalSend(prsToSignal, signal)
	
end

local function signalWait(signal)
	
end

if false then
if prsToSignal == 0 then
	print("signal wait repeat start")
	signalHandlerSet(SIGUSR1, signalHandler)
	local i = 0
	repeat
		i = i + 1
		print("signalHandlerSet() start: "..i)
		--print("signalPause()")
		signalPause()
	until false
	print("signal repeat after")
	print("signal end")
else
	print("signal send repeat start")
	for i=1,signalSendCount do
		print("signalSend(prsToSignal, SIGUSR1) start: "..i)
		signalSend(prsToSignal, SIGUSR1)
		yield() --nanosleep(1) --	sleep(0)
	end 
	--C.kill(prsToSignal, SIGINT)
end
end


-- we MUST call either threadJoin() or do something (sleep) before lua_close 
-- or we get Segmentation fault: 11
-- sleep(1) is smallest enough in this case because thread_entry func is fast

--local ret = threadJoin(threadB) -- and IN thread threadExit(12)
--print("threadJoin(threadB): "..ret)

--local ret = threadJoin(threadA) -- and IN thread threadExit(51)
--print("threadJoin(threadA): "..ret)

print("luaStateDelete() - start")
sleep(10)
luaStateDelete(luaStateA) -- Destroys all objects in the given Lua state
luaStateDelete(luaStateB) -- if Lua state is running you WILL get crash
print("luaStateDelete() - end")

print()
print(" -- ThreadTest.lua end -- ")
print()

