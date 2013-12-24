--  lib_shared_memory.lua
module(..., package.seeall)

local ffi = require("ffi")
local C = ffi.C
local util = require("lib_util")
local bit = require("bit")

local microsleep = util.microsleep
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

local INVALID_HANDLE_VALUE	= ffi.cast("void *", -1)

local function print_error(functionName, str)
	print("### shared mem lua error (" .. functionName .. "): " .. str .. " ###")
end

if util.isWin then

	-- good (linux, osx, FreeBSD, Solaris):
	--   https://github.com/D-Programming-Language/druntime/blob/master/src/core/sys/posix/sys/mman.d
	-- constants: https://github.com/Wiladams/BanateCoreWin32/blob/master/WinBase.lua
	-- http://www.programarts.com/cfree_en/winbase_h.html
	local k32 = require("win_kernel32")

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
	FILE_ATTRIBUTE_READONLY = 0x01
	FILE_FLAG_DELETE_ON_CLOSE = 0x04000000
	PAGE_READONLY         = 0x02
	PAGE_READWRITE        = 0x04
  PAGE_WRITECOPY        = 0x08
  SEC_COMMIT = 0x8000000


  -- globas, create array of these, filename as index
	un = {}
	shmName = {} --"shmfile.txt"

	-- map 'filename' and return a pointer to it. fill out *length and *un if not-nil
	-- example: http://msdn.microsoft.com/en-us/library/windows/desktop/aa366551(v=vs.85).aspx

	function sharedMemorySize(filename)
		return un[filename].filesize
	end


	function sharedMemoryOpen(filename, size, create)
		if size < 65536 then
			size = 65536
		end

		shmName[filename] = util.cstr(filename)
		local shm_global_name = string.gsub(filename, "\\", "_")
		shm_global_name = string.gsub(shm_global_name, "C:_", "") -- "Global\\"
		print(shm_global_name)
		shm_global_name = util.cstr(shm_global_name)

		-- local accessOpts, shareOpts, openOpts, fileOpts
		local protectOpts, fileProtectOpts
		if create then
			-- accessOpts  = bit.bor(GENERIC_WRITE, GENERIC_READ)
			-- shareOpts = bit.bor(FILE_SHARE_WRITE, FILE_SHARE_READ)
			-- openOpts = OPEN_ALWAYS
			-- fileOpts = bit.bor(FILE_ATTRIBUTE_NORMAL, FILE_FLAG_DELETE_ON_CLOSE)
			protectOpts = bit.bor(PAGE_READWRITE) -- SEC_COMMIT needed?
			fileProtectOpts = FILE_MAP_ALL_ACCESS
		else
			-- accessOpts  = bit.bor(GENERIC_READ)
			-- shareOpts = bit.bor(FILE_SHARE_READ)
			-- openOpts = OPEN_EXISTING
			-- fileOpts = FILE_ATTRIBUTE_READONLY
			protectOpts = PAGE_READONLY
			fileProtectOpts = FILE_MAP_READ
		end

		--[[
		local hFile
		if  create then
			hFile = C.CreateFileA(shmName[filename], accessOpts, shareOpts, nil, openOpts, fileOpts, nil);
			if hFile == INVALID_HANDLE_VALUE then
				--if create then
					print("C.CreateFileA() failed, error: "..win_errortext(C.GetLastError()))
				--end
				return nil
			end
		end
		]]

		local hMapFile
		if create then
			hMapFile = C.CreateFileMappingA(INVALID_HANDLE_VALUE, nil, protectOpts, 0, size, shm_global_name)
			--hMapFile = C.CreateFileMappingA(hFile, nil, protectOpts, 0, size, shm_global_name)
			if hMapFile == nil then
				print("C.CreateFileMappingA() failed, error: "..win_errortext(C.GetLastError()))
				--C.CloseHandle(hFile)
				return nil
			end
		else
			hMapFile = C.OpenFileMappingA(fileProtectOpts, 0, shm_global_name)
			if hMapFile == nil then
				print("C.OpenFileMappingA() failed, error: "..win_errortext(C.GetLastError()))
				--C.CloseHandle(hFile)
				return nil
			end
		end

		local pMem = C.MapViewOfFile(hMapFile, fileProtectOpts, 0, 0, 0) -- , 0, 0, size)
		--(hMapFile, FILE_MAP_READ, 0,0,0)
		if pMem == nil then
			print("C.MapViewOfFile() failed, error: "..win_errortext(C.GetLastError()))
			C.CloseHandle(hMapFile)
			--C.CloseHandle(hFile)
			return nil
	 	end

		if create then
			ffi.fill(pMem, size , 0) -- set area to full of zeroes
		end

		--local filesize = C.GetFileSize(hFile, nil) -- where used?
		un[filename] = {}
		un[filename].memptr = pMem
		--un[filename].file = hFile
		un[filename].map = hMapFile
		un[filename].filesize = filesize

		collectgarbage()
		return pMem
	end

	function sharedMemoryDisconnect(filename)
		local ret = 0
		-- later: find filename from array and use it's values
		-- if filename ~= shmName[filename] then
		-- 	print_error("sharedMemoryDisconnect", "filename ~= shmName (sharedMemoryDelete)")
		-- 	return
		-- end
		if un[filename].map then
			C.UnmapViewOfFile(un[filename].map)
		else
			print_error("sharedMemoryDisconnect", "un[filename].map == nil", filename)
			ret = -1
		end
		if un[filename].memptr then
		 	C.CloseHandle(un[filename].memptr)
		else
			print_error("sharedMemoryDisconnect", "un[filename].memptr == nil", filename)
			ret = ret + -2
		end
		--[[
		if un[filename].file then
		 	C.CloseHandle(un[filename].file)
		else
			print_error("sharedMemoryDisconnect", "un[filename].file == nil", filename)
			ret = ret + -4
		end
		]]
		collectgarbage()
		return ret
	end

	function sharedMemoryDelete(filename)
		local ret = sharedMemoryDisconnect(filename)
		--[[print("sharedMemoryDelete", filename)
		-- actual delete of file here
		local del = C.DeleteFileA(util.cstr(filename))
		if del ~= 1 then
			print_error("sharedMemoryDelete", "DeleteFile() failed", filename)
			ret = ret + -8
		end
		]]
		collectgarbage()
		return ret
	end

