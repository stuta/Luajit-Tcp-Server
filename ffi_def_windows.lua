-- ffi_def_windows.lua
module(..., package.seeall)
local ffi = require "ffi"
-- Lua state - creating a new Lua state to a new thread
ffi.cdef[[
	// lua.h
	static const int LUA_GCSTOP		= 0;
	static const int LUA_GCRESTART		= 1;
	static const int LUA_GCCOLLECT		= 2;
	static const int LUA_GCCOUNT		= 3;
	static const int LUA_GCCOUNTB		= 4;
	static const int LUA_GCSTEP		= 5;
	static const int LUA_GCSETPAUSE		= 6;
	static const int LUA_GCSETSTEPMUL	= 7;
	static const int LUA_GLOBALSINDEX = -10002;
	typedef struct lua_State lua_State;
	int (lua_gc) (lua_State *L, int what, int data);
	lua_State *luaL_newstate(void);
	void luaL_openlibs(lua_State *L);
	void lua_close(lua_State *L);
	int luaL_loadstring(lua_State *L, const char *s);
	int lua_pcall(lua_State *L, int nargs, int nresults, int errfunc);
	void lua_getfield(lua_State *L, int index, const char *k);
	ptrdiff_t lua_tointeger(lua_State *L, int index);
	void lua_settop(lua_State *L, int index);
]]
ffi.cdef[[
	// handmade basic types
	// http://msdn.microsoft.com/en-us/library/windows/desktop/aa383751(v=vs.85).aspx

	typedef unsigned short WORD;
	typedef unsigned long DWORD;
	typedef int INT;
	typedef long LONG;
	typedef unsigned short USHORT;
	typedef void *HANDLE;
	typedef int WINBOOL,*PWINBOOL,*LPWINBOOL;
	typedef void *PVOID,*LPVOID;
	typedef WINBOOL BOOL;

	// Basic system type definitions, taken from the BSD file sys/types.h.
	typedef unsigned char   u_char;
	typedef unsigned short  u_short;
	typedef unsigned int    u_int;
	typedef unsigned long   u_long;
]]
ffi.cdef[[
	// bad or ugly define macros, done by hand
	// bad order of generated calls
]]
-- everything above will stay, below will be generated --
-- ******************** --
-- generated code start --

--[[ lib_date_time.lua ]]
ffi.cdef[[
	typedef __int64 __time64_t;
	
	typedef __time64_t time_t;
	
	}
time_t time(time_t * _Time)
{
    return _time64(_Time);
]]

--[[ lib_http.lua ]]
--[[ lib_kqueue.lua ]]
--[[ lib_poll.lua ]]
ffi.cdef[[
	static const int POLLERR =     0x0001;
	static const int POLLHUP =     0x0002;
	static const int POLLIN =      (POLLRDNORM | POLLRDBAND);
	static const int POLLNVAL =    0x0004;
	static const int POLLOUT =     (POLLWRNORM);
	
	void   free( void * _Memory);
	void * realloc( void * _Memory,   size_t _NewSize);
]]

