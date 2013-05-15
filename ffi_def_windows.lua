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
	DWORD time;
]]

--[[ lib_http.lua ]]
--[[ lib_kqueue.lua ]]
--[[ lib_poll.lua ]]
ffi.cdef[[
	void  free (void*);
	void*  realloc (void*, size_t);
]]

--[[ lib_shared_memory.lua ]]
ffi.cdef[[
	typedef const CHAR *LPCCH,*PCSTR,*LPCSTR;
	typedef const void *PCVOID,*LPCVOID;
	typedef struct _SECURITY_ATTRIBUTES {
	 DWORD nLength;
	 LPVOID lpSecurityDescriptor;
	 BOOL bInheritHandle;
	} SECURITY_ATTRIBUTES,*PSECURITY_ATTRIBUTES,*LPSECURITY_ATTRIBUTES;

	BOOL  CloseHandle(HANDLE);
	HANDLE  CreateFileMappingA(HANDLE,LPSECURITY_ATTRIBUTES,DWORD,DWORD,DWORD,LPCSTR);
	DWORD  GetLastError(void);
	PVOID  MapViewOfFile(HANDLE,DWORD,DWORD,DWORD,DWORD);
	HANDLE  OpenFileMappingA(DWORD,BOOL,LPCSTR);
	size_t  strlen (const char*);
	BOOL  UnmapViewOfFile(LPCVOID);
]]

--[[ lib_signal.lua ]]
--[[ lib_socket.lua ]]
ffi.cdef[[
	typedef struct _GUID {
	 unsigned long Data1;
	 unsigned short Data2;
	 unsigned short Data3;
	 unsigned char Data4[8];
	} GUID, *REFGUID, *LPGUID;

	typedef struct _WSAPROTOCOLCHAIN {
	 int ChainLen;
	 DWORD ChainEntries[7];
	} WSAPROTOCOLCHAIN, *LPWSAPROTOCOLCHAIN;

	struct in_addr {
	 union {
	  struct { u_char s_b1,s_b2,s_b3,s_b4; } S_un_b;
	  struct { u_short s_w1,s_w2; } S_un_w;
	  u_long S_addr;
	 } S_un;
	static const int s_addr = S_un.S_addr;
	static const int s_host = S_un.S_un_b.s_b2;
	static const int s_net = S_un.S_un_b.s_b1;
	static const int s_imp = S_un.S_un_w.s_w2;
	static const int s_impno = S_un.S_un_b.s_b4;
	static const int s_lh = S_un.S_un_b.s_b3;
	};

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
	} WSAPROTOCOL_INFOA, *LPWSAPROTOCOL_INFOA;

	typedef struct WSAData {
	 WORD wVersion;
	 WORD wHighVersion;
	 char szDescription[256 +1];
	 char szSystemStatus[128 +1];
	 unsigned short iMaxSockets;
	 unsigned short iMaxUdpDg;
	 char * lpVendorInfo;
	} WSADATA;

	typedef struct sockaddr *LPSOCKADDR;
	typedef WSADATA *LPWSADATA;
	typedef u_int SOCKET;
	struct sockaddr {
	 u_short sa_family;
	 char sa_data[14];
	};

	typedef CHAR *PCHAR,*LPCH,*PCH,*NPSTR,*LPSTR,*PSTR;
	struct sockaddr_in {
	 short sin_family;
	 u_short sin_port;
	 struct in_addr sin_addr;
	 char sin_zero[8];
	};

	typedef DWORD *PDWORD,*LPDWORD;
	
	SOCKET  accept(SOCKET,struct sockaddr*,int*);
	int  bind(SOCKET,const struct sockaddr*,int);
	int  closesocket(SOCKET);
	int  connect(SOCKET,const struct sockaddr*,int);
	int  getpeername(SOCKET,struct sockaddr*,int*);
	int  getsockopt(SOCKET,int,int,char*,int*);
	u_short  htons(u_short);
	int  ioctlsocket(SOCKET,long,u_long *);
	int  listen(SOCKET,int);
	u_short  ntohs(u_short);
	int  recv(SOCKET,char*,int,int);
	int  send(SOCKET,const char*,int,int);
	int  setsockopt(SOCKET,int,int,const char*,int);
	int  shutdown(SOCKET,int);
	SOCKET  socket(int,int,int);
	INT  WSAAddressToStringA(LPSOCKADDR, DWORD, LPWSAPROTOCOL_INFOA, LPSTR, LPDWORD);
	int  WSACleanup(void);
	int  WSAGetLastError(void);
	int  WSAStartup(WORD,LPWSADATA);
]]

