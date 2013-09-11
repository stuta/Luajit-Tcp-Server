--  lib_thread.lua
module(..., package.seeall)

local util = require "lib_util"
local ffi = require "ffi"
local C = ffi.C

-- thread
--[[
https://github.com/hnakamur/luajit-examples/blob/master/pthread/thread1.lua
http://pubs.opengroup.org/onlinepubs/007908799/xsh/pthread.h.html
/System/Library/Frameworks/Kernel.framework/Versions/A/Headers/kern/thread.h
/System/Library/Frameworks/Kernel.framework/Versions/A/Headers/sys/_types.h
/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/usr/include/pthread.h
]]

-- common win+mac
function threadFuncToAddress(thread_entry)
	return tonumber(ffi.cast('intptr_t', ffi.cast('void *(*)(void *)', thread_entry)))
end

-- create a separate Lua state first
-- define a callback function in *that* created state
function luaStateCreate(lua_code, thread_entry_address_name)
	local thread_entry_address = thread_entry_address_name or "thread_entry_address"
	local L = C.luaL_newstate()
	assert(L ~= nil)

	-- http://williamaadams.wordpress.com/2012/04/03/step-by-step-inch-by-inch/
	C.lua_gc(L, C.LUA_GCSTOP, 0) -- stop collector during initialization
	C.luaL_openlibs(L)
	C.lua_gc(L, C.LUA_GCRESTART, -1)

	assert(C.luaL_loadstring(L, lua_code) == 0)
	local res = C.lua_pcall(L, 0, 1, 0) -- runs code
	-- defines functions and variables, we need thread_entry_address -variable
	-- that is the thread_entry() -function memory pointer Lua-number
	assert(res == 0)

	-- get function thread_entry() address from calling thread
	-- http://pgl.yoyo.org/luai/i/lua_call
	C.lua_getfield(L, C.LUA_GLOBALSINDEX, thread_entry_address) 
	-- thread_entry_address = function or (usually) global variable to be called
	local func_ptr = C.lua_tointeger(L, -1); -- lua_getfield value
	C.lua_settop(L, -2); -- set stack to correct (prev call params -1?)
	return L, func_ptr
end

-- Destroys all objects in the given Lua state
-- if Lua state is still running you WILL get crash
function luaStateDelete(luaState)
	C.lua_close(luaState)
end

function threadToIdString(thread)
	local addr = tostring(thread) --ffi.cast('void *', thread[0])
	--local addr = ffi.cast('intptr_t', ffi.cast('void *', thread[0])) -- addr is now int64_t
	return addr 
	
	--if util.isMac then
		--return tonumber(ffi.cast('intptr_t', ffi.cast('void *', thread[0]))) -- is this ok?
	--end
	--return tonumber(thread)
end


if util.isWin then

	local k32 = require "win_kernel32" -- k32 not needed here

	function threadSelf()
		local id = C.GetCurrentThreadId()
		return threadToIdString(id)
	end

	-- then use pthread_create() from the original state, passing the callback address of the other state
	function luaThreadCreate(func_ptr, arg, flags)
		flags = flags or 0
		local thread_c = ffi.new("DWORD[1]")
		local arg_c = ffi.cast("void *", arg) -- necessary if arg is not cstr, should we we check arg type?
		local func_ptr_c = ffi.cast("void *", func_ptr)
		local handle = C.CreateThread(nil, 0, func_ptr_c, arg_c, flags, thread_c)
		assert(handle, " *** ERR: luaThreadCreate() failed.")
		return thread_c
	end

	function threadJoin(thread_id)
		local thread = ffi.cast('void *', thread_id)
		local return_val = C.WaitForSingleObject(thread, C.INFINITE)
		return return_val
	end

	function threadExit(return_val)
		if false then
			print()
			print(" *** ERR: threadExit(return_val) is not supported")
			print()
			local return_ptr = ffi.cast('void *', return_val)
			--ffi.C.pthread_exit(return_ptr)
		end
	end

else
	-- Mac + others
	-- Posix threads

	function threadSelf()
		local id = C.pthread_self()
		--if ffi.os == "OSX" then
		return threadToIdString(id)
		--return tostring(ffi.cast("char *", pid)) --tonumber(ffi.cast("uint32_t", id)) 		--tonumber(pid)
	end

	-- then use pthread_create() from the original state, passing the callback address of the other state
	function luaThreadCreate(func_ptr, arg)
		local thread_c = ffi.new("pthread_t[1]")
		local arg_c = ffi.cast("void *", arg) -- necessary if arg is not cstr, should we we check arg type?
		local res = C.pthread_create(thread_c, nil, ffi.cast("thread_func", func_ptr), arg_c)
		assert(res == 0, " *** ERR: luaThreadCreate() failed.")
		return thread_c[0] -- thread_c,threadToIdString(thread_c)
	end

	function threadJoin(thread_id)
		local return_val = ffi.new("int[1]") -- ffi.cast('intptr_t'
		local return_ptr = ffi.cast('void *', return_val)
		--local thread = ffi.cast('intptr_t', thread_id)
		-- fix this call in Linux
		local res = C.pthread_join(thread_id[0], return_ptr) -- and IN thread C.pthread_exit(100)
		return return_val[0]
	end

	function threadExit(return_val)
		if false then
			print()
			print(" *** ERR: threadExit(return_val) is not supported, in Linux it will cause 'PANIC: unprotected error in call to Lua API (?)'")
			print()
		end
		local return_ptr = ffi.cast('void *', return_val)
		C.pthread_exit(return_ptr)
	end

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

				 The thread ID returned by pthread_self() is not the same thing as the
				 kernel thread ID returned by a call to gettid(2).
	]]
end
