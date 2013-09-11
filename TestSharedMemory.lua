--  TestSharedMemory.lua

print()
print(" -- TestSharedMemory.lua start -- ")
print()

local arg = {...}
local util = require "lib_util"
local smem = require "lib_shared_memory"
local ffi = require "ffi"
local C = ffi.C

local isClient = arg[1]=="c" or false
local filename
if util.isWin then
	filename = "TestSharedMemory.txt" -- "C:\\\\TestSharedMemory.txt"
else
	filename = "TestSharedMemory.txt"
	--/Users/pasi/svnroot/cpp/MA_Lua/github_repos/Luajit-Tcp-Server/shmfile.txt
end
local size = 4096

--sharedMemoryDelete(filename) -- delete prev if open
local shm = smem.sharedMemoryCreate(filename, size)
if not shm then
	print(" -- sharedMemoryCreate() == nil, FAILED")
else
	-- read and write
	local str = "***SharedMemory read/write OK!***"
	local strlen = #str + 1
	local str_c = util.cstr(str)
	local buffer,buffer_ptr = util.createBuffer(64) --ffi.new("char *[?]", strlen*2)
	print(shm, buffer, buffer_ptr)
	local shm_ptr = util.getOffsetPointer(shm, 0) --getPointer(shm)
	ffi.copy(shm_ptr, str_c, strlen) -- copy text to shared memory
	print(" -- 0 + 0 send: "..ffi.string(shm)) -- print shared memory

	buffer_ptr = util.getOffsetPointer(buffer, 0)
	ffi.copy(buffer_ptr, shm_ptr, strlen) -- copy from shared memory to buffer
	print(" -- 0 + 0 rcev: "..ffi.string(buffer_ptr)) -- print buffer


	shm_ptr = util.getOffsetPointer(shm, 6)
	ffi.copy(shm_ptr, str_c, strlen)
	print(" -- 0 + 6 send: "..ffi.string(shm))

	shm_ptr = util.getOffsetPointer(shm, 0)
	buffer_ptr = util.getOffsetPointer(buffer, 0)
	ffi.copy(buffer_ptr, shm_ptr, strlen)
	print(" -- 0 + 0 rcev: "..ffi.string(buffer_ptr))


	shm_ptr = util.getOffsetPointer(shm, 12)
	buffer_ptr = util.getOffsetPointer(buffer, 4)
	ffi.copy(buffer_ptr, shm_ptr, strlen)
	buffer_ptr = util.getOffsetPointer(buffer, 0)
	print(" -- 12+ 4 rcev: "..ffi.string(buffer_ptr))

	shm_ptr = util.getOffsetPointer(shm, 0)
	shm_ptr[0] = string.byte("A")
	print(" -- shm_ptr[0] = string.byte('A'): ", shm_ptr[0], ffi.string(shm))
	shm_ptr[1] = string.byte("@")
	print(" -- shm_ptr[1] = string.byte('@'): ", shm_ptr[0], ffi.string(shm))

	--[[
	local strIn_cp = ffi.cast("char *", strIn_c + 0)
	ffi.copy(strIn_cp, shm_ptr, strlen)
	print(" -- call + 0: "..ffi.string(strIn_cp))
	]]
end

io.write("press any key to delete shared memory area: ")
util.waitKeyPressed()
smem.sharedMemoryDelete(filename)

print()
print(" -- TestSharedMemory.lua end -- ")
print()

