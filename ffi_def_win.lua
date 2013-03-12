--  ffi_def_win.lua
local ffi = require "ffi"
local bit = require "bit"

-- local bnot = bit.bnot
-- local band = bit.band
local bor = bit.bor
local lshift = bit.lshift
-- local rshift = bit.rshif

--[[
https://github.com/Wiladams/BanateCoreWin32
https://github.com/Wiladams/LJIT2Win32/blob/master/WinBase.lua
]]

-- Berkeley Sockets calls
-- https://github.com/Wiladams/LJIT2Win32/blob/master/win_socket.lua
dofile "win_socket.lua"

ffi.cdef[[
	// Windows
	// win basic structures and defines
	static const DWORD STD_INPUT_HANDLE = -10; 	//#define STD_INPUT_HANDLE    (DWORD)-10
	static const DWORD STD_OUTPUT_HANDLE = -11;	// #define STD_OUTPUT_HANDLE   (DWORD)-11
	static const DWORD STD_ERROR_HANDLE = -12;	// #define STD_ERROR_HANDLE    (DWORD)-12

	static const int ENABLE_LINE_INPUT = 0x0002;	// #define ENABLE_LINE_INPUT       0x0002
	static const int ENABLE_ECHO_INPUT = 0x0004;	// #define ENABLE_ECHO_INPUT       0x0004

]]

ffi.cdef[[
	// Windows
	// win basic functions

	BOOL QueryPerformanceFrequency( // BOOL WINAPI QueryPerformanceFrequency
  	LARGE_INTEGER *lpFrequency // _Out_  LARGE_INTEGER *lpFrequency
	);
	BOOL QueryPerformanceCounter( // BOOL WINAPI QueryPerformanceCounter
  	LARGE_INTEGER *lpPerformanceCount // _Out_  LARGE_INTEGER *lpPerformanceCount
	);
	int MultiByteToWideChar(UINT CodePage,
			DWORD    dwFlags,
			LPCSTR   lpMultiByteStr, int cbMultiByte,
			LPWSTR  lpWideCharStr, int cchWideChar);
	int WideCharToMultiByte(UINT CodePage,
			DWORD    dwFlags,
			LPCWSTR  lpWideCharStr, int cchWideChar,
			LPSTR   lpMultiByteStr, int cbMultiByte,
			LPCSTR   lpDefaultChar,
			LPBOOL  lpUsedDefaultChar);
	HANDLE GetStdHandle(
    DWORD nStdHandle // _In_
	);
	BOOL GetConsoleMode(
    HANDLE hConsoleHandle, // _In_
    LPDWORD lpMode // _Out_
	);
	BOOL SetConsoleMode(
		HANDLE hConsoleHandle, // _In_
		DWORD dwMode // _In_
	);
	BOOL ReadConsoleA(
		HANDLE hConsoleInput, // _In_
		LPVOID lpBuffer, // _Out_
		DWORD nNumberOfCharsToRead, // _In_
		LPDWORD lpNumberOfCharsRead, // _Out_
		LPVOID pInputControl // _In_opt_
	);
	void 	Sleep(int ms); // win sleep
	bool  SwitchToThread(void); // win yield
	DWORD GetLastError(void);
]]