else
  -- OSX, Posix, Linux?
  	--/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/usr/include/sys/mman.h

	MAP_FAILED	= ffi.cast("void *", -1) -- ((void *)-1)	-- /* [MF|SHM] mmap failed */
	--print(MAP_FAILED) -> "cdata<void *>: 0xffffffffffffffff"

  -- Lua globals
  shmemSize = 4096
	sharedMemory = {}
	shFD = {}
	shmName = {}

	-- http://stackoverflow.com/questions/10668/reading-other-process-memory-in-os-x-bsd
	local function shared_memory_clear(filename, doPrint)
		if sharedMemory[filename] then
			if doPrint then print("sharedMemory already existed (sharedMemoryCreate) ", filename) end
			C.munmap(sharedMemory[filename], shmemSize)
		end
		if shFD[filename] >= 0 then
			if doPrint then print("shFD[filename] was already >= 0 (sharedMemoryCreate)", shFD[filename], filename) end
		end
		if shFD[filename] then
			C.close(shFD[filename])
		end
		if shmName[filename] then
			if doPrint then print("shmName already existed (sharedMemoryCreate)", filename) end
		end
		if shmName[filename] then
			C.shm_unlink(shmName[filename]) -- can not start again if shm_unlink has not been done
		end
		sharedMemory[filename] = nil
		collectgarbage()
	end

	function sharedMemoryDisconnect(filename)
	local ret = 0
		if not sharedMemory[filename] then
			print("sharedMemory[filename] == nil (sharedMemoryDisconnect)", filename)
			ret = -1
		else
			C.munmap(sharedMemory[filename], shmemSize)
			sharedMemory[filename] = nil
		end
		if not shmName[filename] then
			print("shmName[filename] == nil (sharedMemoryDisconnect)", filename)
			ret = -2
		else
			C.shm_unlink(shmName[filename])
		end
		shmName[filename] = nil
		collectgarbage()
		return ret
	end

	-- Tear down shared memory
	function sharedMemoryDelete(filename)
		local ret = 0
		print("sharedMemoryDelete(): ",filename)
		if not sharedMemory[filename] then
			print("sharedMemory[filename] == nil (sharedMemoryDelete)", filename)
			ret = -1
		else
			C.munmap(sharedMemory[filename], shmemSize)
			sharedMemory[filename] = nil
		end
		if not shFD[filename] then
			print("shFD[filename] < 1 (sharedMemoryDelete)", filename)
			ret = -2
		else
			C.close(shFD[filename])
			shFD[filename] = nil
		end
		filename = util.cstr(filename)
		C.shm_unlink(filename) -- can not start again if shm_unlink has not been done
		shmName[filename] = nil
		collectgarbage()
		return ret
	end

	function sharedMemoryOpen(filename, size, create)
		shmName[filename] = util.cstr(filename)
		-- shared_memory_clear(filename, true) -- not a very good idea?

		local shm_options, mmap_options, mmap_flags, shm_mode, ret
		mmap_flags = C.MAP_SHARED --bit.bor(C.MAP_ANON, C.MAP_SHARED)
		if create then
			shm_options = bit.bor(C.O_RDWR, C.O_CREAT, C.O_EXCL) -- , C.O_EXCL
		 	mmap_options = bit.bor(C.PROT_WRITE)
		 	shm_mode = 755 -- 0600, 777?
		else
		 	shm_options = bit.bor(C.O_RDONLY)
		 	mmap_options = bit.bor(C.PROT_READ)
		 	shm_mode = 755 -- 755
		end

		if size and size > 0 then -- 0 = default smallest size
			shmemSize = size
		end

		shFD[filename] = C.shm_open(shmName[filename], shm_options, shm_mode) -- ,0600 or ,0755?
		if shFD[filename] >= 0 then
				if create then
					ret = C.ftruncate(shFD[filename], shmemSize)
				else
					ret = 0
				end
				if ret == 0 then
					--print("mmap_flags", mmap_flags)
					sharedMemory[filename] = C.mmap(nil, shmemSize, mmap_options, mmap_flags, shFD[filename], 0)
					--sharedMemory[filename] = C.mmap(nil, shmemSize, mmap_options, mmap_flags, -1, 0)
					if sharedMemory[filename] ~= MAP_FAILED then

						--[[if create then -- Linux options so that we don't need to run as root
							perms = ffi.new("struct ipc_perm")
							perms.uid = 100
							perms.gid = 200
							perms.mode = 755 -- 0660 = Allow read/write only by uid '100' or members of group '200'
							C.shmctl(shmid, C.IPC_SET, perms);
						end	]]

						-- print("sharedMemory OK: " .. filename)
						-- Initialize shared memory if needed
						-- Send 'shmemSize' & 'shmemSize' to other process(es)
						if create then
							ffi.fill(sharedMemory[filename], shmemSize , 0) -- set area to full of zeroes
						end
					else
						print("sharedMemory: mmap failed")
						shared_memory_clear(filename, false)
						return sharedMemory[filename]
					end
				else
					print("sharedMemory: ftruncate(shFD[filename], shmemSize) == "..ret.." : FAILED")
					shared_memory_clear(filename, false)
					return sharedMemory[filename]
				end
				C.close(shFD[filename])		-- Note: sharedMemory still valid until munmap() called
		else
			if create then
				print("shFD[filename] < 0: FAILED, shFD[filename] = "..shFD[filename], filename)
				shared_memory_clear(filename, false)
			end
			return sharedMemory[filename]
		end
		collectgarbage()
		return sharedMemory[filename]
	end