--[[ lib_shared_memory.lua ]]
ffi.cdef[[
	static const int SO_LINGER =       0x0080      // linger on close if data present;
	
	DECLSPEC_IMPORT
	VOID
	WINAPI
	ReleaseSRWLockExclusive (
	     __inout PSRWLOCK SRWLock
	     );
	DECLSPEC_IMPORT
	BOOL
	WINAPI
	SleepConditionVariableCS (
	    __inout PCONDITION_VARIABLE ConditionVariable,
	    __inout PCRITICAL_SECTION CriticalSection,
	    __in DWORD dwMilliseconds
	    );
	// #pragma pack(pop)
	// #pragma pack(push,8)
	struct _iobuf {
	        char *_ptr;
	        int   _cnt;
	        char *_base;
	        int   _flag;
	        int   _file;
	        int   _charbuf;
	        int   _bufsiz;
	        char *_tmpfname;
	        };
	
	// #pragma pack()

	DECLSPEC_IMPORT
	__out_opt
	PVOID
	WINAPI
	EncodePointer (
	    __in_opt PVOID Ptr
	    );
	typedef struct _SECURITY_ATTRIBUTES {
	    DWORD nLength;
	    LPVOID lpSecurityDescriptor;
	    BOOL bInheritHandle;
	} SECURITY_ATTRIBUTES, *PSECURITY_ATTRIBUTES, *LPSECURITY_ATTRIBUTES;

	typedef struct _iobuf FILE;
	DECLSPEC_IMPORT
	FARPROC
	WINAPI
	GetProcAddress (
	    __in HMODULE hModule,
	    __in LPCSTR lpProcName
	    );
	DECLSPEC_IMPORT
	BOOL
	WINAPI
	HeapQueryInformation (
	    __in_opt HANDLE HeapHandle,
	    __in HEAP_INFORMATION_CLASS HeapInformationClass,
	    __out_bcount_part_opt(HeapInformationLength, *ReturnLength) PVOID HeapInformation,
	    __in SIZE_T HeapInformationLength,
	    __out_opt PSIZE_T ReturnLength
	    );
	DECLSPEC_IMPORT
	DWORD
	WINAPI
	GetVersion (
	    VOID
	    );
	DECLSPEC_IMPORT
	__out_opt
	HGLOBAL
	WINAPI
	GlobalHandle (
	    __in LPCVOID pMem
	    );
	
	DECLSPEC_IMPORT
BOOL
WINAPI
CloseHandle(
    __in HANDLE hObject
    );
	DECLSPEC_IMPORT
__out_opt
HANDLE
WINAPI
CreateFileMappingA(
    __in     HANDLE hFile,
    __in_opt LPSECURITY_ATTRIBUTES lpFileMappingAttributes,
    __in     DWORD flProtect,
    __in     DWORD dwMaximumSizeHigh,
    __in     DWORD dwMaximumSizeLow,
    __in_opt LPCSTR lpName
    );
	DECLSPEC_IMPORT
__checkReturn
DWORD
WINAPI
GetLastError(
    VOID
    );
	DECLSPEC_IMPORT
__out_opt __out_data_source(FILE)
LPVOID
WINAPI
MapViewOfFile(
    __in HANDLE hFileMappingObject,
    __in DWORD dwDesiredAccess,
    __in DWORD dwFileOffsetHigh,
    __in DWORD dwFileOffsetLow,
    __in SIZE_T dwNumberOfBytesToMap
    );
	DECLSPEC_IMPORT
__out
HANDLE
WINAPI
OpenFileMappingA(
    __in DWORD dwDesiredAccess,
    __in BOOL bInheritHandle,
    __in LPCSTR lpName
    );
	size_t  strlen(   const char * _Str);
	DECLSPEC_IMPORT
BOOL
WINAPI
UnmapViewOfFile(
    __in LPCVOID lpBaseAddress
    );
]]

