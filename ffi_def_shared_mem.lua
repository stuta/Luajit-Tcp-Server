--  ffi_def_shared_mem.lua
dofile "ffi_def_util.lua"
local ffi = require("ffi")
local bit = require("bit")
local C = ffi.C

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


ffi.cdef[[
	
	int 		shm_open(const char *name, int oflag, mode_t mode); // The parameter "mode_t mode" is optional.
	// int 		shm_open(const char *name, int oflag);
	int 		shm_unlink(const char *name);
	int 		ftruncate(int fildes, off_t length);
	void* 	mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset);
	int			close(int fildes);
	int			munmap(void *addr, size_t len);
	int			shm_unlink(const char *name);
  int 		mlock(void*, size_t);
  int 		munlock(void*, size_t);
	int 		mlockall(int);
  int 		munlockall();
  int 		mprotect(void*, size_t, int);
	
	DWORD GetLastError(void);
	
	HANDLE CreateFileA(
		LPCTSTR lpFileName, // 
		DWORD dwDesiredAccess, // 
		DWORD dwShareMode, // 
		LPSECURITY_ATTRIBUTES lpSecurityAttributes, // _In_opt_      
		DWORD dwCreationDisposition, // 
		DWORD dwFlagsAndAttributes, // 
		HANDLE hTemplateFile // _In_opt_    
	);
	
	HANDLE CreateFileMappingA(
	  HANDLE               hFile,
  	SECURITY_ATTRIBUTES* sa,
  	DWORD                protect,
  	DWORD                size_high,
  	DWORD                size_low,
  	LPCSTR               name
	 );
	 
	HANDLE OpenFileMapping(
		DWORD dwDesiredAccess, // _In_  
		BOOL bInheritHandle, // _In_  
		LPCTSTR lpName // _In_  
	);
	
 	/* not in use
 	
	HANDLE CreateFile(
		LPCTSTR lpFileName, // 
		DWORD dwDesiredAccess, // 
		DWORD dwShareMode, // 
		LPSECURITY_ATTRIBUTES lpSecurityAttributes, // _In_opt_      
		DWORD dwCreationDisposition, // 
		DWORD dwFlagsAndAttributes, // 
		HANDLE hTemplateFile // _In_opt_      
	);
	HANDLE CreateFileMapping(
		HANDLE hFile, // _In_
		LPSECURITY_ATTRIBUTES lpAttributes, // _In_opt_
		DWORD flProtect, // _In_
		DWORD dwMaximumSizeHigh, // _In_
		DWORD dwMaximumSizeLow, // _In_
		LPCTSTR lpName // _In_opt_
	);
	HANDLE CreateFileW ( // http://source.winehq.org/WineAPI/CreateFileW.html
		LPCWSTR               filename,
		DWORD                 access,
		DWORD                 sharing,
		LPSECURITY_ATTRIBUTES sa,
		DWORD                 creation,
		DWORD                 attributes,
		HANDLE                template
	 );
	 
	*/
	
	LPVOID MapViewOfFile(
    HANDLE hFileMappingObject, // _In_
    DWORD dwDesiredAccess, // _In_
    DWORD dwFileOffsetHigh, // _In_
    DWORD dwFileOffsetLow, // _In_
    SIZE_T dwNumberOfBytesToMap // _In_
	);
	BOOL UnmapViewOfFile(
    LPCVOID lpBaseAddress // _In_
	);
	BOOL CloseHandle(
  	HANDLE hObject // _In_  
	);
	DWORD GetFileSize(
  	HANDLE hFile, // _In_
  	LPDWORD lpFileSizeHigh // _Out_opt_
	);
	
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
	--Protections are chosen from these bits, or-ed together
	PROT_NONE		= 0x00	-- /* [MC2] no permissions */
	PROT_READ		= 0x01	-- /* [MC2] pages can be read */
	PROT_WRITE	= 0x02	-- /* [MC2] pages can be written */
	PROT_EXEC		= 0x04	-- /* [MC2] pages can be executed */

	--Flags contain sharing type and options.
	--Sharing types; choose one.
	MAP_SHARED	= 0x0001		-- /* [MF|SHM] share changes */
	MAP_PRIVATE	= 0x0002		-- /* [MF|SHM] changes are private */
	
	MAP_FAILED	= ffi.cast("void *", -1) -- ((void *)-1)	-- /* [MF|SHM] mmap failed */
	--print(MAP_FAILED) -> "cdata<void *>: 0xffffffffffffffff"
  
  O_CREAT		= 0x0200		-- /* create if nonexistant */
  O_TRUNC		= 0x0400		-- /* truncate to zero length */
  O_EXCL		= 0x0800		-- /* error if already exists */

	-- open-only flags
  O_RDONLY	= 0x0000		-- /* open for reading only */
  O_WRONLY	= 0x0001		-- /* open for writing only */
  O_RDWR		= 0x0002		-- /* open for reading and writing */
  O_ACCMODE	= 0x0003		-- /* mask for above modes */

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
		local opts = bit.bor(O_CREAT, O_EXCL, O_RDWR)
		shFD = C.shm_open(shmName, opts, 0755) -- ,0600 or ,0755?, optional
		if shFD >= 0 then
				if C.ftruncate(shFD, shmemSize) == 0 then
					sharedMemory = C.mmap(nil, shmemSize, bit.bor(PROT_READ, PROT_WRITE), MAP_SHARED, shFD, 0) 
													 --(nil, shmemSize, (PROT_READ | PROT_WRITE), MAP_SHARED, shFD, 0)
					if sharedMemory ~= MAP_FAILED then
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