end

function sharedMemoryCreate(filename, size)
	print("\tsharedMemoryCreate(): ",filename, size)
	return sharedMemoryOpen(filename, size, true)
end

function sharedMemoryConnect(filename, size)
	print("\tsharedMemoryConnect(): ",filename, size)
	return sharedMemoryOpen(filename, size, false)
end


-- helper funcs

local yield = util.yield

local append = -1 -- mf.append
local inPos = 0
local outPos = 0
	--[[
	http://www.freelists.org/post/luajit/How-to-create-another-lua-State-in-pthread,4
	The canonical way to convert a cdata pointer to a Lua number is:
    tonumber(ffi.cast('intptr_t', ffi.cast('void *', ptr)))
	This returns a signed result, which is cheaper to handle and turns
	into a no-op, when JIT-compiled. If you really need an unsigned
	address (and not just an abstract identifier), then use uintptr_t.
	]]
local inAddress_c --= ffi.new("unsigned int[1]") --ffi.new("unsigned int[1]") -- uintptr_t = unsigned int? yes in osx64
local outAddress_c --= ffi.new("unsigned int[1]")
local waitCount = 0 -- global

local statusLen = 1 -- uint8_t -- how namy bits (not bytes)
local statusType = "int"..(statusLen*8).."_t" -- int8_t
local statusTypePtr = statusType.." *"

