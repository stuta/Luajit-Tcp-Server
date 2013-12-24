-- ffi_def_windows_by_hand.lua
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
	
	// following MUST be here
	typedef intptr_t INT_PTR; 
	typedef uintptr_t UINT_PTR;
	
	// WinNT.h, BaseTsd.h
	typedef void VOID;
	typedef void *LPVOID;
	typedef const void *LPCVOID;

	typedef char CHAR;
	typedef unsigned char UCHAR;
	typedef short SHORT;
	typedef unsigned short USHORT;
	typedef int INT;
	typedef unsigned int UINT;
	typedef long LONG;
	typedef unsigned long ULONG;
	typedef __int64 LONGLONG;
	typedef unsigned __int64 ULONGLONG;

	typedef int BOOL;
	typedef unsigned char BYTE;
	
	typedef void *HANDLE;
	typedef unsigned short WORD;
	typedef unsigned long DWORD;
	

	// Basic system type definitions, taken from the BSD file sys/types.h.
	typedef unsigned char   u_char;
	typedef unsigned short  u_short;
	typedef unsigned int    u_int;
	typedef unsigned long   u_long;
]]
ffi.cdef[[
// bad or ugly define macros, done by hand
	
// #define inside struct is bad
typedef struct in_addr {
        union {
                struct { UCHAR s_b1,s_b2,s_b3,s_b4; } S_un_b;
                struct { USHORT s_w1,s_w2; } S_un_w;
                ULONG S_addr;
        } S_un;
			// #define s_addr  S_un.S_addr /* can be used for most tcp & ip code */
			// #define s_host  S_un.S_un_b.s_b2    // host on imp
			// #define s_net   S_un.S_un_b.s_b1    // network
			// #define s_imp   S_un.S_un_w.s_w2    // imp
			// #define s_impno S_un.S_un_b.s_b4    // imp #
			// #define s_lh    S_un.S_un_b.s_b3    // logical host
} IN_ADDR, *PIN_ADDR, *LPIN_ADDR;

// wrong order of defines
typedef USHORT ADDRESS_FAMILY;

]]
-- everything above will stay, below will be generated --
-- ******************** --
-- generated code start --

--[[ lib_date_time.lua ]]
ffi.cdef[[
typedef __int64 __time64_t;

typedef __time64_t time_t;

static double difftime(time_t _Time1, time_t _Time2);
static time_t time(time_t * _Time);
]]

--[[ lib_http.lua ]]
--[[ lib_kqueue.lua ]]
--[[ lib_poll.lua ]]
ffi.cdef[[
static const int POLLRDBAND = 0x0200;
static const int POLLRDNORM = 0x0100;
static const int POLLWRNORM = 0x0010;
static const int POLLERR = 0x0001;
static const int POLLHUP = 0x0002;
static const int POLLIN = (POLLRDNORM | POLLRDBAND);
static const int POLLNVAL = 0x0004;
static const int POLLOUT = (POLLWRNORM);

typedef UINT_PTR SOCKET;

typedef struct pollfd {
    SOCKET fd;
    SHORT events;
    SHORT revents;
} WSAPOLLFD, *PWSAPOLLFD, *LPWSAPOLLFD;

void free( void * _Memory);
void * realloc( void * _Memory, size_t _NewSize);
]]

--[[ lib_shared_memory.lua ]]
ffi.cdef[[
typedef unsigned __int64 ULONG_PTR, *PULONG_PTR;

typedef ULONG_PTR SIZE_T, *PSIZE_T;
typedef const CHAR *LPCSTR, *PCSTR;

typedef struct _SECURITY_ATTRIBUTES {
    DWORD nLength;
    LPVOID lpSecurityDescriptor;
    BOOL bInheritHandle;
} SECURITY_ATTRIBUTES, *PSECURITY_ATTRIBUTES, *LPSECURITY_ATTRIBUTES;


BOOL
CloseHandle(
    HANDLE hObject
    );

HANDLE
CreateFileMappingA(
    HANDLE hFile,
    LPSECURITY_ATTRIBUTES lpFileMappingAttributes,
    DWORD flProtect,
    DWORD dwMaximumSizeHigh,
    DWORD dwMaximumSizeLow,
    LPCSTR lpName
    );

DWORD
GetLastError(
    VOID
    );

LPVOID
MapViewOfFile(
    HANDLE hFileMappingObject,
    DWORD dwDesiredAccess,
    DWORD dwFileOffsetHigh,
    DWORD dwFileOffsetLow,
    SIZE_T dwNumberOfBytesToMap
    );

HANDLE
OpenFileMappingA(
    DWORD dwDesiredAccess,
    BOOL bInheritHandle,
    LPCSTR lpName
    );
size_t strlen( const char * _Str);

BOOL
UnmapViewOfFile(
    LPCVOID lpBaseAddress
    );
]]