--[[ lib_tcp.lua ]]
ffi.cdef[[
	static const int AF_INET = 2;
	static const int AF_INET6 = 23;
	static const int AI_PASSIVE = 1;
	static const int INET6_ADDRSTRLEN = 46;
	static const int INET_ADDRSTRLEN = 16;
	static const int IPPROTO_TCP = 6;
	static const int SO_RCVBUF = 0x1002;
	static const int SO_REUSEADDR = 4;
	static const int SO_SNDBUF = 0x1001;
	static const int SO_USELOOPBACK = 64;
	static const int SOCK_STREAM = 1;
	static const int SOL_SOCKET = 0xffff;
	static const int SOMAXCONN = 0x7fffffff;
	static const int TCP_NODELAY = 0x0001;
	
	struct sockaddr_storage {
	    short ss_family;
	    char __ss_pad1[((sizeof (long long)) - sizeof (short))];
	    long long __ss_align;
	    char __ss_pad2[(128 - (sizeof (short) + ((sizeof (long long)) - sizeof (short)) + (sizeof (long long))))];
	};

	struct in6_addr {
	    union {
	        u_char _S6_u8[16];
	        u_short _S6_u16[8];
	        u_long _S6_u32[4];
	        } _S6_un;
	};

	struct addrinfo {
	 int ai_flags;
	 int ai_family;
	 int ai_socktype;
	 int ai_protocol;
	 size_t ai_addrlen;
	 char *ai_canonname;
	 struct sockaddr *ai_addr;
	 struct addrinfo *ai_next;
	};

	struct sockaddr_in6 {
	 short sin6_family;
	 u_short sin6_port;
	 u_long sin6_flowinfo;
	 struct in6_addr sin6_addr;
	 u_long sin6_scope_id;
	};

	struct in6_addr sin6_addr;
	u_short sin6_port;
]]

--[[ lib_thread.lua ]]
ffi.cdef[[
	static const int INFINITE = 0xFFFFFFFF;
	
	typedef DWORD ( *LPTHREAD_START_ROUTINE)(LPVOID);
	typedef struct _CREATE_THREAD_DEBUG_INFO {
	 HANDLE hThread;
	 LPVOID lpThreadLocalBase;
	 LPTHREAD_START_ROUTINE lpStartAddress;
	} CREATE_THREAD_DEBUG_INFO,*LPCREATE_THREAD_DEBUG_INFO;

	CREATE_THREAD_DEBUG_INFO CreateThread;
	DWORD  GetCurrentThreadId(void);
	DWORD  WaitForSingleObject(HANDLE,DWORD);
]]

--[[ lib_util.lua ]]
ffi.cdef[[
	static const int ENABLE_ECHO_INPUT = 4;
	static const int ENABLE_LINE_INPUT = 2;
	static const int FORMAT_MESSAGE_FROM_SYSTEM = 4096;
	static const int FORMAT_MESSAGE_IGNORE_INSERTS = 512;
	static const int STD_INPUT_HANDLE = (DWORD)(0xfffffff6);
	
	typedef union _LARGE_INTEGER {
	  struct {
	    DWORD LowPart;
	    LONG HighPart;
	  } u;
	  struct {
	    DWORD LowPart;
	    LONG HighPart;
	  };
	  LONGLONG QuadPart;
	} LARGE_INTEGER, *PLARGE_INTEGER;

	typedef struct _SYSTEM_INFO {
	 union {
	  DWORD dwOemId;
	  struct {
	   WORD wProcessorArchitecture;
	   WORD wReserved;
	  } ;
	 } ;
	 DWORD dwPageSize;
	 PVOID lpMinimumApplicationAddress;
	 PVOID lpMaximumApplicationAddress;
	 DWORD dwActiveProcessorMask;
	 DWORD dwNumberOfProcessors;
	 DWORD dwProcessorType;
	 DWORD dwAllocationGranularity;
	 WORD wProcessorLevel;
	 WORD wProcessorRevision;
	} SYSTEM_INFO,*LPSYSTEM_INFO;

	struct timeval {
	 long tv_sec;
	 long tv_usec;
	};

	BOOL  GetConsoleMode(HANDLE,PDWORD);
	HANDLE  GetStdHandle(DWORD);
	void  GetSystemInfo(LPSYSTEM_INFO);
	BOOL  QueryPerformanceCounter(PLARGE_INTEGER);
	BOOL  QueryPerformanceFrequency(PLARGE_INTEGER);
	BOOL  ReadConsoleA(HANDLE,PVOID,DWORD,PDWORD,PVOID);
	BOOL  SetConsoleMode(HANDLE,DWORD);
	void  Sleep(DWORD);
	char*  strerror (int);
	BOOL  SwitchToThread(void);
]]