local inPtrStatus, inPtrData, outPtrStatus, outPtrData  --, inPtrStatus[0], outPtrStatus[0] -- set in mmapAddressSet()
local inSize, outSize, outMaxSize


function mmapInStatus()
	return inPtrStatus[0]
end

function mmapOutStatus()
	return outPtrStatus[0]
end

function mmapWaitCount()
	return waitCount
end

function mmapInDisconnect(filename)
	return sharedMemoryDisconnect(filename)
end

function mmapOutDestroy(filename)
	return sharedMemoryDelete(filename)
end

function mmapAddressSet(doPrint)

	outPtrStatus = util.getOffsetPointer(outAddress_c, 0)
	outPtrData = util.getOffsetPointer(outAddress_c, statusLen)
	inPtrStatus = util.getOffsetPointer(inAddress_c, 0)
	inPtrData = util.getOffsetPointer(inAddress_c, statusLen)
	if doPrint then
		print()
		print("statusLen   : ", statusLen)

		print("outBuffer   : ", outSize)
		print("outAddress_c: ", outAddress_c)
		print("outPtrStatus: ", outPtrStatus)
		print("outPtrData  : ", outPtrData)
		print("outPtrStatus[0] : ", outPtrStatus[0])

		print("inBuffer    : ", inSize)
		print("inAddress_c : ", inAddress_c)
		print("inPtrStatus : ", inPtrStatus)
		print("inPtrData   : ", inPtrData)
		print("inPtrStatus[0]  : ", inPtrStatus[0])

		print()
	end
end

function mmapInConnect(filename, bufferSize)
	inSize =  bufferSize
	inFilename = filename
	inAddress_c = sharedMemoryConnect(inFilename, inSize)
	if not inAddress_c or inAddress_c == INVALID_HANDLE_VALUE then
		-- print_error("mmapInConnect", " -- inAddress_c = sharedMemoryCreate() == nil, FAILED")
		inSize = 0
	end
	return inSize -- fix to real buffer size
end

function mmapOutCreate(filename, bufferSize)
  outSize =  bufferSize
	outMaxSize = outSize - statusLen
	outFilename = filename
	outAddress_c = sharedMemoryCreate(outFilename, outSize)
	if not outAddress_c or outAddress_c == INVALID_HANDLE_VALUE then
		print_error("mmapOutCreate", " -- outAddress_c = sharedMemoryCreate() == nil, FAILED")
		--os.exit()
		bufferSize = 0
	end

	return bufferSize -- fix to real buffer size
end

local coroutine_yield = coroutine.yield
function mmapStatusInWaitCoro(waitForStatus)
	local us = microsec or 0
	-- pleaso DO NOT TOUCH this function unless you can prove you can do better, this has been tested many times
	while inPtrStatus[0] ~= waitForStatus do
		waitCount = waitCount + 1
		yield()
		coroutine_yield()
	end
end

function mmapStatusInWait(waitForStatus)
	local us = microsec or 0
	-- pleaso DO NOT TOUCH this function unless you can prove you can do better, this has been tested many times
	while inPtrStatus[0] ~= waitForStatus do
		waitCount = waitCount + 1
		yield()
	end
end


function mmapStatusInWaitNotCoro(waitForStatus)
	local us = microsec or 0
	-- pleaso DO NOT TOUCH this function unless you can prove you can do better, this has been tested many times
	while inPtrStatus[0] == waitForStatus do
		waitCount = waitCount + 1
		yield()
		coroutine_yield()
	end
end

function mmapStatusInWaitNot(waitForStatus)
	local us = microsec or 0
	-- pleaso DO NOT TOUCH this function unless you can prove you can do better, this has been tested many times
	while inPtrStatus[0] == waitForStatus do
		waitCount = waitCount + 1
		yield()
	end
