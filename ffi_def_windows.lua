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
	// bad on ugly define macros, done by hand
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
#pragma warning(pop)
#pragma once
static __inline double difftime(time_t _Time1, time_t _Time2)
{
    return _difftime64(_Time1,_Time2);
	}
static __inline time_t time(time_t * _Time)
{
    return _time64(_Time);
]]

--[[ lib_http.lua ]]
--[[ lib_kqueue.lua ]]
--[[ lib_poll.lua ]]
ffi.cdef[[
	typedef short SHORT;
	
	#pragma warning(pop)
	typedef UINT_PTR        SOCKET;
	typedef struct pollfd {
	    SOCKET  fd;
	    SHORT   events;
	    SHORT   revents;
	} WSAPOLLFD, *PWSAPOLLFD,  *LPWSAPOLLFD;
	__declspec(dllimport)
	SOCKET
	 __stdcall
	accept(
	     SOCKET s,
	     struct sockaddr  * addr,
	     int  * addrlen
	    );
	__declspec(dllimport)
	int
	 __stdcall
	bind(
	     SOCKET s,
	     const struct sockaddr  * name,
	     int namelen
	    );
	__declspec(dllimport)
	int
	 __stdcall
	closesocket(
	     SOCKET s
	    );
	__declspec(dllimport)
	int
	 __stdcall
	connect(
	     SOCKET s,
	     const struct sockaddr  * name,
	     int namelen
	    );
	__declspec(dllimport)
	int
	 __stdcall
	ioctlsocket(
	     SOCKET s,
	     long cmd,
	     u_long  * argp
	    );
	__declspec(dllimport)
	int
	 __stdcall
	getpeername(
	     SOCKET s,
	     struct sockaddr  * name,
	     int  * namelen
	    );
	__declspec(dllimport)
	int
	 __stdcall
	getsockname(
	     SOCKET s,
	     struct sockaddr  * name,
	     int  * namelen
	    );
	__declspec(dllimport)
	int
	 __stdcall
	getsockopt(
	     SOCKET s,
	     int level,
	     int optname,
	     char  * optval,
	     int  * optlen
	    );
	__declspec(dllimport)
	u_long
	 __stdcall
	htonl(
	     u_long hostlong
	    );
	__declspec(dllimport)
	u_short
	 __stdcall
	htons(
	     u_short hostshort
	    );
	__declspec(dllimport)
	unsigned long
	 __stdcall
	inet_addr(
	      const char  * cp
	    );
	__declspec(dllimport)
	char  *
	 __stdcall
	inet_ntoa(
	     struct in_addr in
	    );
	__declspec(dllimport)
	int
	 __stdcall
	listen(
	     SOCKET s,
	     int backlog
	    );
	__declspec(dllimport)
	u_long
	 __stdcall
	ntohl(
	     u_long netlong
	    );
	__declspec(dllimport)
	u_short
	 __stdcall
	ntohs(
	     u_short netshort
	    );
	__declspec(dllimport)
	int
	 __stdcall
	recv(
	     SOCKET s,
	      char  * buf,
	     int len,
	     int flags
	    );
	 __declspec(dllimport)
	int
	 __stdcall
	recvfrom(
	     SOCKET s,
	      char  * buf,
	     int len,
	     int flags,
	     struct sockaddr  * from,
	     int  * fromlen
	    );
	__declspec(dllimport)
	int
	 __stdcall
	select(
	     int nfds,
	     fd_set  * readfds,
	     fd_set  * writefds,
	     fd_set  * exceptfds,
	     const struct timeval  * timeout
	    );
	__declspec(dllimport)
	int
	 __stdcall
	send(
	     SOCKET s,
	     const char  * buf,
	     int len,
	     int flags
	    );
	__declspec(dllimport)
	int
	 __stdcall
	sendto(
	     SOCKET s,
	     const char  * buf,
	     int len,
	     int flags,
	     const struct sockaddr  * to,
	     int tolen
	    );
	__declspec(dllimport)
	int
	 __stdcall
	setsockopt(
	     SOCKET s,
	     int level,
	     int optname,
	     const char  * optval,
	     int optlen
	    );
	__declspec(dllimport)
	int
	 __stdcall
	shutdown(
	     SOCKET s,
	     int how
	    );
	__declspec(dllimport)
	SOCKET
	 __stdcall
	socket(
	     int af,
	     int type,
	     int protocol
	    );
	__declspec(dllimport)
	struct hostent  *
	 __stdcall
	gethostbyaddr(
	     const char  * addr,
	     int len,
	     int type
	    );
	__declspec(dllimport)
	struct hostent  *
	 __stdcall
	gethostbyname(
	     const char  * name
	    );
	__declspec(dllimport)
	int
	 __stdcall
	gethostname(
	     char  * name,
	     int namelen
	    );
	__declspec(dllimport)
	struct servent  *
	 __stdcall
	getservbyport(
	     int port,
	     const char  * proto
	    );
	__declspec(dllimport)
	struct servent  *
	 __stdcall
	getservbyname(
	     const char  * name,
	     const char  * proto
	    );
	__declspec(dllimport)
	struct protoent  *
	 __stdcall
	getprotobynumber(
	     int number
	    );
	__declspec(dllimport)
	struct protoent  *
	 __stdcall
	getprotobyname(
	     const char  * name
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSAStartup(
	     WORD wVersionRequested,
	     LPWSADATA lpWSAData
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSACleanup(
	    void
	    );
	__declspec(dllimport)
	void
	 __stdcall
	WSASetLastError(
	     int iError
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSAGetLastError(
	    void
	    );
	__declspec(dllimport)
	BOOL
	 __stdcall
	WSAIsBlocking(
	    void
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSAUnhookBlockingHook(
	    void
	    );
	__declspec(dllimport)
	FARPROC
	 __stdcall
	WSASetBlockingHook(
	     FARPROC lpBlockFunc
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSACancelBlockingCall(
	    void
	    );
	 __declspec(dllimport)
	HANDLE
	 __stdcall
	WSAAsyncGetServByName(
	     HWND hWnd,
	     u_int wMsg,
	     const char  * name,
	     const char  * proto,
	     char  * buf,
	     int buflen
	    );
	 __declspec(dllimport)
	HANDLE
	 __stdcall
	WSAAsyncGetServByPort(
	     HWND hWnd,
	     u_int wMsg,
	     int port,
	     const char  * proto,
	     char  * buf,
	     int buflen
	    );
	 __declspec(dllimport)
	HANDLE
	 __stdcall
	WSAAsyncGetProtoByName(
	     HWND hWnd,
	     u_int wMsg,
	     const char  * name,
	     char  * buf,
	     int buflen
	    );
	 __declspec(dllimport)
	HANDLE
	 __stdcall
	WSAAsyncGetProtoByNumber(
	     HWND hWnd,
	     u_int wMsg,
	     int number,
	     char  * buf,
	     int buflen
	    );
	 __declspec(dllimport)
	HANDLE
	 __stdcall
	WSAAsyncGetHostByName(
	     HWND hWnd,
	     u_int wMsg,
	     const char  * name,
	     char  * buf,
	     int buflen
	    );
	 __declspec(dllimport)
	HANDLE
	 __stdcall
	WSAAsyncGetHostByAddr(
	     HWND hWnd,
	     u_int wMsg,
	     const char  * addr,
	     int len,
	     int type,
	     char  * buf,
	     int buflen
	    );
	 __declspec(dllimport)
	int
	 __stdcall
	WSACancelAsyncRequest(
	     HANDLE hAsyncTaskHandle
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSAAsyncSelect(
	     SOCKET s,
	     HWND hWnd,
	     u_int wMsg,
	     long lEvent
	    );
	__declspec(dllimport)
	SOCKET
	 __stdcall
	WSAAccept(
	     SOCKET s,
	     struct sockaddr  * addr,
	     LPINT addrlen,
	     LPCONDITIONPROC lpfnCondition,
	     DWORD_PTR dwCallbackData
	    );
	__declspec(dllimport)
	BOOL
	 __stdcall
	WSACloseEvent(
	     HANDLE hEvent
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSAConnect(
	     SOCKET s,
	     const struct sockaddr  * name,
	     int namelen,
	     LPWSABUF lpCallerData,
	     LPWSABUF lpCalleeData,
	     LPQOS lpSQOS,
	     LPQOS lpGQOS
	    );
	BOOL
	__stdcall
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
	__stdcall
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
	__stdcall
	WSAConnectByList(
	     SOCKET s,
	     PSOCKET_ADDRESS_LIST SocketAddress,
	     LPDWORD LocalAddressLength,
	     LPSOCKADDR LocalAddress,
	     LPDWORD RemoteAddressLength,
	     LPSOCKADDR RemoteAddress,
	     const struct timeval * timeout,
	     LPWSAOVERLAPPED Reserved);
	__declspec(dllimport)
	HANDLE
	 __stdcall
	WSACreateEvent(
	    void
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSADuplicateSocketA(
	     SOCKET s,
	     DWORD dwProcessId,
	     LPWSAPROTOCOL_INFOA lpProtocolInfo
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSADuplicateSocketW(
	     SOCKET s,
	     DWORD dwProcessId,
	     LPWSAPROTOCOL_INFOW lpProtocolInfo
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSAEnumNetworkEvents(
	     SOCKET s,
	     HANDLE hEventObject,
	     LPWSANETWORKEVENTS lpNetworkEvents
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSAEnumProtocolsA(
	     LPINT lpiProtocols,
	     LPWSAPROTOCOL_INFOA lpProtocolBuffer,
	     LPDWORD lpdwBufferLength
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSAEnumProtocolsW(
	     LPINT lpiProtocols,
	     LPWSAPROTOCOL_INFOW lpProtocolBuffer,
	     LPDWORD lpdwBufferLength
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSAEventSelect(
	     SOCKET s,
	     HANDLE hEventObject,
	     long lNetworkEvents
	    );
	__declspec(dllimport)
	BOOL
	 __stdcall
	WSAGetOverlappedResult(
	     SOCKET s,
	     LPWSAOVERLAPPED lpOverlapped,
	     LPDWORD lpcbTransfer,
	     BOOL fWait,
	     LPDWORD lpdwFlags
	    );
	__declspec(dllimport)
	BOOL
	 __stdcall
	WSAGetQOSByName(
	     SOCKET s,
	     LPWSABUF lpQOSName,
	     LPQOS lpQOS
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSAHtonl(
	      SOCKET s,
	      u_long hostlong,
	      u_long  * lpnetlong
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSAHtons(
	      SOCKET s,
	      u_short hostshort,
	      u_short  * lpnetshort
	    );
	 __declspec(dllimport)
	int
	 __stdcall
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
	 __declspec(dllimport)
	SOCKET
	 __stdcall
	WSAJoinLeaf(
	     SOCKET s,
	     const struct sockaddr  * name,
	     int namelen,
	     LPWSABUF lpCallerData,
	     LPWSABUF lpCalleeData,
	     LPQOS lpSQOS,
	     LPQOS lpGQOS,
	     DWORD dwFlags
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSANtohl(
	     SOCKET s,
	     u_long netlong,
	     u_long  * lphostlong
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSANtohs(
	     SOCKET s,
	     u_short netshort,
	     u_short  * lphostshort
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSARecv(
	     SOCKET s,
	      LPWSABUF lpBuffers,
	     DWORD dwBufferCount,
	     LPDWORD lpNumberOfBytesRecvd,
	     LPDWORD lpFlags,
	     LPWSAOVERLAPPED lpOverlapped,
	     LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSARecvDisconnect(
	     SOCKET s,
	      LPWSABUF lpInboundDisconnectData
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSARecvFrom(
	     SOCKET s,
	      LPWSABUF lpBuffers,
	     DWORD dwBufferCount,
	     LPDWORD lpNumberOfBytesRecvd,
	     LPDWORD lpFlags,
	     struct sockaddr  * lpFrom,
	     LPINT lpFromlen,
	     LPWSAOVERLAPPED lpOverlapped,
	     LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
	    );
	__declspec(dllimport)
	BOOL
	 __stdcall
	WSAResetEvent(
	     HANDLE hEvent
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSASend(
	     SOCKET s,
	     LPWSABUF lpBuffers,
	     DWORD dwBufferCount,
	     LPDWORD lpNumberOfBytesSent,
	     DWORD dwFlags,
	     LPWSAOVERLAPPED lpOverlapped,
	     LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
	    );
	__declspec(dllimport)
	int 
	 __stdcall 
	WSASendMsg(
	     SOCKET Handle,
	     LPWSAMSG lpMsg,
	     DWORD dwFlags,
	     LPDWORD lpNumberOfBytesSent,
	     LPWSAOVERLAPPED lpOverlapped,
	     LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSASendDisconnect(
	     SOCKET s,
	     LPWSABUF lpOutboundDisconnectData
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSASendTo(
	     SOCKET s,
	     LPWSABUF lpBuffers,
	     DWORD dwBufferCount,
	     LPDWORD lpNumberOfBytesSent,
	     DWORD dwFlags,
	     const struct sockaddr  * lpTo,
	     int iTolen,
	     LPWSAOVERLAPPED lpOverlapped,
	     LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
	    );
	__declspec(dllimport)
	BOOL
	 __stdcall
	WSASetEvent(
	     HANDLE hEvent
	    );
	__declspec(dllimport)
	SOCKET
	 __stdcall
	WSASocketA(
	     int af,
	     int type,
	     int protocol,
	     LPWSAPROTOCOL_INFOA lpProtocolInfo,
	     GROUP g,
	     DWORD dwFlags
	    );
	__declspec(dllimport)
	SOCKET
	 __stdcall
	WSASocketW(
	     int af,
	     int type,
	     int protocol,
	     LPWSAPROTOCOL_INFOW lpProtocolInfo,
	     GROUP g,
	     DWORD dwFlags
	    );
	__declspec(dllimport)
	DWORD
	 __stdcall
	WSAWaitForMultipleEvents(
	     DWORD cEvents,
	     const HANDLE  * lphEvents,
	     BOOL fWaitAll,
	     DWORD dwTimeout,
	     BOOL fAlertable
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSAAddressToStringA(
	     LPSOCKADDR lpsaAddress,
	         DWORD               dwAddressLength,
	     LPWSAPROTOCOL_INFOA lpProtocolInfo,
	     LPSTR lpszAddressString,
	      LPDWORD             lpdwAddressStringLength
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSAAddressToStringW(
	     LPSOCKADDR lpsaAddress,
	         DWORD               dwAddressLength,
	     LPWSAPROTOCOL_INFOW lpProtocolInfo,
	     LPWSTR lpszAddressString,
	      LPDWORD             lpdwAddressStringLength
	    );
	 __declspec(dllimport)
	INT
	 __stdcall
	WSAStringToAddressA(
	        LPSTR               AddressString,
	        INT                 AddressFamily,
	     LPWSAPROTOCOL_INFOA lpProtocolInfo,
	     LPSOCKADDR lpAddress,
	     LPINT               lpAddressLength
	    );
	 __declspec(dllimport)
	INT
	 __stdcall
	WSAStringToAddressW(
	        LPWSTR             AddressString,
	        INT                AddressFamily,
	     LPWSAPROTOCOL_INFOW lpProtocolInfo,
	     LPSOCKADDR lpAddress,
	     LPINT              lpAddressLength
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSALookupServiceBeginA(
	     LPWSAQUERYSETA lpqsRestrictions,
	     DWORD          dwControlFlags,
	     LPHANDLE       lphLookup
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSALookupServiceBeginW(
	     LPWSAQUERYSETW lpqsRestrictions,
	     DWORD          dwControlFlags,
	     LPHANDLE       lphLookup
	    );
	 __declspec(dllimport)
	INT
	 __stdcall
	WSALookupServiceNextA(
	     HANDLE           hLookup,
	     DWORD            dwControlFlags,
	     LPDWORD       lpdwBufferLength,
	     LPWSAQUERYSETA lpqsResults
	    );
	 __declspec(dllimport)
	INT
	 __stdcall
	WSALookupServiceNextW(
	     HANDLE           hLookup,
	     DWORD            dwControlFlags,
	     LPDWORD       lpdwBufferLength,
	     LPWSAQUERYSETW lpqsResults
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSANSPIoctl(
	     HANDLE           hLookup,
	     DWORD            dwControlCode,
	     LPVOID lpvInBuffer,
	     DWORD            cbInBuffer,
	     LPVOID lpvOutBuffer,
	     DWORD            cbOutBuffer,
	     LPDWORD        lpcbBytesReturned,
	     LPWSACOMPLETION lpCompletion
	    );
	 __declspec(dllimport)
	INT
	 __stdcall
	WSALookupServiceEnd(
	     HANDLE  hLookup
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSAInstallServiceClassA(
	      LPWSASERVICECLASSINFOA   lpServiceClassInfo
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSAInstallServiceClassW(
	      LPWSASERVICECLASSINFOW   lpServiceClassInfo
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSARemoveServiceClass(
	      LPGUID  lpServiceClassId
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSAGetServiceClassInfoA(
	      LPGUID  lpProviderId,
	      LPGUID  lpServiceClassId,
	     LPDWORD  lpdwBufSize,
	     LPWSASERVICECLASSINFOA lpServiceClassInfo
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSAGetServiceClassInfoW(
	      LPGUID  lpProviderId,
	      LPGUID  lpServiceClassId,
	     LPDWORD  lpdwBufSize,
	     LPWSASERVICECLASSINFOW lpServiceClassInfo
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSAEnumNameSpaceProvidersA(
	     LPDWORD             lpdwBufferLength,
	     LPWSANAMESPACE_INFOA lpnspBuffer
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSAEnumNameSpaceProvidersW(
	     LPDWORD             lpdwBufferLength,
	     LPWSANAMESPACE_INFOW lpnspBuffer
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSAEnumNameSpaceProvidersExA(
	     LPDWORD             lpdwBufferLength,
	     LPWSANAMESPACE_INFOEXA lpnspBuffer
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSAEnumNameSpaceProvidersExW(
	     LPDWORD             lpdwBufferLength,
	     LPWSANAMESPACE_INFOEXW lpnspBuffer
	    );
	__declspec(dllimport)
	 INT
	 __stdcall
	WSAGetServiceClassNameByClassIdA(
	           LPGUID  lpServiceClassId,
	     LPSTR lpszServiceClassName,
	     LPDWORD lpdwBufferLength
	    );
	__declspec(dllimport)
	 INT
	 __stdcall
	WSAGetServiceClassNameByClassIdW(
	           LPGUID  lpServiceClassId,
	     LPWSTR lpszServiceClassName,
	     LPDWORD lpdwBufferLength
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSASetServiceA(
	     LPWSAQUERYSETA lpqsRegInfo,
	     WSAESETSERVICEOP essoperation,
	     DWORD dwControlFlags
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSASetServiceW(
	     LPWSAQUERYSETW lpqsRegInfo,
	     WSAESETSERVICEOP essoperation,
	     DWORD dwControlFlags
	    );
	__declspec(dllimport)
	INT
	 __stdcall
	WSAProviderConfigChange(
	     LPHANDLE lpNotificationHandle,
	     LPWSAOVERLAPPED lpOverlapped,
	     LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
	    );
	__declspec(dllimport)
	int
	 __stdcall
	WSAPoll(
	     LPWSAPOLLFD fdArray,
	     ULONG fds,
	     INT timeout
	    );
	typedef struct sockaddr_in  *LPSOCKADDR_IN;
	typedef struct linger LINGER;
	typedef struct linger *PLINGER;
	typedef struct linger  *LPLINGER;
	typedef struct fd_set FD_SET;
	typedef struct fd_set *PFD_SET;
	typedef struct fd_set  *LPFD_SET;
	typedef struct hostent HOSTENT;
	typedef struct hostent *PHOSTENT;
	typedef struct hostent  *LPHOSTENT;
	typedef struct servent SERVENT;
	typedef struct servent *PSERVENT;
	typedef struct servent  *LPSERVENT;
	typedef struct protoent PROTOENT;
	typedef struct protoent *PPROTOENT;
	typedef struct protoent  *LPPROTOENT;
	typedef struct timeval TIMEVAL;
	typedef struct timeval *PTIMEVAL;
	typedef struct timeval  *LPTIMEVAL;
	#pragma warning(disable:4103)
	#pragma pack(pop)
	
	
	// *** 0. ws2tcpip.h ***
	#pragma once
	#pragma once
	#pragma warning(disable:4103)
	#pragma pack(push,4)
	#pragma warning(push)
	#pragma warning(disable:4001) 
	#pragma once
	#pragma warning(pop)
	#pragma once
	#pragma warning(disable:4116)       
	#pragma warning(disable:4514)
	#pragma warning(disable:4103)
	#pragma warning(push)
	#pragma warning(disable:4001)
	#pragma warning(disable:4201)
	#pragma warning(disable:4214)
	#pragma once
	#pragma once
	#pragma once
	typedef __w64 unsigned int   size_t;
	typedef unsigned short wchar_t;
	enum SA_YesNoMaybe
	{
		SA_No = 0x0fff0001,
		SA_Maybe = 0x0fff0010,
		SA_Yes = 0x0fff0100
	};

	__declspec(noalias)                                                                             void   free( void * _Memory);
	__declspec(noalias) __declspec(restrict)                           void * realloc( void * _Memory,   size_t _NewSize);
]]

--[[ lib_shared_memory.lua ]]
ffi.cdef[[
	__declspec(dllimport)
BOOL
__stdcall
CloseHandle(
     HANDLE hObject
    );
	__declspec(dllimport)
HANDLE
__stdcall
CreateFileMappingA(
         HANDLE hFile,
     LPSECURITY_ATTRIBUTES lpFileMappingAttributes,
         DWORD flProtect,
         DWORD dwMaximumSizeHigh,
         DWORD dwMaximumSizeLow,
     LPCSTR lpName
    );
	__declspec(dllimport)
DWORD
__stdcall
GetLastError(
    void
    );
	__declspec(dllimport)
LPVOID
__stdcall
MapViewOfFile(
     HANDLE hFileMappingObject,
     DWORD dwDesiredAccess,
     DWORD dwFileOffsetHigh,
     DWORD dwFileOffsetLow,
     SIZE_T dwNumberOfBytesToMap
    );
	__declspec(dllimport)
HANDLE
__stdcall
OpenFileMappingA(
     DWORD dwDesiredAccess,
     BOOL bInheritHandle,
     LPCSTR lpName
    );
	size_t  strlen(   const char * _Str);
	__declspec(dllimport)
BOOL
__stdcall
UnmapViewOfFile(
     LPCVOID lpBaseAddress
    );
]]

--[[ lib_signal.lua ]]
--[[ lib_socket.lua ]]
ffi.cdef[[
	typedef struct WSAData {
	        WORD                    wVersion;
	        WORD                    wHighVersion;
	        char                    szDescription[256+1];
	        char                    szSystemStatus[128+1];
	        unsigned short          iMaxSockets;
	        unsigned short          iMaxUdpDg;
	        char  *              lpVendorInfo;
	} WSADATA,  * LPWSADATA;

	typedef  CHAR *NPSTR, *LPSTR, *PSTR;
	
	__declspec(dllimport)
INT
 __stdcall
getaddrinfo(
            PCSTR               pNodeName,
            PCSTR               pServiceName,
            const ADDRINFOA *   pHints,
         PADDRINFOA *        ppResult
    );
	__declspec(dllimport)
INT
 __stdcall
getnameinfo(
             const SOCKADDR *    pSockaddr,
                                    socklen_t           SockaddrLength,
        PCHAR               pNodeBuffer,
                                    DWORD               NodeBufferSize,
     PCHAR               pServiceBuffer,
                                    DWORD               ServiceBufferSize,
                                    INT                 Flags
    );
	PCSTR
 __stdcall
inet_ntop(
                                    INT             Family,
                                    PVOID           pAddr,
             PSTR            pStringBuf,
                                    size_t          StringBufSize
    );
]]

--[[ lib_tcp.lua ]]
ffi.cdef[[
	#pragma warning(pop)
	#pragma once
	#pragma warning( push )
	#pragma warning( disable : 4793 4412 )
	static __inline int swprintf(wchar_t * _String, size_t _Count, const wchar_t * _Format, ...)
	{
	    va_list _Arglist;
	    int _Ret;
	    ( _Arglist = (va_list)( &(_Format) ) + ( (sizeof(_Format) + sizeof(int) - 1) & ~(sizeof(int) - 1) ) );
	    _Ret = _vswprintf_c_l(_String, _Count, _Format, ((void *)0), _Arglist);
	    ( _Arglist = (va_list)0 );
	    return _Ret;
	}
	#pragma warning( pop )
	#pragma warning( push )
	#pragma warning( disable : 4412 )
	static __inline int vswprintf(wchar_t * _String, size_t _Count, const wchar_t * _Format, va_list _Ap)
	{
	    return _vswprintf_c_l(_String, _Count, _Format, ((void *)0), _Ap);
	}
	#pragma warning( pop )
	#pragma warning( push )
	#pragma warning( disable : 4793 4412 )
	static __inline int _swprintf_l(wchar_t * _String, size_t _Count, const wchar_t * _Format, _locale_t _Plocinfo, ...)
	{
	    va_list _Arglist;
	    int _Ret;
	    ( _Arglist = (va_list)( &(_Plocinfo) ) + ( (sizeof(_Plocinfo) + sizeof(int) - 1) & ~(sizeof(int) - 1) ) );
	    _Ret = _vswprintf_c_l(_String, _Count, _Format, _Plocinfo, _Arglist);
	    ( _Arglist = (va_list)0 );
	    return _Ret;
	}
	#pragma warning( pop )
	#pragma warning( push )
	#pragma warning( disable : 4412 )
	static __inline int _vswprintf_l(wchar_t * _String, size_t _Count, const wchar_t * _Format, _locale_t _Plocinfo, va_list _Ap)
	{
	    return _vswprintf_c_l(_String, _Count, _Format, _Plocinfo, _Ap);
	}
	#pragma warning( pop )
	  wchar_t * _wtempnam(   const wchar_t * _Directory,    const wchar_t * _FilePrefix);
	  int _vscwprintf(    const wchar_t * _Format, va_list _ArgList);
	  int _vscwprintf_l(    const wchar_t * _Format,    _locale_t _Locale, va_list _ArgList);
	 __declspec(deprecated("This function or variable may be unsafe. Consider using " "fwscanf_s" " instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details."))  int fwscanf(   FILE * _File,     const wchar_t * _Format, ...);
	 __declspec(deprecated("This function or variable may be unsafe. Consider using " "_fwscanf_s_l" " instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details."))  int _fwscanf_l(   FILE * _File,     const wchar_t * _Format,    _locale_t _Locale, ...);
	#pragma warning(push)
	#pragma warning(disable:6530)
	  int fwscanf_s(   FILE * _File,     const wchar_t * _Format, ...);
	  int _fwscanf_s_l(   FILE * _File,     const wchar_t * _Format,    _locale_t _Locale, ...);
	 __declspec(deprecated("This function or variable may be unsafe. Consider using " "swscanf_s" " instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details."))  int swscanf(   const wchar_t * _Src,     const wchar_t * _Format, ...);
	 __declspec(deprecated("This function or variable may be unsafe. Consider using " "_swscanf_s_l" " instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details."))  int _swscanf_l(   const wchar_t * _Src,     const wchar_t * _Format,    _locale_t _Locale, ...);
	  int swscanf_s(   const wchar_t *_Src,     const wchar_t * _Format, ...);
	  int _swscanf_s_l(   const wchar_t * _Src,     const wchar_t * _Format,    _locale_t _Locale, ...);
	 __declspec(deprecated("This function or variable may be unsafe. Consider using " "_snwscanf_s" " instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details."))  int _snwscanf(     const wchar_t * _Src,   size_t _MaxCount,     const wchar_t * _Format, ...);
	 __declspec(deprecated("This function or variable may be unsafe. Consider using " "_snwscanf_s_l" " instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details."))  int _snwscanf_l(     const wchar_t * _Src,   size_t _MaxCount,     const wchar_t * _Format,    _locale_t _Locale, ...);
	  int _snwscanf_s(     const wchar_t * _Src,   size_t _MaxCount,     const wchar_t * _Format, ...);
	  int _snwscanf_s_l(     const wchar_t * _Src,   size_t _MaxCount,     const wchar_t * _Format,    _locale_t _Locale, ...);
	 __declspec(deprecated("This function or variable may be unsafe. Consider using " "wscanf_s" " instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details."))  int wscanf(    const wchar_t * _Format, ...);
	 __declspec(deprecated("This function or variable may be unsafe. Consider using " "_wscanf_s_l" " instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details."))  int _wscanf_l(    const wchar_t * _Format,    _locale_t _Locale, ...);
	  int wscanf_s(    const wchar_t * _Format, ...);
	  int _wscanf_s_l(    const wchar_t * _Format,    _locale_t _Locale, ...);
	#pragma warning(pop)
	  FILE * _wfdopen(  int _FileHandle ,    const wchar_t * _Mode);
	 __declspec(deprecated("This function or variable may be unsafe. Consider using " "_wfopen_s" " instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details."))  FILE * _wfopen(   const wchar_t * _Filename,    const wchar_t * _Mode);
	  errno_t _wfopen_s(     FILE ** _File,    const wchar_t * _Filename,    const wchar_t * _Mode);
	 __declspec(deprecated("This function or variable may be unsafe. Consider using " "_wfreopen_s" " instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details."))  FILE * _wfreopen(   const wchar_t * _Filename,    const wchar_t * _Mode,    FILE * _OldFile);
	  errno_t _wfreopen_s(     FILE ** _File,    const wchar_t * _Filename,    const wchar_t * _Mode,    FILE * _OldFile);
	 void _wperror(   const wchar_t * _ErrMsg);
	  FILE * _wpopen(   const wchar_t *_Command,    const wchar_t * _Mode);
	 int _wremove(   const wchar_t * _Filename);
	  errno_t _wtmpnam_s(    wchar_t * _DstBuf,   size_t _SizeInWords);
	__declspec(deprecated("This function or variable may be unsafe. Consider using " "_wtmpnam_s" " instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details."))  wchar_t * _wtmpnam(  wchar_t *_Buffer);
	  wint_t _fgetwc_nolock(   FILE * _File);
	  wint_t _fputwc_nolock(  wchar_t _Ch,    FILE * _File);
	  wint_t _ungetwc_nolock(  wint_t _Ch,    FILE * _File);
	 void _lock_file(   FILE * _File);
	 void _unlock_file(   FILE * _File);
	  int _fclose_nolock(   FILE * _File);
	  int _fflush_nolock(   FILE * _File);
	  size_t _fread_nolock(  void * _DstBuf,   size_t _ElementSize,   size_t _Count,    FILE * _File);
	  size_t _fread_nolock_s(  void * _DstBuf,   size_t _DstSize,   size_t _ElementSize,   size_t _Count,    FILE * _File);
	  int _fseek_nolock(   FILE * _File,   long _Offset,   int _Origin);
	  long _ftell_nolock(   FILE * _File);
	  int _fseeki64_nolock(   FILE * _File,   __int64 _Offset,   int _Origin);
	  __int64 _ftelli64_nolock(   FILE * _File);
	  size_t _fwrite_nolock(   const void * _DstBuf,   size_t _Size,   size_t _Count,    FILE * _File);
	  int _ungetc_nolock(  int _Ch,    FILE * _File);
	__declspec(deprecated("The POSIX name for this item is deprecated. Instead, use the ISO C++ conformant name: " "_tempnam" ". See online help for details."))  char * tempnam(   const char * _Directory,    const char * _FilePrefix);
	 __declspec(deprecated("The POSIX name for this item is deprecated. Instead, use the ISO C++ conformant name: " "_fcloseall" ". See online help for details."))  int fcloseall(void);
	 __declspec(deprecated("The POSIX name for this item is deprecated. Instead, use the ISO C++ conformant name: " "_fdopen" ". See online help for details."))  FILE * fdopen(  int _FileHandle,    const char * _Format);
	 __declspec(deprecated("The POSIX name for this item is deprecated. Instead, use the ISO C++ conformant name: " "_fgetchar" ". See online help for details."))  int fgetchar(void);
	 __declspec(deprecated("The POSIX name for this item is deprecated. Instead, use the ISO C++ conformant name: " "_fileno" ". See online help for details."))  int fileno(  FILE * _File);
	 __declspec(deprecated("The POSIX name for this item is deprecated. Instead, use the ISO C++ conformant name: " "_flushall" ". See online help for details."))  int flushall(void);
	 __declspec(deprecated("The POSIX name for this item is deprecated. Instead, use the ISO C++ conformant name: " "_fputchar" ". See online help for details."))  int fputchar(  int _Ch);
	 __declspec(deprecated("The POSIX name for this item is deprecated. Instead, use the ISO C++ conformant name: " "_getw" ". See online help for details."))  int getw(   FILE * _File);
	 __declspec(deprecated("The POSIX name for this item is deprecated. Instead, use the ISO C++ conformant name: " "_putw" ". See online help for details."))  int putw(  int _Ch,    FILE * _File);
	 __declspec(deprecated("The POSIX name for this item is deprecated. Instead, use the ISO C++ conformant name: " "_rmtmp" ". See online help for details."))  int rmtmp(void);
	#pragma pack(pop)
	
	
	// *** 0. sys/types.h ***
	#pragma once
	typedef __w64 long __time32_t;   
	typedef __int64 __time64_t;     
	typedef __time64_t time_t;      
	typedef unsigned short _ino_t;          
	typedef unsigned short ino_t;
	typedef unsigned int _dev_t;            
	typedef unsigned int dev_t;
	typedef long _off_t;                    
	typedef long off_t;
	
	
	// *** 0. time.h ***
	#pragma once
	#pragma once
	#pragma once
	typedef __w64 unsigned int   size_t;
	typedef unsigned short wchar_t;
	enum SA_YesNoMaybe
	{
		SA_No = 0x0fff0001,
		SA_Maybe = 0x0fff0010,
		SA_Yes = 0x0fff0100
	};
	typedef struct in6_addr {
	    union {
	        UCHAR       Byte[16];
	        USHORT      Word[8];
	    } u;
	} IN6_ADDR, *PIN6_ADDR,  *LPIN6_ADDR;

	// #pragma pack(pop)
	
	
	// *** 0. ws2def.h ***
	#pragma once
	#pragma warning(push)
	#pragma warning(disable:4201)
	#pragma warning(disable:4214) 
	#pragma once
	typedef struct in_addr {
	        union {
	                struct { UCHAR s_b1,s_b2,s_b3,s_b4; } S_un_b;
	                struct { USHORT s_w1,s_w2; } S_un_w;
	                ULONG S_addr;
	        } S_un;
	} IN_ADDR, *PIN_ADDR, FAR *LPIN_ADDR;
	typedef USHORT ADDRESS_FAMILY;
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
	
	// #pragma pack()

	typedef USHORT ADDRESS_FAMILY;
	typedef struct {
	    union {
	        struct {
	            ULONG Zone : 28;
	            ULONG Level : 4;
	        };
	        ULONG Value;
	    };
	} SCOPE_ID, *PSCOPE_ID;

	struct { USHORT s_w1,s_w2; } S_un_w;
	                ULONG S_addr;
	        } S_un;
	} IN_ADDR, *PIN_ADDR, FAR *LPIN_ADDR;
	typedef USHORT ADDRESS_FAMILY;
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

	typedef struct in_addr {
	        union {
	                struct { UCHAR s_b1,s_b2,s_b3,s_b4; } S_un_b;
	                struct { USHORT s_w1,s_w2; } S_un_w;
	                ULONG S_addr;
	        } S_un;
	} IN_ADDR, *PIN_ADDR, FAR *LPIN_ADDR;

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
	typedef struct addrinfoW
	{
	    int                 ai_flags;       
	    int                 ai_family;      
	    int                 ai_socktype;    
	    int                 ai_protocol;    
	    size_t              ai_addrlen;     
	    PWSTR               ai_canonname;   
	    __field_bcount(ai_addrlen) struct sockaddr *   ai_addr;        
	    struct addrinfoW *  ai_next;        
	}
	ADDRINFOW, *PADDRINFOW;
	#pragma warning(pop)
	
	
	// *** 0. winsock2.h ***
	#pragma once
	#pragma warning(disable:4103)
	#pragma pack(push,4)
	#pragma warning(push)
	#pragma warning(disable:4001) 
	#pragma once
	#pragma warning(pop)
	#pragma once
	#pragma warning(disable:4116)       
	#pragma warning(disable:4514)
	#pragma warning(disable:4103)
	#pragma warning(push)
	#pragma warning(disable:4001)
	#pragma warning(disable:4201)
	#pragma warning(disable:4214)
	#pragma once
	#pragma once
	#pragma once
	typedef __w64 unsigned int   size_t;
	typedef unsigned short wchar_t;
	enum SA_YesNoMaybe
	{
		SA_No = 0x0fff0001,
		SA_Maybe = 0x0fff0010,
		SA_Yes = 0x0fff0100
	};

	typedef struct sockaddr_in6 {
	    ADDRESS_FAMILY sin6_family; 
	    USHORT sin6_port;           
	    ULONG  sin6_flowinfo;       
	    IN6_ADDR sin6_addr;         
	    union {
	        ULONG sin6_scope_id;     
	        SCOPE_ID sin6_scope_struct; 
	    };

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
	IN6_ADDR sin6_addr;
	USHORT sin6_port;
	IN_ADDR sin_addr;
	USHORT sin_port;
]]

--[[ lib_thread.lua ]]
ffi.cdef[[
	typedef DWORD (__stdcall *PTHREAD_START_ROUTINE)(
	    LPVOID lpThreadParameter
	    );
	typedef PTHREAD_START_ROUTINE LPTHREAD_START_ROUTINE;
	typedef struct _CREATE_THREAD_DEBUG_INFO {
	    HANDLE hThread;
	    LPVOID lpThreadLocalBase;
	    LPTHREAD_START_ROUTINE lpStartAddress;
	} CREATE_THREAD_DEBUG_INFO, *LPCREATE_THREAD_DEBUG_INFO;

	CREATE_THREAD_DEBUG_INFO CreateThread;
	__declspec(dllimport)
DWORD
__stdcall
GetCurrentThreadId(
    void
    );
	__declspec(dllimport)
DWORD
__stdcall
WaitForSingleObject(
     HANDLE hHandle,
     DWORD dwMilliseconds
    );
]]

--[[ lib_util.lua ]]
ffi.cdef[[
	typedef struct _SYSTEM_INFO {
	    union {
	        DWORD dwOemId;          
	        struct {
	            WORD wProcessorArchitecture;
	            WORD wReserved;
	        } ;
	    } ;
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

	__declspec(dllimport)
BOOL
__stdcall
GetConsoleMode(
     HANDLE hConsoleHandle,
     LPDWORD lpMode
    );
	__declspec(dllimport)
HANDLE
__stdcall
GetStdHandle(
     DWORD nStdHandle
    );
	__declspec(dllimport)
void
__stdcall
GetSystemInfo(
     LPSYSTEM_INFO lpSystemInfo
    );
	__declspec(dllimport)
BOOL
__stdcall
QueryPerformanceCounter(
     LARGE_INTEGER *lpPerformanceCount
    );
	__declspec(dllimport)
BOOL
__stdcall
QueryPerformanceFrequency(
     LARGE_INTEGER *lpFrequency
    );
	__declspec(dllimport)
BOOL
__stdcall
ReadConsoleA(
     HANDLE hConsoleInput,
       LPVOID lpBuffer,
     DWORD nNumberOfCharsToRead,
     LPDWORD lpNumberOfCharsRead,
     PCONSOLE_READCONSOLE_CONTROL pInputControl
    );
	__declspec(dllimport)
BOOL
__stdcall
SetConsoleMode(
     HANDLE hConsoleHandle,
     DWORD dwMode
    );
	__declspec(deprecated("This function or variable has been superceded by newer library or operating system functionality. Consider using " "Sleep" " instead. See online help for details."))  void _sleep(  unsigned long _Duration);
	__declspec(deprecated("This function or variable may be unsafe. Consider using " "strerror" " instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details.")) char ** __sys_errlist(void);
	__declspec(dllimport)
BOOL
__stdcall
SwitchToThread(
    void
    );
]]

--[[ TestAddrinfo.lua ]]
--[[ TestAll.lua ]]
--[[ TestKqueue.lua ]]
ffi.cdef[[
	typedef  long HRESULT;HRESULT ( __stdcall *open )( 
             IXMLHttpRequest * This,
              BSTR bstrMethod,
              BSTR bstrUrl,
             VARIANT varAsync,
             VARIANT bstrUser,
             VARIANT bstrPassword);
]]

--[[ TestLinux.lua ]]
--[[ TestSharedMemory.lua ]]
--[[ TestSignal.lua ]]
--[[ TestSignal_bad.lua ]]
--[[ TestSocket.lua ]]
--[[ TestThread.lua ]]

--[[
not found calls = {
   [1] = "--- lib_date_time.lua ---";
   [2] = "--- lib_http.lua ---";
   [3] = "--- lib_kqueue.lua ---";
   [4] = "--- lib_poll.lua ---";
   [5] = "POLLERR";
   [6] = "POLLHUP";
   [7] = "POLLIN";
   [8] = "POLLNVAL";
   [9] = "POLLOUT";
   [10] = "--- lib_shared_memory.lua ---";
   [11] = "close";
   [12] = "ftruncate";
   [13] = "MAP_SHARED";
   [14] = "mmap";
   [15] = "munmap";
   [16] = "O_CREAT";
   [17] = "O_RDONLY";
   [18] = "O_RDWR";
   [19] = "PROT_READ";
   [20] = "PROT_WRITE";
   [21] = "shm_open";
   [22] = "shm_unlink";
   [23] = "--- lib_signal.lua ---";
   [24] = "getpid";
   [25] = "kill";
   [26] = "pthread_sigmask";
   [27] = "sigaddset";
   [28] = "sigemptyset";
   [29] = "sigwait";
   [30] = "--- lib_socket.lua ---";
   [31] = "close";
   [32] = "F_GETFL";
   [33] = "F_SETFL";
   [34] = "fcntl";
   [35] = "gai_strerror";
   [36] = "O_NONBLOCK";
   [37] = "poll";
   [38] = "--- lib_tcp.lua ---";
   [39] = "AF_INET";
   [40] = "AF_INET6";
   [41] = "AI_PASSIVE";
   [42] = "INET6_ADDRSTRLEN";
   [43] = "INET_ADDRSTRLEN";
   [44] = "SO_RCVBUF";
   [45] = "SO_REUSEADDR";
   [46] = "SO_SNDBUF";
   [47] = "SO_USELOOPBACK";
   [48] = "SOCK_STREAM";
   [49] = "SOL_SOCKET";
   [50] = "SOMAXCONN";
   [51] = "TCP_NODELAY";
   [52] = "--- lib_thread.lua ---";
   [53] = "INFINITE";
   [54] = "pthread_create";
   [55] = "pthread_exit";
   [56] = "pthread_join";
   [57] = "pthread_self";
   [58] = "--- lib_util.lua ---";
   [59] = "_SC_NPROCESSORS_CONF";
   [60] = "_SC_NPROCESSORS_ONLN";
   [61] = "ENABLE_ECHO_INPUT";
   [62] = "ENABLE_LINE_INPUT";
   [63] = "FORMAT_MESSAGE_FROM_SYSTEM";
   [64] = "FORMAT_MESSAGE_IGNORE_INSERTS";
   [65] = "gettimeofday";
   [66] = "nanosleep";
   [67] = "sched_yield";
   [68] = "STD_INPUT_HANDLE";
   [69] = "sysconf";
   [70] = "usleep";
   [71] = "--- TestAddrinfo.lua ---";
   [72] = "AF_INET";
   [73] = "AI_CANONNAME";
   [74] = "NI_MAXHOST";
   [75] = "NI_MAXSERV";
   [76] = "NI_NAMEREQD";
   [77] = "NI_NUMERICHOST";
   [78] = "NI_NUMERICSERV";
   [79] = "SOCK_STREAM";
   [80] = "--- TestAll.lua ---";
   [81] = "--- TestKqueue.lua ---";
   [82] = "close";
   [83] = "EV_ADD";
   [84] = "EV_ENABLE";
   [85] = "EV_ONESHOT";
   [86] = "EVFILT_VNODE";
   [87] = "INFINITE";
   [88] = "kevent";
   [89] = "kqueue";
   [90] = "NOTE_ATTRIB";
   [91] = "NOTE_DELETE";
   [92] = "NOTE_EXTEND";
   [93] = "NOTE_WRITE";
   [94] = "O_RDONLY";
   [95] = "--- TestLinux.lua ---";
   [96] = "mmap";
   [97] = "munmap";
   [98] = "O_CREAT";
   [99] = "O_EXCL";
   [100] = "shm_open";
   [101] = "shm_unlink";
   [102] = "--- TestSharedMemory.lua ---";
   [103] = "--- TestSignal.lua ---";
   [104] = "--- TestSignal_bad.lua ---";
   [105] = "getpid";
   [106] = "kill";
   [107] = "pause";
   [108] = "signal";
   [109] = "--- TestSocket.lua ---";
   [110] = "SD_SEND";
   [111] = "--- TestThread.lua ---";
};
]]