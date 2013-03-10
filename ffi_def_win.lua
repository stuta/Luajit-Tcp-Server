--  ffi_def_win.lua
local ffi = require "ffi" 
--[[
https://github.com/Wiladams/BanateCoreWin32
]]
ffi.cdef([[
	// Windows
	// win basic types
		// https://github.com/Wiladams/BanateCoreWin32/blob/master/WTypes.lua
	typedef unsigned char	BYTE;
	typedef long			BOOL;
	typedef BYTE			BOOLEAN;
	typedef char			CHAR;
	typedef wchar_t			WCHAR;
	typedef uint16_t		WORD;
	typedef unsigned long	DWORD;
	typedef uint32_t		DWORD32;
	typedef int				INT;
	typedef int32_t			INT32;
	typedef int64_t			INT64;
	typedef float 			FLOAT;
	typedef long			LONG;
	typedef signed int		LONG32;
	typedef int64_t			LONGLONG;
	typedef size_t			SIZE_T;

	typedef uint8_t			BCHAR;
	typedef unsigned char	UCHAR;
	typedef unsigned int	UINT;
	typedef unsigned int	UINT32;
	typedef unsigned long	ULONG;
	typedef unsigned int	ULONG32;
	typedef unsigned short	USHORT;
	typedef uint64_t		ULONGLONG;


	// Some pointer types
	typedef unsigned char	*PUCHAR;
	typedef unsigned int	*PUINT;
	typedef unsigned int	*PUINT32;
	typedef unsigned long	*PULONG;
	typedef unsigned int	*PULONG32;
	typedef unsigned short	*PUSHORT;
	typedef LONGLONG 		*PLONGLONG;
	typedef ULONGLONG 		*PULONGLONG;


	typedef void *			PVOID;
	typedef DWORD *			DWORD_PTR;
	typedef intptr_t		LONG_PTR;
	typedef uintptr_t		UINT_PTR;
	typedef uintptr_t		ULONG_PTR;
	typedef ULONG_PTR *		PULONG_PTR;


	typedef DWORD *			LPCOLORREF;

	typedef BOOL *			LPBOOL;
	typedef char *			LPSTR;
	typedef short *			LPWSTR;
	typedef const short *	LPCWSTR;
	typedef LPSTR			LPTSTR;

	typedef DWORD *			LPDWORD;
	typedef void *			LPVOID;
	typedef WORD *			LPWORD;

	typedef const char *	LPCSTR;
	typedef LPCSTR			LPCTSTR;
	typedef const void *	LPCVOID;


	typedef LONG_PTR		LRESULT;

	typedef LONG_PTR		LPARAM;
	typedef UINT_PTR		WPARAM;


	typedef unsigned char	TBYTE;
	typedef char			TCHAR;

	typedef USHORT			COLOR16;
	typedef DWORD			COLORREF;

	// Special types
	typedef WORD			ATOM;
	typedef DWORD			LCID;
	typedef USHORT			LANGID;

	// Various Handles
	typedef void *			HANDLE;
	typedef HANDLE			*PHANDLE;
	typedef HANDLE			LPHANDLE;
	typedef void *			HBITMAP;
	typedef void *			HBRUSH;
	typedef void *			HICON;
	typedef HICON			HCURSOR;
	typedef HANDLE			HDC;
	typedef void *			HDESK;
	typedef HANDLE			HDROP;
	typedef HANDLE			HDWP;
	typedef HANDLE			HENHMETAFILE;
	typedef INT				HFILE;
	typedef HANDLE			HFONT;
	typedef void *			HGDIOBJ;
	typedef HANDLE			HGLOBAL;
	typedef HANDLE 			HGLRC;
	typedef HANDLE			HHOOK;
	typedef void *			HINSTANCE;
	typedef void *			HKEY;
	typedef void *			HKL;
	typedef HANDLE			HLOCAL;
	typedef void *			HMEMF;
	typedef HANDLE			HMENU;
	typedef HANDLE			HMETAFILE;
	typedef void			HMF;
	typedef HINSTANCE		HMODULE;
	typedef HANDLE			HMONITOR;
	typedef HANDLE			HPALETTE;
	typedef void *			HPEN;
	typedef LONG			HRESULT;
	typedef HANDLE			HRGN;
	typedef void *			HRSRC;
	typedef void *			HSTR;
	typedef HANDLE			HSZ;
	typedef void *			HTASK;
	typedef void *			HWINSTA;
	typedef HANDLE			HWND;

	// Ole Automation
	typedef WCHAR			OLECHAR;
	typedef OLECHAR 		*LPOLESTR;
	typedef const OLECHAR	*LPCOLESTR;

	//typedef char      OLECHAR;
	//typedef LPSTR     LPOLESTR;
	//typedef LPCSTR    LPCOLESTR;

	typedef OLECHAR *BSTR;
	typedef BSTR *LPBSTR;

	typedef DWORD ACCESS_MASK;
	typedef ACCESS_MASK* PACCESS_MASK;

	typedef LONG FXPT16DOT16, *LPFXPT16DOT16;
	typedef LONG FXPT2DOT30, *LPFXPT2DOT30;
]])

ffi.cdef([[
	// Windows
	// win basic structures and defines
	static const DWORD STD_INPUT_HANDLE = -10; 	//#define STD_INPUT_HANDLE    (DWORD)-10
	static const DWORD STD_OUTPUT_HANDLE = -11;	// #define STD_OUTPUT_HANDLE   (DWORD)-11
	static const DWORD STD_ERROR_HANDLE = -12;	// #define STD_ERROR_HANDLE    (DWORD)-12
	
	static const int ENABLE_LINE_INPUT = 0x0002;	// #define ENABLE_LINE_INPUT       0x0002
	static const int ENABLE_ECHO_INPUT = 0x0004;	// #define ENABLE_ECHO_INPUT       0x0004

	typedef union _LARGE_INTEGER { 
		struct {
			DWORD LowPart;
			LONG  HighPart;
		} ;
		struct {
			DWORD LowPart;
			LONG  HighPart;
		} u;
		LONGLONG QuadPart;
	} LARGE_INTEGER, *PLARGE_INTEGER;
	
	typedef struct _SECURITY_ATTRIBUTES {
		DWORD nLength;
		LPVOID lpSecurityDescriptor;
		BOOL bInheritHandle;
	} SECURITY_ATTRIBUTES,  *PSECURITY_ATTRIBUTES,  *LPSECURITY_ATTRIBUTES;
	
	typedef DWORD (__stdcall *LPTHREAD_START_ROUTINE) (
    LPVOID lpThreadParameter // [in] 
	);
]])

ffi.cdef([[
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
]])

-- ffi_def_shared_mem.lua
ffi.cdef([[
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
]])

--  ffi_def_thread.lua
ffi.cdef([[
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
]])

