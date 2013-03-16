--  lib_shared_mem.lua

dofile "lib_util.lua"
local ffi = require("ffi")
local bit = require("bit")
local C = ffi.C
--local isWin = isWin
--[[
windows:
http://mollyrocket.com/forums/viewtopic.php?p=2529
http://msdn.microsoft.com/en-us/library/aa366878(v=vs.85).aspx
https://github.com/Wiladams/BanateCoreWin32/blob/master/WTypes.lua
https://github.com/Wiladams/BanateCoreWin32/blob/master/WinBase.lua
http://www.programarts.com/cfree_en/winbase_h.html

osx:
http://stackoverflow.com/questions/10668/reading-other-process-memory-in-os-x-bsd
]]

if isWin then

	-- good (linux, osx, FreeBSD, Solaris):
	--   https://github.com/D-Programming-Language/druntime/blob/master/src/core/sys/posix/sys/mman.d
	-- constants: https://github.com/Wiladams/BanateCoreWin32/blob/master/WinBase.lua
	-- http://www.programarts.com/cfree_en/winbase_h.html

	FILE_MAP_ALL_ACCESS = 0xf001f
	FILE_MAP_READ    		= 4
	FILE_MAP_WRITE   		= 2
	FILE_MAP_COPY    		= 1

	CREATE_ALWAYS 		= 2
	CREATE_NEW 				= 1
	OPEN_ALWAYS 			= 4
	OPEN_EXISTING 		= 3
	TRUNCATE_EXISTING = 5

	GENERIC_READ    = 0x80000000
	GENERIC_WRITE   = 0x40000000
	GENERIC_EXECUTE = 0x20000000
	GENERIC_ALL     = 0x10000000

	FILE_SHARE_READ				= 0x01
	FILE_SHARE_WRITE			= 0x02
	FILE_FLAG_OVERLAPPED 	= 0x40000000

	-- http://www.pinvoke.net/default.aspx/Structures/MEMORY_BASIC_INFORMATION.html
	FILE_ATTRIBUTE_NORMAL = 0x80
	PAGE_READONLY         = 0x02
	PAGE_READWRITE        = 0x04
  PAGE_WRITECOPY        = 0x08

	INVALID_HANDLE_VALUE	= ffi.cast("void *", -1)

  -- globas, create array of these, filename as index
	un = {}
	un.memptr = nil
	un.file = nil
	un.map = nil
	un.filesize = -1

	shmName = nil --"shmfile.txt"

	-- map 'filename' and return a pointer to it. fill out *length and *un if not-nil
	-- example: http://msdn.microsoft.com/en-us/library/windows/desktop/aa366551(v=vs.85).aspx
	function sharedMemorySize()
		return un.filesize
	end

	function sharedMemoryCreate(filename, size)
		shmName = cstr(filename)
		local openOpts  = bit.bor(GENERIC_READ, GENERIC_WRITE)
		local shareOpts = bit.bor(FILE_SHARE_READ, FILE_SHARE_WRITE)
		local hFile = C.CreateFileA(shmName, openOpts, shareOpts, nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, nil);
		if hFile == INVALID_HANDLE_VALUE then
			print("C.CreateFileA() failed: "..GetLastError())
			return nil
		end

		local hMapFile = C.CreateFileMappingA(hFile, nil, PAGE_READWRITE, 0, size, nil)
		if hMapFile == nil then
			print("C.CreateFileMappingA() failed"..GetLastError())
			C.CloseHandle(hFile)
			return nil
		end
		local pMem = C.MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, 0) -- , 0, 0, size)

		--(hMapFile, FILE_MAP_READ, 0,0,0)
		if pMem == nil then
			print("C.MapViewOfFile() failed"..GetLastError())
			C.CloseHandle(hMapFile)
			C.CloseHandle(hFile)
			return nil
	 	end

		local filesize = C.GetFileSize(hFile, nil) -- where used?
		un.memptr = pMem
		un.file = hFile
		un.map = hMapFile
		un.filesize = filesize

		return pMem
	end

	function sharedMemoryDelete(filename)
		-- later: find filename from array and use it's values
		-- if filename ~= shmName then
		-- 	error("filename ~= shmName (sharedMemoryDelete)")
		-- 	return
		-- end
		if un.map then
			C.UnmapViewOfFile(un.map)
		 	C.CloseHandle(un.memptr)
		 	C.CloseHandle(un.file)
		else
			error("un.map == nil (sharedMemoryDelete)")
		end
	end