--[[ lib_signal.lua ]]
--[[ lib_socket.lua ]]
ffi.cdef[[

typedef struct _GUID {
    unsigned long Data1;
    unsigned short Data2;
    unsigned short Data3;
    unsigned char Data4[ 8 ];
} GUID;

typedef struct _WSAPROTOCOLCHAIN {
    int ChainLen; /* the length of the chain,     */
    DWORD ChainEntries[7]; /* a list of dwCatalogEntryIds */
} WSAPROTOCOLCHAIN, * LPWSAPROTOCOLCHAIN;
typedef void *PVOID;
typedef int socklen_t;

typedef struct addrinfo
{
    int ai_flags; // AI_PASSIVE, AI_CANONNAME, AI_NUMERICHOST
    int ai_family; // PF_xxx
    int ai_socktype; // SOCK_xxx
    int ai_protocol; // 0 or IPPROTO_xxx for IPv4 and IPv6
    size_t ai_addrlen; // Length of ai_addr
    char * ai_canonname; // Canonical name for nodename
    struct sockaddr * ai_addr; // Binary address
    struct addrinfo * ai_next; // Next structure in linked list
}
ADDRINFOA, *PADDRINFOA;


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
    CHAR szProtocol[255 +1];
} WSAPROTOCOL_INFOA, * LPWSAPROTOCOL_INFOA;
typedef CHAR *PCHAR, *LPCH, *PCH;

typedef struct sockaddr_in {
    ADDRESS_FAMILY sin_family;
    USHORT sin_port;
    IN_ADDR sin_addr;
    CHAR sin_zero[8];
} SOCKADDR_IN, *PSOCKADDR_IN;
typedef DWORD *LPDWORD;

typedef struct sockaddr {
    ADDRESS_FAMILY sa_family; // Address family.
    CHAR sa_data[14]; // Up to 14 bytes of direct address.
} SOCKADDR, *PSOCKADDR, *LPSOCKADDR;

typedef struct WSAData {
        WORD wVersion;
        WORD wHighVersion;
        unsigned short iMaxSockets;
        unsigned short iMaxUdpDg;
        char * lpVendorInfo;
        char szDescription[256 +1];
        char szSystemStatus[128 +1];
} WSADATA, * LPWSADATA;
typedef CHAR *NPSTR, *LPSTR, *PSTR;


SOCKET
accept(
    SOCKET s,
    struct sockaddr * addr,
    int * addrlen
    );

int
bind(
    SOCKET s,
    const struct sockaddr * name,
    int namelen
    );

int
closesocket(
    SOCKET s
    );

int
connect(
    SOCKET s,
    const struct sockaddr * name,
    int namelen
    );

INT
getaddrinfo(
    PCSTR pNodeName,
    PCSTR pServiceName,
    const ADDRINFOA * pHints,
    PADDRINFOA * ppResult
    );

INT
getnameinfo(
    const SOCKADDR * pSockaddr,
    socklen_t SockaddrLength,
    PCHAR pNodeBuffer,
    DWORD NodeBufferSize,
    PCHAR pServiceBuffer,
    DWORD ServiceBufferSize,
    INT Flags
    );

int
getpeername(
    SOCKET s,
    struct sockaddr * name,
    int * namelen
    );

int
getsockopt(
    SOCKET s,
    int level,
    int optname,
    char * optval,
    int * optlen
    );

u_short
htons(
    u_short hostshort
    );

PCSTR
inet_ntop(
    INT Family,
    PVOID pAddr,
    PSTR pStringBuf,
    size_t StringBufSize
    );

int
ioctlsocket(
    SOCKET s,
    long cmd,
    u_long * argp
    );

int
listen(
    SOCKET s,
    int backlog
    );

u_short
ntohs(
    u_short netshort
    );

int
recv(
    SOCKET s,
    char * buf,
    int len,
    int flags
    );

int
send(
    SOCKET s,
    const char * buf,
    int len,
    int flags
    );

int
setsockopt(
    SOCKET s,
    int level,
    int optname,
    const char * optval,
    int optlen
    );

int
shutdown(
    SOCKET s,
    int how
    );

SOCKET
socket(
    int af,
    int type,
    int protocol
    );

INT
WSAAddressToStringA(
    LPSOCKADDR lpsaAddress,
    DWORD dwAddressLength,
    LPWSAPROTOCOL_INFOA lpProtocolInfo,
    LPSTR lpszAddressString,
    LPDWORD lpdwAddressStringLength
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
static const int AF_INET = 2;
static const int AF_INET6 = 23;
static const int INET6_ADDRSTRLEN = 65;
static const int INET_ADDRSTRLEN = 22;
static const int SO_RCVBUF = 0x1002;
static const int SO_REUSEADDR = 0x0004;
static const int SO_SNDBUF = 0x1001;
static const int SO_USELOOPBACK = 0x0040;
static const int SOCK_STREAM = 1;
static const int SOL_SOCKET = 0xffff;
static const int SOMAXCONN = 0x7fffffff;
static const int TCP_NODELAY = 0x0001;

// DWORD fDsrHold : 1;

typedef struct {
    union {
        struct {
            ULONG Zone : 28;
            ULONG Level : 4;
        };
        ULONG Value;
    };
} SCOPE_ID, *PSCOPE_ID;

typedef struct in6_addr {
    union {
        UCHAR Byte[16];
        USHORT Word[8];
    } u;
} IN6_ADDR, *PIN6_ADDR, *LPIN6_ADDR;
// typedef enum _RTL_UMS_THREAD_INFO_CLASS UMS_THREAD_INFO_CLASS, *PUMS_THREAD_INFO_CLASS;

/*
typedef struct sockaddr_in6 {
    ADDRESS_FAMILY sin6_family; // AF_INET6.
    USHORT sin6_port; // Transport level port number.
    ULONG sin6_flowinfo; // IPv6 flow information.
    IN6_ADDR sin6_addr; // IPv6 address.
    union {
        ULONG sin6_scope_id; // Set of interfaces for a scope.
        SCOPE_ID sin6_scope_struct;
    };
*/
typedef struct sockaddr_in6 {
    ADDRESS_FAMILY sin6_family; // AF_INET6.
    USHORT sin6_port; // Transport level port number.
    ULONG sin6_flowinfo; // IPv6 flow information.
    IN6_ADDR sin6_addr; // IPv6 address.
    union {
        ULONG sin6_scope_id; // Set of interfaces for a scope.
        SCOPE_ID sin6_scope_struct;
    };
} SOCKADDR_IN6_LH, *PSOCKADDR_IN6_LH, *LPSOCKADDR_IN6_LH;

typedef struct sockaddr_storage {
    ADDRESS_FAMILY ss_family; // address family
    CHAR __ss_pad1[((sizeof(__int64)) - sizeof(USHORT))]; // 6 byte pad, this is to make
    __int64 __ss_align; // Field to force desired structure
    CHAR __ss_pad2[(128 - (sizeof(USHORT) + ((sizeof(__int64)) - sizeof(USHORT)) + (sizeof(__int64))))]; // 112 byte pad to achieve desired size;
} SOCKADDR_STORAGE_LH, *PSOCKADDR_STORAGE_LH, *LPSOCKADDR_STORAGE_LH;


typedef enum {
    IPPROTO_HOPOPTS = 0, 
    IPPROTO_ICMP = 1,
    IPPROTO_IGMP = 2,
    IPPROTO_GGP = 3,
    IPPROTO_IPV4 = 4,
    IPPROTO_ST = 5,
    IPPROTO_TCP = 6,
    IPPROTO_CBT = 7,
    IPPROTO_EGP = 8,
    IPPROTO_IGP = 9,
    IPPROTO_PUP = 12,
    IPPROTO_UDP = 17,
    IPPROTO_IDP = 22,
    IPPROTO_RDP = 27,
    IPPROTO_IPV6 = 41, 
    IPPROTO_ROUTING = 43, 
    IPPROTO_FRAGMENT = 44, 
    IPPROTO_ESP = 50, 
    IPPROTO_AH = 51, 
    IPPROTO_ICMPV6 = 58, 
    IPPROTO_NONE = 59, 
    IPPROTO_DSTOPTS = 60, 
    IPPROTO_ND = 77,
    IPPROTO_ICLFXBM = 78,
    IPPROTO_PIM = 103,
    IPPROTO_PGM = 113,
    IPPROTO_L2TP = 115,
    IPPROTO_SCTP = 132,
    IPPROTO_RAW = 255,
    IPPROTO_MAX = 256,
    IPPROTO_RESERVED_RAW = 257,
    IPPROTO_RESERVED_IPSEC = 258,
    IPPROTO_RESERVED_IPSECOFFLOAD = 259,
    IPPROTO_RESERVED_MAX = 260
} IPPROTO, *PIPROTO;
// IN6_ADDR sin6_addr;
// USHORT sin6_port;
]]