end

function mmapStatusOutSet(stat)
	--ma.ReadWriteMemoryBarrier()
	outPtrStatus[0] = stat
end

function mmapOutWrite(status, pos, data, dataLen)
	-- lua ffi version
	--[[if( not outAddress_c ) then
		print_error( "mmapOutWrite", "outAddress_c is NULL" )
		return -1
	end]]

	if ( dataLen < 1 )  then
		--dataLen = (int32_t)strlen( (char *)data ) -- int32_t = -214783648 to 2,147,483,647
		print("data len cast 1: " .. dataLen)
		dataLen = C.strlen(data) --ffi.cast("int32_t",C.strlen(data)) -- 64 -> 32?
		print("data len cast 2: " .. dataLen)
		io.flush()
	end
	if( dataLen < 1 ) then
		print_error( "mmapOutWrite", "data length < 1" )
		return -4
	end

	if( pos > append ) then  -- append = -1
		if( pos > ( outMaxSize - 1 ) ) then
			print_error( "mmapOutWrite", string.format("out position is bigger than buffer size-1: %d > %d", pos, outMaxSize) )
			return -2
		end
		-- outPos = outFileBuf->pubseekoff( 0, ios_base::cur ) -- get current out pos
		if( ( pos + dataLen ) > outMaxSize ) then
			print_error( "mmapOutWrite", string.format("out position + data length > buffer size: %d + %d > %d", pos, dataLen, outMaxSize) )
			return -3 -- must test and return before setting new outPos for next call
		end
		outPos = pos --outFileBuf->pubseekpos( pos )
	else
		if( ( outPos + dataLen ) > outMaxSize ) then
			print_error( "mmapOutWrite", string.format("out position + data length > buffer size: %d + %d > %d", outPos, dataLen, outMaxSize) )
			return -3 -- same as before, this is ok
		end
	end


	--char* writePtr = (char *)outAddress_c; // nicer to debug char*
	--char* writeDataPtr = writePtr + outPos + statusLen;
	--memcpy( writeDataPtr, data, dataLen );
	--memcpy( writePtr, &status, statusLen );
	-- void * memcpy ( void * destination, const void * source, size_t num ); -> destination is returned.
	if outPos == 0 then
		ffi.copy(outPtrData, data, dataLen)
	else
		local outPtrDataTmp = ffi.cast("uintptr_t *", outAddress_c + statusLen + outPos)
		ffi.copy(outPtrDataTmp, data, dataLen)
	end
	mmapStatusOutSet(status)
	outPos = outPos + dataLen -- outPos += outFileBuf->sputn( data, dataLen )

	return 0 --outPtrStatus[0][0] --dataLen
end

function mmapInRead(status, pos, data, dataLen)
	if( dataLen < 0 ) then
		print_error( "mmapInRead", "read data length < 0" )
		return -2
	end

	local inMaxSize = inSize - statusLen
	if( pos > append ) then  -- append = -1
		if( pos > ( inMaxSize-1 ) ) then
			print_error( "mmapInRead", string.format("in position is bigger than buffer size-1: %d > %d", pos, inMaxSize) )
			return -3
		end
		inPos = pos
	end

	-- inPos = inAddress_c->pubseekoff( 0, ios_base::cur ) -- get current in pos
	if( inPos > inMaxSize ) then
		print_error( "mmapInRead", string.format("read position > buffer size: %d > %d", inPos, inMaxSize) )
		return -4
	end

	if( ( inPos + dataLen ) > inMaxSize ) then
		print_error( "mmapInRead", string.format("read position + read length > buffer size: %d + %d > %d", inPos, dataLen, inMaxSize) )
		return -5
		-- OR use: dataLen = inSize - inPos
	end

	if inPos == 0 then
		ffi.copy(data, inPtrData, dataLen)
	else
		local inPtrDataTmp = ffi.cast("uintptr_t *", outAddress_c + inPos + statusLen)
		ffi.copy(data, inPtrDataTmp, dataLen) --memcpy( data, readPtr, dataLen )
	end
	mmapStatusOutSet(status)

	inPos = inPos + dataLen -- outPos += outFileBuf->sputn( data, dataLen )

	return 0 -- 0=all ok
end