--[[ TestAddrinfo.lua ]]
ffi.cdef[[
	static const int AI_CANONNAME = 2;
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
   [2] = "difftime";
   [3] = "--- lib_http.lua ---";
   [4] = "--- lib_kqueue.lua ---";
   [5] = "--- lib_poll.lua ---";
   [6] = "POLLERR";
   [7] = "POLLHUP";
   [8] = "POLLIN";
   [9] = "POLLNVAL";
   [10] = "POLLOUT";
   [11] = "--- lib_shared_memory.lua ---";
   [12] = "close";
   [13] = "ftruncate";
   [14] = "MAP_SHARED";
   [15] = "mmap";
   [16] = "munmap";
   [17] = "O_CREAT";
   [18] = "O_RDONLY";
   [19] = "O_RDWR";
   [20] = "PROT_READ";
   [21] = "PROT_WRITE";
   [22] = "shm_open";
   [23] = "shm_unlink";
   [24] = "--- lib_signal.lua ---";
   [25] = "getpid";
   [26] = "kill";
   [27] = "pthread_sigmask";
   [28] = "sigaddset";
   [29] = "sigemptyset";
   [30] = "sigwait";
   [31] = "--- lib_socket.lua ---";
   [32] = "close";
   [33] = "F_GETFL";
   [34] = "F_SETFL";
   [35] = "fcntl";
   [36] = "gai_strerror";
   [37] = "getaddrinfo";
   [38] = "getnameinfo";
   [39] = "inet_ntop";
   [40] = "O_NONBLOCK";
   [41] = "poll";
   [42] = "WSAPoll";
   [43] = "--- lib_tcp.lua ---";
   [44] = "--- lib_thread.lua ---";
   [45] = "pthread_create";
   [46] = "pthread_exit";
   [47] = "pthread_join";
   [48] = "pthread_self";
   [49] = "--- lib_util.lua ---";
   [50] = "_SC_NPROCESSORS_CONF";
   [51] = "_SC_NPROCESSORS_ONLN";
   [52] = "gettimeofday";
   [53] = "nanosleep";
   [54] = "sched_yield";
   [55] = "sysconf";
   [56] = "usleep";
   [57] = "--- TestAddrinfo.lua ---";
   [58] = "--- TestAll.lua ---";
   [59] = "--- TestKqueue.lua ---";
   [60] = "close";
   [61] = "EV_ADD";
   [62] = "EV_ENABLE";
   [63] = "EV_ONESHOT";
   [64] = "EVFILT_VNODE";
   [65] = "kevent";
   [66] = "kqueue";
   [67] = "NOTE_ATTRIB";
   [68] = "NOTE_DELETE";
   [69] = "NOTE_EXTEND";
   [70] = "NOTE_WRITE";
   [71] = "O_RDONLY";
   [72] = "open";
   [73] = "--- TestLinux.lua ---";
   [74] = "mmap";
   [75] = "munmap";
   [76] = "O_CREAT";
   [77] = "O_EXCL";
   [78] = "shm_open";
   [79] = "shm_unlink";
   [80] = "--- TestSharedMemory.lua ---";
   [81] = "--- TestSignal.lua ---";
   [82] = "--- TestSignal_bad.lua ---";
   [83] = "getpid";
   [84] = "kill";
   [85] = "pause";
   [86] = "signal";
   [87] = "--- TestSocket.lua ---";
   [88] = "--- TestThread.lua ---";
};
]]