--[[ lib_thread.lua ]]
ffi.cdef[[
static const int INFINITE = 0xFFFFFFFF;

// new: PTHREAD_START_ROUTINE
typedef DWORD (*PTHREAD_START_ROUTINE)(
    LPVOID lpThreadParameter
    );
    
typedef PTHREAD_START_ROUTINE LPTHREAD_START_ROUTINE;

typedef struct _CREATE_THREAD_DEBUG_INFO {
    HANDLE hThread;
    LPVOID lpThreadLocalBase;
    LPTHREAD_START_ROUTINE lpStartAddress;
} CREATE_THREAD_DEBUG_INFO, *LPCREATE_THREAD_DEBUG_INFO;

// CREATE_THREAD_DEBUG_INFO CreateThread;

DWORD
GetCurrentThreadId(
    VOID
    );

DWORD
WaitForSingleObject(
    HANDLE hHandle,
    DWORD dwMilliseconds
    );
]]

--[[ lib_util.lua ]]
ffi.cdef[[
static const int ENABLE_ECHO_INPUT = 0x0004;
static const int ENABLE_LINE_INPUT = 0x0002;
static const int FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000;
static const int FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200;
static const int STD_INPUT_HANDLE = ((DWORD)-10);

//new: typedef ULONG_PTR DWORD_PTR, *PDWORD_PTR;
typedef ULONG_PTR DWORD_PTR, *PDWORD_PTR;

typedef struct _SYSTEM_INFO {
    union {
        DWORD dwOemId; // Obsolete field...do not use
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

typedef union _LARGE_INTEGER {
    struct {
        DWORD LowPart;
        LONG HighPart;
    } s;
    struct {
        DWORD LowPart;
        LONG HighPart;
    } u;
    LONGLONG QuadPart;
} LARGE_INTEGER;

typedef struct _CONSOLE_READCONSOLE_CONTROL {
    ULONG nLength;
    ULONG nInitialChars;
    ULONG dwCtrlWakeupMask;
    ULONG dwControlKeyState;
} CONSOLE_READCONSOLE_CONTROL, *PCONSOLE_READCONSOLE_CONTROL;

struct timeval {
        long tv_sec; /* seconds */
        long tv_usec; /* and microseconds */
};


DWORD
FormatMessageA(
    DWORD dwFlags,
    LPCVOID lpSource,
    DWORD dwMessageId,
    DWORD dwLanguageId,
    LPSTR lpBuffer,
    DWORD nSize,
    va_list *Arguments
    );

BOOL
GetConsoleMode(
    HANDLE hConsoleHandle,
    LPDWORD lpMode
    );

HANDLE
GetStdHandle(
    DWORD nStdHandle
    );

VOID
GetSystemInfo(
    LPSYSTEM_INFO lpSystemInfo
    );

BOOL
QueryPerformanceCounter(
    LARGE_INTEGER *lpPerformanceCount
    );

BOOL
QueryPerformanceFrequency(
    LARGE_INTEGER *lpFrequency
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

VOID
Sleep(
    DWORD dwMilliseconds
    );
char * strerror( int);

BOOL
SwitchToThread(
    VOID
    );
]]

--[[ TestAddrinfo.lua ]]
ffi.cdef[[
static const int NI_MAXHOST = 1025;
static const int NI_MAXSERV = 32;
static const int NI_NAMEREQD = 0x04;
static const int NI_NUMERICHOST = 0x02;
static const int NI_NUMERICSERV = 0x08;
]]

--[[ TestAll.lua ]]
--[[ TestKqueue.lua ]]