else
  -- OSX, Posix, Linux?
  	--/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/usr/include/sys/mman.h

	--MAP_FAILED	= ffi.cast("void *", -1) -- ((void *)-1)	-- /* [MF|SHM] mmap failed */
	--print(MAP_FAILED) -> "cdata<void *>: 0xffffffffffffffff"

  -- Lua globals
  shmemSize = 4096
	sharedMemory = nil
	shFD = -10
	shmName = nil

	-- http://stackoverflow.com/questions/10668/reading-other-process-memory-in-os-x-bsd
	local function shared_memory_clear(doPrint)
		if sharedMemory then
			if doPrint then print("sharedMemory already existed (sharedMemoryCreate) ", sharedMemory) end
			C.munmap(sharedMemory, shmemSize)
		end
		if shFD >= 0 then
			if doPrint then print("shFD was already >= 0 (sharedMemoryCreate)", shFD) end
			C.close(shFD)
		end
		if shmName then
			if doPrint then print("shmName already existed (sharedMemoryCreate)", shmName) end
			C.shm_unlink(shmName) -- can not start again if shm_unlink has not been done
		end
		sharedMemory = nil
	end

	-- Tear down shared memory
	function sharedMemoryDelete(filename)
		if shmName and ffi.string(shmName) ~= filename then
			print("shmName ~= filename (sharedMemoryDelete)")
			C.shm_unlink(shmName) -- unlink old name
		end
		shmName = cstr(filename)
		if not sharedMemory then
			print("sharedMemory == nil (sharedMemoryDelete)")
		else
			C.munmap(sharedMemory, shmemSize)
		end
		if shFD < 0 then
			print("shFD < 1 (sharedMemoryDelete)", shFD)
		else
			C.close(shFD)
		end
		C.shm_unlink(shmName) -- can not start again if shm_unlink has not been done
	end

	function sharedMemoryCreate(filename, size)
		shared_memory_clear(true) -- not a very good idea?

		shmName = cstr(filename)
		if size and size > 0 then -- 0 = default smallest size
			shmemSize = size
		end
		local opts = bit.bor(C.O_CREAT, C.O_EXCL, C.O_RDWR)
		shFD = C.shm_open(shmName, opts, 0755) -- ,0600 or ,0755?, optional
		if shFD >= 0 then
				if C.ftruncate(shFD, shmemSize) == 0 then
					sharedMemory = C.mmap(nil, shmemSize, bit.bor(C.PROT_READ, C.PROT_WRITE), C.MAP_SHARED, shFD, 0)
					if sharedMemory ~= C.MAP_FAILED then
						-- print("sharedMemory OK: " .. filename)
						-- Initialize shared memory if needed
						-- Send 'shmemSize' & 'shmemSize' to other process(es)
						ffi.fill(sharedMemory, shmemSize , 0)
					else
						print("sharedMemory == MAP_FAILED: FAILED")
						shared_memory_clear(false)
						return sharedMemory
					end
				else
					print("ftruncate(shFD, shmemSize) ~= 0: FAILED")
					shared_memory_clear(false)
					return sharedMemory
				end
				C.close(shFD)		-- Note: sharedMemory still valid until munmap() called
		else
			print("shFD < 0: FAILED, shFD = "..shFD)
			shared_memory_clear(false)
			return sharedMemory
		end
		return sharedMemory
	end


end