--[[ lib_signal.lua ]]
--[[ lib_socket.lua ]]
ffi.cdef[[
	static const int SO_CONDITIONAL_ACCEPT = 0x3002 // enable true conditional accept:;
	static const int AI_PASSIVE =                  0x00000001  // Socket address will be used in bind() call;
	static const int gai_strerror =   gai_strerrorW;
	static const int SO_ACCEPTCONN =   0x0002      // socket has had listen();
	static const int SO_SNDBUF =       0x1001      // send buffer size;
	static const int SO_ACCEPTCONN =   0x0002      // socket has had listen();
	
	typedef struct _WSAPROTOCOLCHAIN {
	    int ChainLen;                                 
	    DWORD ChainEntries[7];       
	} WSAPROTOCOLCHAIN,  * LPWSAPROTOCOLCHAIN;

	typedef int socklen_t;
	typedef struct _GUID {
	    unsigned long  Data1;
	    unsigned short Data2;
	    unsigned short Data3;
	    unsigned char  Data4[ 8 ];
	} GUID;

	typedef struct addrinfo
	{
	    int                 ai_flags;       
	    int                 ai_family;      
	    int                 ai_socktype;    
	    int                 ai_protocol;    
	    size_t              ai_addrlen;     
	    char *              ai_canonname;   
	    __field_bcount(ai_addrlen) struct sockaddr *   ai_addr;        
	    struct addrinfo *   ai_next;        
	}
	ADDRINFOA, *PADDRINFOA;

	typedef union sockaddr_gen {
	    struct sockaddr Address;
	    struct sockaddr_in AddressIn;
	    struct sockaddr_in6_old AddressIn6;
	} sockaddr_gen;
	typedef struct _INTERFACE_INFO {
	    ULONG iiFlags;              
	    sockaddr_gen iiAddress;     
	    sockaddr_gen iiBroadcastAddress; 
	    sockaddr_gen iiNetmask;     
	} INTERFACE_INFO, FAR *LPINTERFACE_INFO;
	typedef struct _INTERFACE_INFO_EX {
	    ULONG iiFlags;              
	    SOCKET_ADDRESS iiAddress;   
	    SOCKET_ADDRESS iiBroadcastAddress; 
	    SOCKET_ADDRESS iiNetmask;   
	} INTERFACE_INFO_EX, FAR *LPINTERFACE_INFO_EX;
	typedef struct sockaddr_in6 {
	    ADDRESS_FAMILY sin6_family; 
	    USHORT sin6_port;           
	    ULONG  sin6_flowinfo;       
	    IN6_ADDR sin6_addr;         
	    union {
	        ULONG sin6_scope_id;     
	        SCOPE_ID sin6_scope_struct; 
	    };

	typedef struct in6_addr {
	    union {
	        UCHAR       Byte[16];
	        USHORT      Word[8];
	    } u;
	} IN6_ADDR, *PIN6_ADDR, FAR *LPIN6_ADDR;

	struct sockaddr_in6_old {
	    SHORT sin6_family;          
	    USHORT sin6_port;           
	    ULONG sin6_flowinfo;        
	    IN6_ADDR sin6_addr;         
	};

	struct sockaddr_in AddressIn;
	__field_bcount(len) CHAR FAR *buf;
	typedef struct _WSAPROTOCOL_INFOA {
	    DWORD dwServiceFlags1;
	    DWORD dwServiceFlags2;
	    DWORD dwServiceFlags3;
	    DWORD dwServiceFlags4;
	    DWORD dwProviderFlags;
	    GUID ProviderId;
	    DWORD dwCatalogEntryId;
	    WSAPROTOCOLCHAIN ProtocolChain;
	    int iVersion;
	    int iAddressFamily;
	    int iMaxSockAddr;
	    int iMinSockAddr;
	    int iSocketType;
	    int iProtocol;
	    int iProtocolMaxOffset;
	    int iNetworkByteOrder;
	    int iSecurityScheme;
	    DWORD dwMessageSize;
	    DWORD dwProviderReserved;
	    CHAR   szProtocol[255+1];
	} WSAPROTOCOL_INFOA,  * LPWSAPROTOCOL_INFOA;

	typedef struct pollfd {
	    SOCKET  fd;
	    SHORT   events;
	    SHORT   revents;
	} WSAPOLLFD, *PWSAPOLLFD,  *LPWSAPOLLFD;

	DECLSPEC_IMPORT
	BOOL
	WINAPI
	GetBinaryTypeA(
	    __in  LPCSTR lpApplicationName,
	    __out LPDWORD  lpBinaryType
	    );
	DECLSPEC_IMPORT
	BOOL
	WINAPI
	SleepConditionVariableSRW (
	    __inout PCONDITION_VARIABLE ConditionVariable,
	    __inout PSRWLOCK SRWLock,
	    __in DWORD dwMilliseconds,
	    __in ULONG Flags
	    );
	typedef  CHAR *NPSTR, *LPSTR, *PSTR;
	DECLSPEC_IMPORT
	BOOL
	WINAPI
	GetNamedPipeAttribute(
	    __in HANDLE Pipe,
	    __in PIPE_ATTRIBUTE_TYPE AttributeType,
	    __in PSTR AttributeName,
	    __out_bcount(*AttributeValueLength) PVOID AttributeValue,
	    __inout PSIZE_T AttributeValueLength
	    );
	typedef struct sockaddr {
	    u_short sa_family;
	    CHAR sa_data[14];                   
	} SOCKADDR, *PSOCKADDR, FAR *LPSOCKADDR;

	typedef CHAR *PCHAR, *LPCH, *PCH;
	typedef struct sockaddr {
	    u_short sa_family;
	    CHAR sa_data[14];                   
	} SOCKADDR, *PSOCKADDR, FAR *LPSOCKADDR;
	typedef struct _SOCKET_ADDRESS {
	    __field_bcount(iSockaddrLength) LPSOCKADDR lpSockaddr;
	    INT iSockaddrLength;
	} SOCKET_ADDRESS, *PSOCKET_ADDRESS, *LPSOCKET_ADDRESS;
	typedef struct _SOCKET_ADDRESS_LIST {
	    INT             iAddressCount;
	    SOCKET_ADDRESS  Address[1];
	} SOCKET_ADDRESS_LIST, *PSOCKET_ADDRESS_LIST, FAR *LPSOCKET_ADDRESS_LIST;
	typedef struct _CSADDR_INFO {
	    SOCKET_ADDRESS LocalAddr ;
	    SOCKET_ADDRESS RemoteAddr ;
	    INT iSocketType ;
	    INT iProtocol ;
	} CSADDR_INFO, *PCSADDR_INFO, FAR * LPCSADDR_INFO ;
	typedef struct sockaddr_storage {
	    ADDRESS_FAMILY ss_family;      
	    CHAR __ss_pad1[((sizeof(__int64)) - sizeof (short))];  
	    __int64 __ss_align;            
	    CHAR __ss_pad2[(128 - (sizeof (short) + ((sizeof(__int64)) - sizeof (short)) + (sizeof(__int64))))];  
	} SOCKADDR_STORAGE_LH, *PSOCKADDR_STORAGE_LH, FAR *LPSOCKADDR_STORAGE_LH;
	typedef struct sockaddr_storage_xp {
	    short ss_family;               
	    CHAR __ss_pad1[((sizeof(__int64)) - sizeof (short))];  
	    __int64 __ss_align;            
	    CHAR __ss_pad2[(128 - (sizeof (short) + ((sizeof(__int64)) - sizeof (short)) + (sizeof(__int64))))];  
	} SOCKADDR_STORAGE_XP, *PSOCKADDR_STORAGE_XP, FAR *LPSOCKADDR_STORAGE_XP;
	typedef enum {
	    IPPROTO_ICMP          = 1,
	    IPPROTO_IGMP          = 2,
	    IPPROTO_GGP           = 3,
	    IPPROTO_TCP           = 6,
	    IPPROTO_PUP           = 12,
	    IPPROTO_UDP           = 17,
	    IPPROTO_IDP           = 22,
	    IPPROTO_ND            = 77,
	    IPPROTO_RAW           = 255,
	    IPPROTO_MAX           = 256,
	    IPPROTO_RESERVED_RAW  = 257,
	    IPPROTO_RESERVED_IPSEC  = 258,
	    IPPROTO_RESERVED_IPSECOFFLOAD  = 259,
	    IPPROTO_RESERVED_MAX  = 260
	} IPPROTO, *PIPROTO;
	typedef enum {
	    ScopeLevelInterface    = 1,
	    ScopeLevelLink         = 2,
	    ScopeLevelSubnet       = 3,
	    ScopeLevelAdmin        = 4,
	    ScopeLevelSite         = 5,
	    ScopeLevelOrganization = 8,
	    ScopeLevelGlobal       = 14,
	    ScopeLevelCount        = 16
	} SCOPE_LEVEL;
	typedef struct {
	    union {
	        struct {
	            ULONG Zone : 28;
	            ULONG Level : 4;
	        };

	typedef struct WSAData {
	        WORD                    wVersion;
	        WORD                    wHighVersion;
	        char                    szDescription[256+1];
	        char                    szSystemStatus[128+1];
	        unsigned short          iMaxSockets;
	        unsigned short          iMaxUdpDg;
	        char  *              lpVendorInfo;
	} WSADATA,  * LPWSADATA;

	typedef  const CHAR *LPCSTR, *PCSTR;
	
	int
 
closesocket(
     SOCKET s
    );
	int
 
connect(
     SOCKET s,
     const struct sockaddr  * name,
     int namelen
    );

	INT
 
getaddrinfo(
            PCSTR               pNodeName,
            PCSTR               pServiceName,
            const ADDRINFOA *   pHints,
         PADDRINFOA *        ppResult
    );
	INT
 
getnameinfo(
             const SOCKADDR *    pSockaddr,
                                    socklen_t           SockaddrLength,
        PCHAR               pNodeBuffer,
                                    DWORD               NodeBufferSize,
     PCHAR               pServiceBuffer,
                                    DWORD               ServiceBufferSize,
                                    INT                 Flags
    );
	int
 
getpeername(
     SOCKET s,
     struct sockaddr  * name,
     int  * namelen
    );

	int
 
getsockopt(
     SOCKET s,
     int level,
     int optname,
     char  * optval,
     int  * optlen
    );
	u_short
 
htons(
     u_short hostshort
    );
	PCSTR
 
inet_ntop(
                                    INT             Family,
                                    PVOID           pAddr,
             PSTR            pStringBuf,
                                    size_t          StringBufSize
    );
	int
 
ioctlsocket(
     SOCKET s,
     long cmd,
     u_long  * argp
    );
	u_short
 
ntohs(
     u_short netshort
    );
	int
 
recv(
     SOCKET s,
      char  * buf,
     int len,
     int flags
    );
	int
 
setsockopt(
     SOCKET s,
     int level,
     int optname,
     const char  * optval,
     int optlen
    );
	int
 
shutdown(
     SOCKET s,
     int how
    );
	INT
 
WSAAddressToStringA(
     LPSOCKADDR lpsaAddress,
         DWORD               dwAddressLength,
     LPWSAPROTOCOL_INFOA lpProtocolInfo,
     LPSTR lpszAddressString,
      LPDWORD             lpdwAddressStringLength
    );
	int
 
WSACleanup(
    void
    );
	int
 
WSAGetLastError(
    void
    );
	int
 
WSAPoll(
     LPWSAPOLLFD fdArray,
     ULONG fds,
     INT timeout
    );
	int
 
WSAStartup(
     WORD wVersionRequested,
     LPWSADATA lpWSAData
    );
]]

--[[ lib_tcp.lua ]]
ffi.cdef[[
	static const int AF_INET =         2               // internetwork: UDP, TCP, etc.;
	static const int AF_INET6 =        23              // Internetwork Version 6;
	static const int INET6_ADDRSTRLEN = 65;
	static const int INET_ADDRSTRLEN =  22;
	static const int SO_RCVBUF =       0x1002      // receive buffer size;
	static const int SO_REUSEADDR =    0x0004      // allow local address reuse;
	static const int SO_USELOOPBACK =  0x0040      // bypass hardware when possible;
	static const int SOCK_STREAM =     1;
	static const int SOL_SOCKET = 0xffff;
	static const int SOMAXCONN =       0x7fffffff;
	static const int TCP_NODELAY =         0x0001;
	
	typedef struct in_addr {
	        union {
	                struct { UCHAR s_b1,s_b2,s_b3,s_b4; } S_un_b;
	                struct { USHORT s_w1,s_w2; } S_un_w;
	                ULONG S_addr;
	        } S_un;
	} IN_ADDR, *PIN_ADDR, FAR *LPIN_ADDR;

	IN_ADDR sin_addr;
	USHORT sin_port;
]]

--[[ lib_thread.lua ]]
ffi.cdef[[
	static const int INFINITE =            0xFFFFFFFF  // Infinite timeout;
	
	typedef DWORD (WINAPI *PTHREAD_START_ROUTINE)(
	    LPVOID lpThreadParameter
	    );
	typedef PTHREAD_START_ROUTINE LPTHREAD_START_ROUTINE;
	typedef struct _CREATE_THREAD_DEBUG_INFO {
	    HANDLE hThread;
	    LPVOID lpThreadLocalBase;
	    LPTHREAD_START_ROUTINE lpStartAddress;
	} CREATE_THREAD_DEBUG_INFO, *LPCREATE_THREAD_DEBUG_INFO;

	CREATE_THREAD_DEBUG_INFO CreateThread;
	DECLSPEC_IMPORT
DWORD
WINAPI
GetCurrentThreadId(
    VOID
    );
	DECLSPEC_IMPORT
DWORD
WINAPI
WaitForSingleObject(
    __in HANDLE hHandle,
    __in DWORD dwMilliseconds
    );
]]

--[[ lib_util.lua ]]
ffi.cdef[[
	static const int ENABLE_ECHO_INPUT =       0x0004;
	static const int ENABLE_LINE_INPUT =       0x0002;
	static const int FORMAT_MESSAGE_FROM_SYSTEM =     0x00001000;
	static const int FORMAT_MESSAGE_IGNORE_INSERTS =  0x00000200;
	static const int STD_INPUT_HANDLE =    ((DWORD)-10);
	
	DECLSPEC_IMPORT
	BOOL
	WINAPI
	SetFilePointerEx(
	    __in      HANDLE hFile,
	    __in      LARGE_INTEGER liDistanceToMove,
	    __out_opt PLARGE_INTEGER lpNewFilePointer,
	    __in      DWORD dwMoveMethod
	    );
	typedef struct _CONSOLE_READCONSOLE_CONTROL {
	    ULONG nLength;
	    ULONG nInitialChars;
	    ULONG dwCtrlWakeupMask;
	    ULONG dwControlKeyState;
	} CONSOLE_READCONSOLE_CONTROL, *PCONSOLE_READCONSOLE_CONTROL;

	typedef struct _SYSTEM_INFO {
	    union {
	        DWORD dwOemId;          
	        struct {
	            WORD wProcessorArchitecture;
	            WORD wReserved;
	        } DUMMYSTRUCTNAME;
	    } DUMMYUNIONNAME;
	    DWORD dwPageSize;
	    LPVOID lpMinimumApplicationAddress;
	    LPVOID lpMaximumApplicationAddress;
	    DWORD_PTR dwActiveProcessorMask;
	    DWORD dwNumberOfProcessors;
	    DWORD dwProcessorType;
	    DWORD dwAllocationGranularity;
	    WORD wProcessorLevel;
	    WORD wProcessorRevision;
	} SYSTEM_INFO, *LPSYSTEM_INFO;

	struct timeval {
	        long    tv_sec;         
	        long    tv_usec;        
	};

	DECLSPEC_IMPORT
DWORD
WINAPI
FormatMessageA(
    __in     DWORD dwFlags,
    __in_opt LPCVOID lpSource,
    __in     DWORD dwMessageId,
    __in     DWORD dwLanguageId,
    __out    LPSTR lpBuffer,
    __in     DWORD nSize,
    __in_opt va_list *Arguments
    );
	BOOL

GetConsoleMode(
     HANDLE hConsoleHandle,
     LPDWORD lpMode
    );
	DECLSPEC_IMPORT
HANDLE
WINAPI
GetStdHandle(
    __in DWORD nStdHandle
    );
	DECLSPEC_IMPORT
VOID
WINAPI
GetSystemInfo(
    __out LPSYSTEM_INFO lpSystemInfo
    );
	DECLSPEC_IMPORT
BOOL
WINAPI
QueryPerformanceCounter(
    __out LARGE_INTEGER *lpPerformanceCount
    );
	DECLSPEC_IMPORT
BOOL
WINAPI
QueryPerformanceFrequency(
    __out LARGE_INTEGER *lpFrequency
    );
	BOOL

ReadConsoleA(
     HANDLE hConsoleInput,
       LPVOID lpBuffer,
     DWORD nNumberOfCharsToRead,
     LPDWORD lpNumberOfCharsRead,
     PCONSOLE_READCONSOLE_CONTROL pInputControl
    );
	BOOL

SetConsoleMode(
     HANDLE hConsoleHandle,
     DWORD dwMode
    );
	DECLSPEC_IMPORT
VOID
WINAPI
Sleep(
    __in DWORD dwMilliseconds
    );
	char ** __sys_errlist(void);
	BOOL

SwitchToThread(
    void
    );
]]

--[[ TestAddrinfo.lua ]]
ffi.cdef[[
	static const int AI_CANONNAME =                0x00000002  // Return canonical name in first ai_canonname;
	static const int NI_MAXHOST =      1025  /* Max size of a fully-qualified domain name */;
	static const int NI_MAXSERV =      32    /* Max size of a service name */;
	static const int NI_NAMEREQD =     0x04  /* Error if the host's name not in DNS */;
	static const int NI_NUMERICHOST =  0x02  /* Return numeric form of the host's address */;
	static const int NI_NUMERICSERV =  0x08  /* Return numeric form of the service (port #) */;
]]

--[[ TestAll.lua ]]
--[[ TestKqueue.lua ]]
--[[ TestLinux.lua ]]
--[[ TestSharedMemory.lua ]]
--[[ TestSignal.lua ]]
--[[ TestSignal_bad.lua ]]
ffi.cdef[[
	static const int SO_PAUSE_ACCEPT = 0x3003      // pause accepting new connections;
	static const int IGNORE =              0       // Ignore signal;
]]

--[[ TestSocket.lua ]]
ffi.cdef[[
	static const int SD_SEND =         0x01;
]]

--[[ TestThread.lua ]]

--[[
not found calls = {
   [1] = "--- lib_date_time.lua ---";
   [2] = "--- lib_http.lua ---";
   [3] = "--- lib_kqueue.lua ---";
   [4] = "--- lib_poll.lua ---";
   [5] = "--- lib_shared_memory.lua ---";
   [6] = "ftruncate";
   [7] = "MAP_SHARED";
   [8] = "mmap";
   [9] = "munmap";
   [10] = "O_CREAT";
   [11] = "O_RDONLY";
   [12] = "O_RDWR";
   [13] = "PROT_READ";
   [14] = "PROT_WRITE";
   [15] = "shm_open";
   [16] = "shm_unlink";
   [17] = "--- lib_signal.lua ---";
   [18] = "getpid";
   [19] = "kill";
   [20] = "pthread_sigmask";
   [21] = "sigaddset";
   [22] = "sigemptyset";
   [23] = "sigwait";
   [24] = "--- lib_socket.lua ---";
   [25] = "F_GETFL";
   [26] = "F_SETFL";
   [27] = "fcntl";
   [28] = "O_NONBLOCK";
   [29] = "poll";
   [30] = "--- lib_tcp.lua ---";
   [31] = "--- lib_thread.lua ---";
   [32] = "pthread_create";
   [33] = "pthread_exit";
   [34] = "pthread_join";
   [35] = "pthread_self";
   [36] = "--- lib_util.lua ---";
   [37] = "_SC_NPROCESSORS_CONF";
   [38] = "_SC_NPROCESSORS_ONLN";
   [39] = "gettimeofday";
   [40] = "nanosleep";
   [41] = "sched_yield";
   [42] = "sysconf";
   [43] = "usleep";
   [44] = "--- TestAddrinfo.lua ---";
   [45] = "--- TestAll.lua ---";
   [46] = "--- TestKqueue.lua ---";
   [47] = "EV_ADD";
   [48] = "EV_ENABLE";
   [49] = "EV_ONESHOT";
   [50] = "EVFILT_VNODE";
   [51] = "kevent";
   [52] = "kqueue";
   [53] = "NOTE_ATTRIB";
   [54] = "NOTE_DELETE";
   [55] = "NOTE_EXTEND";
   [56] = "NOTE_WRITE";
   [57] = "O_RDONLY";
   [58] = "open";
   [59] = "--- TestLinux.lua ---";
   [60] = "mmap";
   [61] = "munmap";
   [62] = "O_CREAT";
   [63] = "O_EXCL";
   [64] = "shm_open";
   [65] = "shm_unlink";
   [66] = "--- TestSharedMemory.lua ---";
   [67] = "--- TestSignal.lua ---";
   [68] = "--- TestSignal_bad.lua ---";
   [69] = "getpid";
   [70] = "kill";
   [71] = "--- TestSocket.lua ---";
   [72] = "--- TestThread.lua ---";
};
]]