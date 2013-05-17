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
/* 64-bit time value */
typedef __time64_t time_t;

}
static double difftime(time_t _Time1, time_t _Time2)
{
    return _difftime64(_Time1,_Time2);

/* Maximum time between read chars. */
    DWORD ReadTotalTimeoutMultiplier;
]]

--[[ lib_http.lua ]]
--[[ lib_kqueue.lua ]]
--[[ lib_poll.lua ]]
ffi.cdef[[
static const int POLLERR = 0x0001;
static const int POLLHUP = 0x0002;
static const int POLLIN = (POLLRDNORM | POLLRDBAND);
static const int POLLNVAL = 0x0004;
static const int POLLOUT = (POLLWRNORM);

typedef short SHORT;

VOID
RaiseException(
    DWORD dwExceptionCode,
    DWORD dwExceptionFlags,
    DWORD nNumberOfArguments,
    CONST ULONG_PTR *lpArguments
    );
BOOL
IsBadReadPtr(
    CONST VOID *lp,
    UINT_PTR ucb
    );
typedef UINT_PTR SOCKET;
typedef struct pollfd {
    SOCKET fd;
    SHORT events;
    SHORT revents;
} WSAPOLLFD, *PWSAPOLLFD, *LPWSAPOLLFD;
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
int
ioctlsocket(
    SOCKET s,
    long cmd,
    u_long * argp
    );
int
getpeername(
    SOCKET s,
    struct sockaddr * name,
    int * namelen
    );
int
getsockname(
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
u_long
htonl(
    u_long hostlong
    );
u_short
htons(
    u_short hostshort
    );
unsigned long
inet_addr(
    const char * cp
    );
char *
inet_ntoa(
    struct in_addr in
    );
int
listen(
    SOCKET s,
    int backlog
    );
u_long
ntohl(
    u_long netlong
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
recvfrom(
    SOCKET s,
    char * buf,
    int len,
    int flags,
    struct sockaddr * from,
    int * fromlen
    );
int
select(
    int nfds,
    fd_set * readfds,
    fd_set * writefds,
    fd_set * exceptfds,
    const struct timeval * timeout
    );
int
send(
    SOCKET s,
    const char * buf,
    int len,
    int flags
    );
int
sendto(
    SOCKET s,
    const char * buf,
    int len,
    int flags,
    const struct sockaddr * to,
    int tolen
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
struct hostent *
gethostbyaddr(
    const char * addr,
    int len,
    int type
    );
struct hostent *
gethostbyname(
    const char * name
    );
int
gethostname(
    char * name,
    int namelen
    );
struct servent *
getservbyport(
    int port,
    const char * proto
    );
struct servent *
getservbyname(
    const char * name,
    const char * proto
    );
struct protoent *
getprotobynumber(
    int number
    );
struct protoent *
getprotobyname(
    const char * name
    );
int
WSAStartup(
    WORD wVersionRequested,
    LPWSADATA lpWSAData
    );
int
WSACleanup(
    void
    );
void
WSASetLastError(
    int iError
    );
int
WSAGetLastError(
    void
    );
BOOL
WSAIsBlocking(
    void
    );
int
WSAUnhookBlockingHook(
    void
    );
WSASetBlockingHook(
    lpBlockFunc
    );
int
WSACancelBlockingCall(
    void
    );
HANDLE
WSAAsyncGetServByName(
    HWND hWnd,
    u_int wMsg,
    const char * name,
    const char * proto,
    char * buf,
    int buflen
    );
HANDLE
WSAAsyncGetServByPort(
    HWND hWnd,
    u_int wMsg,
    int port,
    const char * proto,
    char * buf,
    int buflen
    );
HANDLE
WSAAsyncGetProtoByName(
    HWND hWnd,
    u_int wMsg,
    const char * name,
    char * buf,
    int buflen
    );
HANDLE
WSAAsyncGetProtoByNumber(
    HWND hWnd,
    u_int wMsg,
    int number,
    char * buf,
    int buflen
    );
HANDLE
WSAAsyncGetHostByName(
    HWND hWnd,
    u_int wMsg,
    const char * name,
    char * buf,
    int buflen
    );
HANDLE
WSAAsyncGetHostByAddr(
    HWND hWnd,
    u_int wMsg,
    const char * addr,
    int len,
    int type,
    char * buf,
    int buflen
    );
int
WSACancelAsyncRequest(
    HANDLE hAsyncTaskHandle
    );
int
WSAAsyncSelect(
    SOCKET s,
    HWND hWnd,
    u_int wMsg,
    long lEvent
    );
SOCKET
WSAAccept(
    SOCKET s,
    struct sockaddr * addr,
    LPINT addrlen,
    LPCONDITIONPROC lpfnCondition,
    DWORD_PTR dwCallbackData
    );
BOOL
WSACloseEvent(
    HANDLE hEvent
    );
int
WSAConnect(
    SOCKET s,
    const struct sockaddr * name,
    int namelen,
    LPWSABUF lpCallerData,
    LPWSABUF lpCalleeData,
    LPQOS lpSQOS,
    LPQOS lpGQOS
    );
static const int WSAConnectByName = WSAConnectByNameA;
BOOL
WSAConnectByNameW(
    SOCKET s,
    LPWSTR nodename,
    LPWSTR servicename,
    LPDWORD LocalAddressLength,
    LPSOCKADDR LocalAddress,
    LPDWORD RemoteAddressLength,
    LPSOCKADDR RemoteAddress,
    const struct timeval * timeout,
    LPWSAOVERLAPPED Reserved);
BOOL
WSAConnectByNameA(
    SOCKET s,
    LPCSTR nodename,
    LPCSTR servicename,
    LPDWORD LocalAddressLength,
    LPSOCKADDR LocalAddress,
    LPDWORD RemoteAddressLength,
    LPSOCKADDR RemoteAddress,
    const struct timeval * timeout,
    LPWSAOVERLAPPED Reserved);
BOOL
WSAConnectByList(
    SOCKET s,
    PSOCKET_ADDRESS_LIST SocketAddress,
    LPDWORD LocalAddressLength,
    LPSOCKADDR LocalAddress,
    LPDWORD RemoteAddressLength,
    LPSOCKADDR RemoteAddress,
    const struct timeval * timeout,
    LPWSAOVERLAPPED Reserved);
HANDLE
WSACreateEvent(
    void
    );
int
WSADuplicateSocketA(
    SOCKET s,
    DWORD dwProcessId,
    LPWSAPROTOCOL_INFOA lpProtocolInfo
    );
int
WSADuplicateSocketW(
    SOCKET s,
    DWORD dwProcessId,
    LPWSAPROTOCOL_INFOW lpProtocolInfo
    );
static const int WSADuplicateSocket = WSADuplicateSocketA;
int
WSAEnumNetworkEvents(
    SOCKET s,
    HANDLE hEventObject,
    LPWSANETWORKEVENTS lpNetworkEvents
    );
int
WSAEnumProtocolsA(
    LPINT lpiProtocols,
    LPWSAPROTOCOL_INFOA lpProtocolBuffer,
    LPDWORD lpdwBufferLength
    );
int
WSAEnumProtocolsW(
    LPINT lpiProtocols,
    LPWSAPROTOCOL_INFOW lpProtocolBuffer,
    LPDWORD lpdwBufferLength
    );
static const int WSAEnumProtocols = WSAEnumProtocolsA;
int
WSAEventSelect(
    SOCKET s,
    HANDLE hEventObject,
    long lNetworkEvents
    );
BOOL
WSAGetOverlappedResult(
    SOCKET s,
    LPWSAOVERLAPPED lpOverlapped,
    LPDWORD lpcbTransfer,
    BOOL fWait,
    LPDWORD lpdwFlags
    );
BOOL
WSAGetQOSByName(
    SOCKET s,
    LPWSABUF lpQOSName,
    LPQOS lpQOS
    );
int
WSAHtonl(
    SOCKET s,
    u_long hostlong,
    u_long * lpnetlong
    );
int
WSAHtons(
    SOCKET s,
    u_short hostshort,
    u_short * lpnetshort
    );
int
WSAIoctl(
    SOCKET s,
    DWORD dwIoControlCode,
    LPVOID lpvInBuffer,
    DWORD cbInBuffer,
    LPVOID lpvOutBuffer,
    DWORD cbOutBuffer,
    LPDWORD lpcbBytesReturned,
    LPWSAOVERLAPPED lpOverlapped,
    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
    );
SOCKET
WSAJoinLeaf(
    SOCKET s,
    const struct sockaddr * name,
    int namelen,
    LPWSABUF lpCallerData,
    LPWSABUF lpCalleeData,
    LPQOS lpSQOS,
    LPQOS lpGQOS,
    DWORD dwFlags
    );
int
WSANtohl(
    SOCKET s,
    u_long netlong,
    u_long * lphostlong
    );
int
WSANtohs(
    SOCKET s,
    u_short netshort,
    u_short * lphostshort
    );
int
WSARecv(
    SOCKET s,
    LPWSABUF lpBuffers,
    DWORD dwBufferCount,
    LPDWORD lpNumberOfBytesRecvd,
    LPDWORD lpFlags,
    LPWSAOVERLAPPED lpOverlapped,
    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
    );
int
WSARecvDisconnect(
    SOCKET s,
    LPWSABUF lpInboundDisconnectData
    );
int
WSARecvFrom(
    SOCKET s,
    LPWSABUF lpBuffers,
    DWORD dwBufferCount,
    LPDWORD lpNumberOfBytesRecvd,
    LPDWORD lpFlags,
    struct sockaddr * lpFrom,
    LPINT lpFromlen,
    LPWSAOVERLAPPED lpOverlapped,
    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
    );
BOOL
WSAResetEvent(
    HANDLE hEvent
    );
int
WSASend(
    SOCKET s,
    LPWSABUF lpBuffers,
    DWORD dwBufferCount,
    LPDWORD lpNumberOfBytesSent,
    DWORD dwFlags,
    LPWSAOVERLAPPED lpOverlapped,
    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
    );
int
WSASendMsg(
    SOCKET Handle,
    LPWSAMSG lpMsg,
    DWORD dwFlags,
    LPDWORD lpNumberOfBytesSent,
    LPWSAOVERLAPPED lpOverlapped,
    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
    );
int
WSASendDisconnect(
    SOCKET s,
    LPWSABUF lpOutboundDisconnectData
    );
int
WSASendTo(
    SOCKET s,
    LPWSABUF lpBuffers,
    DWORD dwBufferCount,
    LPDWORD lpNumberOfBytesSent,
    DWORD dwFlags,
    const struct sockaddr * lpTo,
    int iTolen,
    LPWSAOVERLAPPED lpOverlapped,
    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
    );
BOOL
WSASetEvent(
    HANDLE hEvent
    );
SOCKET
WSASocketA(
    int af,
    int type,
    int protocol,
    LPWSAPROTOCOL_INFOA lpProtocolInfo,
    GROUP g,
    DWORD dwFlags
    );
SOCKET
WSASocketW(
    int af,
    int type,
    int protocol,
    LPWSAPROTOCOL_INFOW lpProtocolInfo,
    GROUP g,
    DWORD dwFlags
    );
static const int WSASocket = WSASocketA;
DWORD
WSAWaitForMultipleEvents(
    DWORD cEvents,
    const HANDLE * lphEvents,
    BOOL fWaitAll,
    DWORD dwTimeout,
    BOOL fAlertable
    );
INT
WSAAddressToStringA(
    LPSOCKADDR lpsaAddress,
    DWORD dwAddressLength,
    LPWSAPROTOCOL_INFOA lpProtocolInfo,
    LPSTR lpszAddressString,
    LPDWORD lpdwAddressStringLength
    );
INT
WSAAddressToStringW(
    LPSOCKADDR lpsaAddress,
    DWORD dwAddressLength,
    LPWSAPROTOCOL_INFOW lpProtocolInfo,
    LPWSTR lpszAddressString,
    LPDWORD lpdwAddressStringLength
    );
static const int WSAAddressToString = WSAAddressToStringA;
INT
WSAStringToAddressA(
    LPSTR AddressString,
    INT AddressFamily,
    LPWSAPROTOCOL_INFOA lpProtocolInfo,
    LPSOCKADDR lpAddress,
    LPINT lpAddressLength
    );
INT
WSAStringToAddressW(
    LPWSTR AddressString,
    INT AddressFamily,
    LPWSAPROTOCOL_INFOW lpProtocolInfo,
    LPSOCKADDR lpAddress,
    LPINT lpAddressLength
    );
static const int WSAStringToAddress = WSAStringToAddressA;
INT
WSALookupServiceBeginA(
    LPWSAQUERYSETA lpqsRestrictions,
    DWORD dwControlFlags,
    LPHANDLE lphLookup
    );
INT
WSALookupServiceBeginW(
    LPWSAQUERYSETW lpqsRestrictions,
    DWORD dwControlFlags,
    LPHANDLE lphLookup
    );
static const int WSALookupServiceBegin = WSALookupServiceBeginA;
INT
WSALookupServiceNextA(
    HANDLE hLookup,
    DWORD dwControlFlags,
    LPDWORD lpdwBufferLength,
    LPWSAQUERYSETA lpqsResults
    );
INT
WSALookupServiceNextW(
    HANDLE hLookup,
    DWORD dwControlFlags,
    LPDWORD lpdwBufferLength,
    LPWSAQUERYSETW lpqsResults
    );
static const int WSALookupServiceNext = WSALookupServiceNextA;
INT
WSANSPIoctl(
    HANDLE hLookup,
    DWORD dwControlCode,
    LPVOID lpvInBuffer,
    DWORD cbInBuffer,
    LPVOID lpvOutBuffer,
    DWORD cbOutBuffer,
    LPDWORD lpcbBytesReturned,
    LPWSACOMPLETION lpCompletion
    );
INT
WSALookupServiceEnd(
    HANDLE hLookup
    );
INT
WSAInstallServiceClassA(
    LPWSASERVICECLASSINFOA lpServiceClassInfo
    );
INT
WSAInstallServiceClassW(
    LPWSASERVICECLASSINFOW lpServiceClassInfo
    );
static const int WSAInstallServiceClass = WSAInstallServiceClassA;
INT
WSARemoveServiceClass(
    LPGUID lpServiceClassId
    );
INT
WSAGetServiceClassInfoA(
    LPGUID lpProviderId,
    LPGUID lpServiceClassId,
    LPDWORD lpdwBufSize,
    LPWSASERVICECLASSINFOA lpServiceClassInfo
    );
INT
WSAGetServiceClassInfoW(
    LPGUID lpProviderId,
    LPGUID lpServiceClassId,
    LPDWORD lpdwBufSize,
    LPWSASERVICECLASSINFOW lpServiceClassInfo
    );
static const int WSAGetServiceClassInfo = WSAGetServiceClassInfoA;
INT
WSAEnumNameSpaceProvidersA(
    LPDWORD lpdwBufferLength,
    LPWSANAMESPACE_INFOA lpnspBuffer
    );
INT
WSAEnumNameSpaceProvidersW(
    LPDWORD lpdwBufferLength,
    LPWSANAMESPACE_INFOW lpnspBuffer
    );
static const int WSAEnumNameSpaceProviders = WSAEnumNameSpaceProvidersA;
INT
WSAEnumNameSpaceProvidersExA(
    LPDWORD lpdwBufferLength,
    LPWSANAMESPACE_INFOEXA lpnspBuffer
    );
INT
WSAEnumNameSpaceProvidersExW(
    LPDWORD lpdwBufferLength,
    LPWSANAMESPACE_INFOEXW lpnspBuffer
    );
static const int WSAEnumNameSpaceProvidersEx = WSAEnumNameSpaceProvidersExA;
 INT
WSAGetServiceClassNameByClassIdA(
    LPGUID lpServiceClassId,
    LPSTR lpszServiceClassName,
    LPDWORD lpdwBufferLength
    );
 INT
WSAGetServiceClassNameByClassIdW(
    LPGUID lpServiceClassId,
    LPWSTR lpszServiceClassName,
    LPDWORD lpdwBufferLength
    );
static const int WSAGetServiceClassNameByClassId = WSAGetServiceClassNameByClassIdA;
INT
WSASetServiceA(
    LPWSAQUERYSETA lpqsRegInfo,
    WSAESETSERVICEOP essoperation,
    DWORD dwControlFlags
    );
INT
WSASetServiceW(
    LPWSAQUERYSETW lpqsRegInfo,
    WSAESETSERVICEOP essoperation,
    DWORD dwControlFlags
    );
static const int WSASetService = WSASetServiceA;
INT
WSAProviderConfigChange(
    LPHANDLE lpNotificationHandle,
    LPWSAOVERLAPPED lpOverlapped,
    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
    );
int
WSAPoll(
    LPWSAPOLLFD fdArray,
    ULONG fds,
    INT timeout
    );
typedef struct sockaddr_in *LPSOCKADDR_IN;
typedef struct linger LINGER;
typedef struct linger *PLINGER;
typedef struct linger *LPLINGER;
typedef struct fd_set FD_SET;
typedef struct fd_set *PFD_SET;
typedef struct fd_set *LPFD_SET;
typedef struct hostent HOSTENT;
typedef struct hostent *PHOSTENT;
typedef struct hostent *LPHOSTENT;
typedef struct servent SERVENT;
typedef struct servent *PSERVENT;
typedef struct servent *LPSERVENT;
typedef struct protoent PROTOENT;
typedef struct protoent *PPROTOENT;
typedef struct protoent *LPPROTOENT;
typedef struct timeval TIMEVAL;
typedef struct timeval *PTIMEVAL;
typedef struct timeval *LPTIMEVAL;
static const int WSAMAKEASYNCREPLY(buflen,error) = MAKELONG(buflen,error);
static const int WSAMAKESELECTREPLY(event,error) = MAKELONG(event,error);
static const int WSAGETASYNCBUFLEN(lParam) = LOWORD(lParam);
static const int WSAGETASYNCERROR(lParam) = HIWORD(lParam);
static const int WSAGETSELECTEVENT(lParam) = LOWORD(lParam);
static const int WSAGETSELECTERROR(lParam) = HIWORD(lParam);
static const int WS2IPDEF_ASSERT(exp) = ((VOID) 0);
static const int WS2TCPIP_INLINE = inline;
typedef struct in6_addr {
    union {
        UCHAR Byte[16];
        USHORT Word[8];
    } u;
} IN6_ADDR, *PIN6_ADDR, *LPIN6_ADDR;
static const int in_addr6 = in6_addr;
static const int _S6_un = u;
static const int _S6_u8 = Byte;
static const int s6_addr = _S6_un._S6_u8;
static const int s6_bytes = u.Byte;
static const int s6_words = u.Word;
typedef union _SOCKADDR_INET {
    SOCKADDR_IN Ipv4;
    SOCKADDR_IN6 Ipv6;
    ADDRESS_FAMILY si_family;
} SOCKADDR_INET, *PSOCKADDR_INET;
typedef struct _sockaddr_in6_pair
{
    PSOCKADDR_IN6 SourceAddress;
    PSOCKADDR_IN6 DestinationAddress;
} SOCKADDR_IN6_PAIR, *PSOCKADDR_IN6_PAIR;
static const int SS_PORT(ssp) = (((PSOCKADDR_IN)(ssp))->sin_port);
static const int IN6ADDR_ANY_INIT = { 0 };

void free( void * _Memory);

void * realloc( void * _Memory, size_t _NewSize);
]]

--[[ lib_shared_memory.lua ]]
ffi.cdef[[
HGLOBAL
GlobalHandle (
    LPCVOID pMem
    );
HGLOBAL
GlobalAlloc (
    UINT uFlags,
    SIZE_T dwBytes
    );
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
typedef char CHAR;
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

typedef const CHAR *LPCSTR, *PCSTR;
typedef CHAR *PCHAR, *LPCH, *PCH;
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
typedef struct WSAData {
        WORD wVersion;
        WORD wHighVersion;
        unsigned short iMaxSockets;
        unsigned short iMaxUdpDg;
        char * lpVendorInfo;
        char szDescription[256 +1];
        char szSystemStatus[128 +1];
} WSADATA, * LPWSADATA;
BOOL
GetNamedPipeAttribute(
    HANDLE Pipe,
    PIPE_ATTRIBUTE_TYPE AttributeType,
    PSTR AttributeName,
    PVOID AttributeValue,
    PSIZE_T AttributeValueLength
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

PCSTR
inet_ntop(
    INT Family,
    PVOID pAddr,
    PSTR pStringBuf,
    size_t StringBufSize
    );
]]

--[[ lib_tcp.lua ]]
ffi.cdef[[
static const int INET6_ADDRSTRLEN = 65;
static const int INET_ADDRSTRLEN = 22;
static const int SO_RCVBUF = 0x1002;
static const int SO_REUSEADDR = 0x0004;
static const int SO_SNDBUF = 0x1001;
static const int SO_USELOOPBACK = 0x0040;
static const int SOCK_STREAM = 1;
static const int SOL_SOCKET = 0xffff;
static const int SOMAXCONN = 0x7fffffff;

typedef enum _RTL_UMS_THREAD_INFO_CLASS UMS_THREAD_INFO_CLASS, *PUMS_THREAD_INFO_CLASS;
typedef struct sockaddr_storage {
    ADDRESS_FAMILY ss_family; // address family
    CHAR __ss_pad1[((sizeof(t64)) - sizeof(USHORT))]; // 6 byte pad, this is to make
    t64 __ss_align; // Field to force desired structure
    CHAR __ss_pad2[(128 - (sizeof(USHORT) + ((sizeof(t64)) - sizeof(USHORT)) + (sizeof(t64))))]; // 112 byte pad to achieve desired size;
} SOCKADDR_STORAGE_LH, *PSOCKADDR_STORAGE_LH, *LPSOCKADDR_STORAGE_LH;
typedef struct sockaddr_storage_xp {
    short ss_family; // Address family.
    CHAR __ss_pad1[((sizeof(t64)) - sizeof(USHORT))]; // 6 byte pad, this is to make
    t64 __ss_align; // Field to force desired structure
    CHAR __ss_pad2[(128 - (sizeof(USHORT) + ((sizeof(t64)) - sizeof(USHORT)) + (sizeof(t64))))]; // 112 byte pad to achieve desired size;
} SOCKADDR_STORAGE_XP, *PSOCKADDR_STORAGE_XP, *LPSOCKADDR_STORAGE_XP;
typedef SOCKADDR_STORAGE_LH SOCKADDR_STORAGE;
typedef SOCKADDR_STORAGE *PSOCKADDR_STORAGE, *LPSOCKADDR_STORAGE;
static const int IOC_UNIX = 0x00000000;
static const int IOC_WS2 = 0x08000000;
static const int IOC_PROTOCOL = 0x10000000;
static const int IOC_VENDOR = 0x18000000;
static const int IOC_WSK = (IOC_WS2|0x07000000);
static const int _WSAIO(x,y) = (IOC_VOID|(x)|(y));
static const int _WSAIOR(x,y) = (IOC_OUT|(x)|(y));
static const int _WSAIOW(x,y) = (IOC_IN|(x)|(y));
static const int _WSAIORW(x,y) = (IOC_INOUT|(x)|(y));
static const int SIO_ASSOCIATE_HANDLE = _WSAIOW(IOC_WS2,1);
static const int SIO_ENABLE_CIRCULAR_QUEUEING = _WSAIO(IOC_WS2,2);
static const int SIO_FIND_ROUTE = _WSAIOR(IOC_WS2,3);
static const int SIO_FLUSH = _WSAIO(IOC_WS2,4);
static const int SIO_GET_BROADCAST_ADDRESS = _WSAIOR(IOC_WS2,5);
static const int SIO_GET_EXTENSION_FUNCTION_POINTER = _WSAIORW(IOC_WS2,6);
static const int SIO_GET_QOS = _WSAIORW(IOC_WS2,7);
static const int SIO_GET_GROUP_QOS = _WSAIORW(IOC_WS2,8);
static const int SIO_MULTIPOINT_LOOPBACK = _WSAIOW(IOC_WS2,9);
static const int SIO_MULTICAST_SCOPE = _WSAIOW(IOC_WS2,10);
static const int SIO_SET_QOS = _WSAIOW(IOC_WS2,11);
static const int SIO_SET_GROUP_QOS = _WSAIOW(IOC_WS2,12);
static const int SIO_TRANSLATE_HANDLE = _WSAIORW(IOC_WS2,13);
static const int SIO_ROUTING_INTERFACE_QUERY = _WSAIORW(IOC_WS2,20);
static const int SIO_ROUTING_INTERFACE_CHANGE = _WSAIOW(IOC_WS2,21);
static const int SIO_ADDRESS_LIST_QUERY = _WSAIOR(IOC_WS2,22);
static const int SIO_ADDRESS_LIST_CHANGE = _WSAIO(IOC_WS2,23);
static const int SIO_QUERY_TARGET_PNP_HANDLE = _WSAIOR(IOC_WS2,24);
static const int SIO_ADDRESS_LIST_SORT = _WSAIORW(IOC_WS2,25);
static const int SIO_RESERVED_1 = _WSAIOW(IOC_WS2,26);
static const int SIO_RESERVED_2 = _WSAIOW(IOC_WS2,33);
static const int IPPROTO_IP = 0;
typedef enum {
    IPPROTO_HOPOPTS = 0, // IPv6 Hop-by-Hop options
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
    IPPROTO_IPV6 = 41, // IPv6 header
    IPPROTO_ROUTING = 43, // IPv6 Routing header
    IPPROTO_FRAGMENT = 44, // IPv6 fragmentation header
    IPPROTO_ESP = 50, // encapsulating security payload
    IPPROTO_AH = 51, // authentication header
    IPPROTO_ICMPV6 = 58, // ICMPv6
    IPPROTO_NONE = 59, // IPv6 no next header
    IPPROTO_DSTOPTS = 60, // IPv6 Destination options
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
static const int IPPORT_TCPMUX = 1;
static const int IPPORT_ECHO = 7;
static const int IPPORT_DISCARD = 9;
static const int IPPORT_SYSTAT = 11;
static const int IPPORT_DAYTIME = 13;
static const int IPPORT_NETSTAT = 15;
static const int IPPORT_QOTD = 17;
static const int IPPORT_MSP = 18;
static const int IPPORT_CHARGEN = 19;
static const int IPPORT_FTP_DATA = 20;
static const int IPPORT_FTP = 21;
static const int IPPORT_TELNET = 23;
static const int IPPORT_SMTP = 25;
static const int IPPORT_TIMESERVER = 37;
static const int IPPORT_NAMESERVER = 42;
static const int IPPORT_WHOIS = 43;
static const int IPPORT_MTP = 57;
static const int IPPORT_TFTP = 69;
static const int IPPORT_RJE = 77;
static const int IPPORT_FINGER = 79;
static const int IPPORT_TTYLINK = 87;
static const int IPPORT_SUPDUP = 95;
static const int IPPORT_POP3 = 110;
static const int IPPORT_NTP = 123;
static const int IPPORT_EPMAP = 135;
static const int IPPORT_NETBIOS_NS = 137;
static const int IPPORT_NETBIOS_DGM = 138;
static const int IPPORT_NETBIOS_SSN = 139;
static const int IPPORT_IMAP = 143;
static const int IPPORT_SNMP = 161;
static const int IPPORT_SNMP_TRAP = 162;
static const int IPPORT_IMAP3 = 220;
static const int IPPORT_LDAP = 389;
static const int IPPORT_HTTPS = 443;
static const int IPPORT_MICROSOFT_DS = 445;
static const int IPPORT_EXECSERVER = 512;
static const int IPPORT_LOGINSERVER = 513;
static const int IPPORT_CMDSERVER = 514;
static const int IPPORT_EFSSERVER = 520;
static const int IPPORT_BIFFUDP = 512;
static const int IPPORT_WHOSERVER = 513;
static const int IPPORT_ROUTESERVER = 520;
static const int IPPORT_RESERVED = 1024;
static const int IPPORT_REGISTERED_MIN = IPPORT_RESERVED;
static const int IPPORT_REGISTERED_MAX = 0xbfff;
static const int IPPORT_DYNAMIC_MIN = 0xc000;
static const int IPPORT_DYNAMIC_MAX = 0xffff;
static const int IN_CLASSA(i) = (((LONG)(i) & 0x80000000) == 0);
static const int IN_CLASSA_NET = 0xff000000;
static const int IN_CLASSA_NSHIFT = 24;
static const int IN_CLASSA_HOST = 0x00ffffff;
static const int IN_CLASSA_MAX = 128;
static const int IN_CLASSB(i) = (((LONG)(i) & 0xc0000000) == 0x80000000);
static const int IN_CLASSB_NET = 0xffff0000;
static const int IN_CLASSB_NSHIFT = 16;
static const int IN_CLASSB_HOST = 0x0000ffff;
static const int IN_CLASSB_MAX = 65536;
static const int IN_CLASSC(i) = (((LONG)(i) & 0xe0000000) == 0xc0000000);
static const int IN_CLASSC_NET = 0xffffff00;
static const int IN_CLASSC_NSHIFT = 8;
static const int IN_CLASSC_HOST = 0x000000ff;
static const int IN_CLASSD(i) = (((long)(i) & 0xf0000000) == 0xe0000000);
static const int IN_CLASSD_NET = 0xf0000000;
static const int IN_CLASSD_NSHIFT = 28;
static const int IN_CLASSD_HOST = 0x0fffffff;
static const int IN_MULTICAST(i) = IN_CLASSD(i);
static const int INADDR_ANY = (ULONG)0x00000000;
static const int INADDR_LOOPBACK = 0x7f000001;
static const int INADDR_BROADCAST = (ULONG)0xffffffff;
static const int INADDR_NONE = 0xffffffff;
typedef enum {
    ScopeLevelInterface = 1,
    ScopeLevelLink = 2,
    ScopeLevelSubnet = 3,
    ScopeLevelAdmin = 4,
    ScopeLevelSite = 5,
    ScopeLevelOrganization = 8,
    ScopeLevelGlobal = 14,
    ScopeLevelCount = 16
} SCOPE_LEVEL;
typedef struct {
    union {
        struct {
            ULONG Zone : 28;
            ULONG Level : 4;
        };
const IN_ADDR in4addr_any;

typedef enum {
    IPPROTO_HOPOPTS = 0, // IPv6 Hop-by-Hop options
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
    IPPROTO_IPV6 = 41, // IPv6 header
    IPPROTO_ROUTING = 43, // IPv6 Routing header
    IPPROTO_FRAGMENT = 44, // IPv6 fragmentation header
    IPPROTO_ESP = 50, // encapsulating security payload
    IPPROTO_AH = 51, // authentication header
    IPPROTO_ICMPV6 = 58, // ICMPv6
    IPPROTO_NONE = 59, // IPv6 no next header
    IPPROTO_DSTOPTS = 60, // IPv6 Destination options
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

IN6_SET_ADDR_UNSPECIFIED(&a->sin6_addr);

a->sin6_port = 0;

IN_ADDR sin_addr;
]]

--[[ lib_thread.lua ]]
ffi.cdef[[
static const int INFINITE = 0xFFFFFFFF;

typedef DWORD (*PTHREAD_START_ROUTINE)(
    LPVOID lpThreadParameter
    );
typedef PTHREAD_START_ROUTINE LPTHREAD_START_ROUTINE;
typedef struct _CREATE_THREAD_DEBUG_INFO {
    HANDLE hThread;
    LPVOID lpThreadLocalBase;
    LPTHREAD_START_ROUTINE lpStartAddress;
} CREATE_THREAD_DEBUG_INFO, *LPCREATE_THREAD_DEBUG_INFO;

CREATE_THREAD_DEBUG_INFO CreateThread;

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

BOOL
SetFilePointerEx(
    HANDLE hFile,
    LARGE_INTEGER liDistanceToMove,
    PLARGE_INTEGER lpNewFilePointer,
    DWORD dwMoveMethod
    );
typedef struct _CONSOLE_READCONSOLE_CONTROL {
    ULONG nLength;
    ULONG nInitialChars;
    ULONG dwCtrlWakeupMask;
    ULONG dwControlKeyState;
} CONSOLE_READCONSOLE_CONTROL, *PCONSOLE_READCONSOLE_CONTROL;
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

) char * strerror( int);

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
--[[ TestLinux.lua ]]
--[[ TestSharedMemory.lua ]]
--[[ TestSignal.lua ]]
--[[ TestSignal_bad.lua ]]
--[[ TestSocket.lua ]]
ffi.cdef[[
static const int SD_SEND = 0x01;
]]

--[[ TestThread.lua ]]

--[[
not found calls = {
   [1] = "--- lib_date_time.lua ---";
   [2] = "--- lib_http.lua ---";
   [3] = "--- lib_kqueue.lua ---";
   [4] = "--- lib_poll.lua ---";
   [5] = "--- lib_shared_memory.lua ---";
   [6] = "close";
   [7] = "ftruncate";
   [8] = "MAP_SHARED";
   [9] = "mmap";
   [10] = "munmap";
   [11] = "O_CREAT";
   [12] = "O_RDONLY";
   [13] = "O_RDWR";
   [14] = "PROT_READ";
   [15] = "PROT_WRITE";
   [16] = "shm_open";
   [17] = "shm_unlink";
   [18] = "--- lib_signal.lua ---";
   [19] = "getpid";
   [20] = "kill";
   [21] = "pthread_sigmask";
   [22] = "sigaddset";
   [23] = "sigemptyset";
   [24] = "sigwait";
   [25] = "--- lib_socket.lua ---";
   [26] = "close";
   [27] = "F_GETFL";
   [28] = "F_SETFL";
   [29] = "fcntl";
   [30] = "gai_strerror";
   [31] = "O_NONBLOCK";
   [32] = "poll";
   [33] = "--- lib_tcp.lua ---";
   [34] = "AF_INET";
   [35] = "AF_INET6";
   [36] = "TCP_NODELAY";
   [37] = "--- lib_thread.lua ---";
   [38] = "pthread_create";
   [39] = "pthread_exit";
   [40] = "pthread_join";
   [41] = "pthread_self";
   [42] = "--- lib_util.lua ---";
   [43] = "_SC_NPROCESSORS_CONF";
   [44] = "_SC_NPROCESSORS_ONLN";
   [45] = "gettimeofday";
   [46] = "nanosleep";
   [47] = "sched_yield";
   [48] = "sysconf";
   [49] = "usleep";
   [50] = "--- TestAddrinfo.lua ---";
   [51] = "AF_INET";
   [52] = "--- TestAll.lua ---";
   [53] = "--- TestKqueue.lua ---";
   [54] = "close";
   [55] = "EV_ADD";
   [56] = "EV_ENABLE";
   [57] = "EV_ONESHOT";
   [58] = "EVFILT_VNODE";
   [59] = "kevent";
   [60] = "kqueue";
   [61] = "NOTE_ATTRIB";
   [62] = "NOTE_DELETE";
   [63] = "NOTE_EXTEND";
   [64] = "NOTE_WRITE";
   [65] = "O_RDONLY";
   [66] = "open";
   [67] = "--- TestLinux.lua ---";
   [68] = "mmap";
   [69] = "munmap";
   [70] = "O_CREAT";
   [71] = "O_EXCL";
   [72] = "shm_open";
   [73] = "shm_unlink";
   [74] = "--- TestSharedMemory.lua ---";
   [75] = "--- TestSignal.lua ---";
   [76] = "--- TestSignal_bad.lua ---";
   [77] = "getpid";
   [78] = "kill";
   [79] = "pause";
   [80] = "signal";
   [81] = "--- TestSocket.lua ---";
   [82] = "--- TestThread.lua ---";
};
]]

--[[
not found basic types = {
   [1] = "}static";
   [2] = "kevent";
   [3] = "sigset_t";
   [4] = "WSADATA64";
   [5] = "sockaddr_in6";
   [6] = "IN6_SET_ADDR_UNSPECIFIED(&a-";
   [7] = "&a->sin6_addr";
   [8] = "pthread_t";
   [9] = "thread_func";
   [10] = "timespec";
};
]]