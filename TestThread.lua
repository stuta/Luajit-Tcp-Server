--  TestThread.lua
print()
print(" -- TestThread.lua start -- ")
print()


local arg = {...}
local util = require "lib_util"
local thread = require "lib_thread"

local ffi = require("ffi")
local C = ffi.C

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

local thread_id = thread.threadSelf()
print("Main thread_id: "..thread_id..", os: "..ffi.os)

-- http://www.freelists.org/post/luajit/How-to-create-another-lua-State-in-pthread,1
-- https://github.com/hnakamur/luajit-examples/blob/master/pthread/thread1.lua

-- define thread runner code, it MUST contain "thread_entry_address" -global variable
luaCode = [[
	local util = require "lib_util" 
	local thread = require "lib_thread" 
	local ffi = require "ffi" 

	local function thread_entry(arg_ptr)
		-- local arg = tonumber(ffi.cast('intptr_t', ffi.cast('void *', arg_ptr))) -- if arg is number
		local arg = ffi.string(arg_ptr) -- if arg is cstr
		local thread_id = thread.threadSelf()
		print(" ... Hello from another Lua state, arg: "..arg..", thread_id: "..thread_id)

		local ms
		math.randomseed( util.microSeconds() )
		if arg == "Argument for threadA" then
			ms = math.random(1, 400)
		else
			ms = math.random(0, 150)
		end
		print(" ... sleep milliseconds: "..ms..", arg: "..arg)
		util.sleep(math.random(1, ms)) --sleep(100) --yield() --nanosleep(0, 20)
		
		print(" ... Quit Lua state, arg: "..arg..", thread_id: "..thread_id)
		if not util.isLinux then
			-- ??thread.threadExit() not supported in linux will cause
			-- 'PANIC: unprotected error in call to Lua API (?)'
			if arg == "Argument for threadA" then
				thread.threadExit(51)
			else
				thread.threadExit(12)
			end
		end
		-- it is better to let Lua state do it's dying in it's own phase
		-- if you need return value then use some other method (shared mem/variable?)
	end

	thread_entry_address = thread.threadFuncToAddress(thread_entry)
	-- threadFuncToAddress() returns thread_entry-function address as Lua number
	-- thread_entry func can be named as you please, but "thread_entry_address" global
	-- variable must exist (or set as parameter 2 to luaStateCreate() -function)

]]

-- create a separate Lua state first
-- define a callback function in *that* created state
local luaStateA,func_ptrA = thread.luaStateCreate(luaCode, nil)
-- then use pthread_create() from the original state, passing the callback address of the other state
local threadA = thread.luaThreadCreate(func_ptrA, util.cstr("Argument for threadA"))
local threadAId = thread.threadToIdString(threadA)
print("threadA: "..threadAId..", funcPtr: "..tostring(func_ptr))

util.sleep(1)
print()
local luaStateB,func_ptrB = thread.luaStateCreate(luaCode, nil)
local threadB = thread.luaThreadCreate(func_ptrB, util.cstr("Argument for threadB"))
local threadBId = thread.threadToIdString(threadB)
print("threadB: "..threadBId.." funcPtr: "..tostring(func_ptr))

if false then
	local ret = thread.threadJoin(threadB) -- and IN thread thread.threadExit(12)
	print("threadJoin(threadB): "..ret)

	ret = thread.threadJoin(threadA) -- and IN thread thread.threadExit(51)
	print("threadJoin(threadA): "..ret)
end

util.sleep(400)
print("thread.luaStateDelete() - start")
-- we MUST call either threadJoin() or do something (sleep) before lua_close
-- or we get Segmentation fault: 11
-- in osx sleep(1) is smallest enough in this case because thread_entry func is fast, win needs longer time

thread.luaStateDelete(luaStateA) -- Destroys all objects in the given Lua state
thread.luaStateDelete(luaStateB) -- if Lua state is running you WILL get crash
print("thread.luaStateDelete() - end")


print()
print(" -- TestThread.lua end -- ")
print()