-- shared_mem.lua
ffi.cdef[[
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

--  thread.lua
ffi.cdef[[
	// Windows
	// https://github.com/Wiladams/BanateCoreWin32/blob/master/win_kernel32.lua
	HMODULE GetModuleHandleA(LPCSTR lpModuleName);
	BOOL CloseHandle(HANDLE hObject);
	HANDLE CreateEventA(LPSECURITY_ATTRIBUTES lpEventAttributes,
			BOOL bManualReset, BOOL bInitialState, LPCSTR lpName);
	HANDLE CreateIoCompletionPort(HANDLE FileHandle,
		HANDLE ExistingCompletionPort,
		ULONG_PTR CompletionKey,
		DWORD NumberOfConcurrentThreads);
	HANDLE CreateThread(
		LPSECURITY_ATTRIBUTES lpThreadAttributes,
		size_t dwStackSize,
		LPTHREAD_START_ROUTINE lpStartAddress,
		LPVOID lpParameter,
		DWORD dwCreationFlags,
		LPDWORD lpThreadId);
	DWORD ResumeThread(HANDLE hThread);
	BOOL SwitchToThread(void);
	DWORD SuspendThread(HANDLE hThread);
	void * GetProcAddress(HMODULE hModule, LPCSTR lpProcName);
	// DWORD QueueUserAPC(PAPCFUNC pfnAPC, HANDLE hThread, ULONG_PTR dwData);
]]

-- socket.lua
-- copied from: https://github.com/hnakamur/luajit-examples/blob/master/socket/cdef/socket.lua
--[[ffi.cdef[ [
	// these are defined in win_socket.lua, but inside structures
	static const int IPPROTO_TCP			= 6;		// tcp
	static const int IPPROTO_UDP			= 17;		// user datagram protocol

	static const int SOCK_STREAM     = 1;    // stream socket
	static const int SOCK_DGRAM      = 2;    // datagram socket

	static const int AF_UNSPEC 		= 0;          // unspecified
	static const int AF_UNIX 		= 1;          // local to host (pipes, portals)
	static const int AF_INET 		= 2;          // internetwork: UDP, TCP, etc.

	static const unsigned long INADDR_ANY             = 0x00000000;
	static const unsigned long INADDR_BROADCAST       = 0xffffffff;
	static const int INADDR_LOOPBACK        = 0x7f000001;
	static const int INADDR_NONE            = 0xffffffff;
	// end win_socket.lua redefines

]]

-- socket.lua
ffi.cdef[[
	// these are defined in win_socket.lua, but inside structures and redefined here
	static const int IPPROTO_TCP			= 6;		// tcp
	static const int IPPROTO_UDP			= 17;		// user datagram protocol
	// end win_socket.lua redefines

	static const int SD_RECEIVE = 0; // Shutdown receive operations.
	static const int SD_SEND 		= 1; // Shutdown send operations.
	static const int SD_BOTH 		= 2; // Shutdown both send and receive operations.
]]

-- socket.lua
ffi.cdef[[
	static const int PF_INET = 2;
	static const int AF_INET = PF_INET;

	static const int SOCK_STREAM = 1;

	typedef uint32_t socklen_t;
	typedef uint16_t in_port_t;
	typedef unsigned short int sa_family_t;
	typedef uint32_t in_addr_t;

	// Basic system type definitions, taken from the BSD file sys/types.h.
	typedef unsigned char   u_char;
	typedef unsigned short  u_short;
	typedef unsigned int    u_int;
	typedef unsigned long   u_long;


	static const int SOL_SOCKET = 1;
	static const int SO_REUSEADDR = 2;
	static const int INADDR_ANY = (in_addr_t)0x00000000;

	// Socket address conversions
	static const int NI_MAXHOST = 1025;
	static const int NI_MAXSERV = 32;

	int getnameinfo(
		const struct sockaddr  *sa, // _In_ FAR
		socklen_t salen, // _In_
		char  *host, // _Out_ FAR
		DWORD hostlen, // _In_
		char  *serv, // _Out_ FAR
		DWORD servlen, // _In_
		int flags // _In_
	);

	/*
	struct sockaddr {
		sa_family_t  	sa_family;
		char    			sa_data[14];
	};

	struct sockaddr_in {
		short   sin_family;
		u_short sin_port;
		struct  in_addr sin_addr;
		char    sin_zero[8];
	};
	*/

	u_short htons(u_short hostshort);
	int WSACleanup(void);

	DWORD FormatMessage(
		DWORD dwFlags, // _In_
    LPCVOID lpSource, // _In_opt_
    DWORD dwMessageId, // _In_
		DWORD dwLanguageId, // _In_
		LPTSTR lpBuffer, // _Out_
 		DWORD nSize, // _In_
    va_list *Arguments // _In_opt_
	);

]]
