-- ffi_def_osx.lua
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

	// these are in sys/types.h, but is this safe universal way?
	typedef int8_t __int8_t;
	typedef int16_t __int16_t;
	typedef int32_t __int32_t;
	typedef int64_t __int64_t;

	typedef uint8_t __uint8_t;
	typedef uint16_t __uint16_t;
	typedef uint32_t __uint32_t;
	typedef uint64_t __uint64_t;
]]

ffi.cdef[[
	// bad on ugly define macros, done by hand
	uint32_t htonl(uint32_t hostlong);
	uint16_t htons(uint16_t hostshort);
	uint32_t ntohl(uint32_t netlong);
	uint16_t ntohs(uint16_t netshort);

	// bad order of generated calls
	
]]


-- everything above will stay, below will be generated --
-- ******************** --
-- generated code start --

--[[ lib_date_time.lua ]]
ffi.cdef[[
	typedef long __darwin_time_t;
	typedef __darwin_time_t time_t;
	
	double difftime(time_t, time_t);
	time_t time(time_t *);
]]

--[[ lib_http.lua ]]
--[[ lib_kqueue.lua ]]
ffi.cdef[[
	// #pragma pack(4)
	struct kevent {
	 uintptr_t ident;
	 int16_t filter;
	 uint16_t flags;
	 uint32_t fflags;
	 intptr_t data;
	 void *udata;
	};
	
	// #pragma pack()
]]

--[[ lib_poll.lua ]]
ffi.cdef[[
	static const int POLLERR = 0x0008;
	static const int POLLHUP = 0x0010;
	static const int POLLIN = 0x0001;
	static const int POLLNVAL = 0x0020;
	static const int POLLOUT = 0x0004;
	
	struct pollfd
	{
	 int fd;
	 short events;
	 short revents;
	};
	
	
	void free(void *);
	void *realloc(void *, size_t);
]]

--[[ lib_shared_memory.lua ]]
ffi.cdef[[
	static const int MAP_SHARED = 0x0001;
	static const int O_CREAT = 0x0200;
	static const int O_RDONLY = 0x0000;
	static const int O_RDWR = 0x0002;
	static const int PROT_READ = 0x01;
	static const int PROT_WRITE = 0x02;
	
	typedef __int64_t __darwin_off_t;
	typedef __darwin_off_t off_t;
	
	int close(int);
	int ftruncate(int, off_t);
	void * mmap(void *, size_t, int, int, int, off_t);
	int munmap(void *, size_t);
	int shm_open(const char *, int, ...);
	int shm_unlink(const char *);
	size_t strlen(const char *);
]]

--[[ lib_signal.lua ]]
ffi.cdef[[
	typedef __int32_t __darwin_pid_t;
	typedef __uint32_t __darwin_sigset_t;
	typedef __darwin_pid_t pid_t;
	typedef __darwin_sigset_t sigset_t;
	
	pid_t getpid(void);
	int kill(pid_t, int);
	int pthread_sigmask(int, const sigset_t *, sigset_t *);
	int sigaddset(sigset_t *, int);
	int sigemptyset(sigset_t *);
	int sigwait(const sigset_t * , int * );
]]

--[[ lib_socket.lua ]]
ffi.cdef[[
	typedef __uint32_t in_addr_t;
	typedef __uint8_t sa_family_t;
	struct in_addr {
	 in_addr_t s_addr;
	};
	
	struct sockaddr {
	 __uint8_t sa_len;
	 sa_family_t sa_family;
	 char sa_data[14];
	};
	
	typedef __uint16_t in_port_t;
	struct sockaddr_in {
	 __uint8_t sin_len;
	 sa_family_t sin_family;
	 in_port_t sin_port;
	 struct in_addr sin_addr;
	 char sin_zero[8];
	};
	
	
	const char *gai_strerror(int);
]]

--[[ lib_tcp.lua ]]
ffi.cdef[[
	static const int AF_INET = 2;
	static const int AF_INET6 = 30;
	static const int AI_PASSIVE = 0x00000001;
	static const int INET6_ADDRSTRLEN = 46;
	static const int INET_ADDRSTRLEN = 16;
	static const int IPPROTO_TCP = 6;
	static const int SO_RCVBUF = 0x1002;
	static const int SO_REUSEADDR = 0x0004;
	static const int SO_SNDBUF = 0x1001;
	static const int SO_USELOOPBACK = 0x0040;
	static const int SOCK_STREAM = 1;
	static const int SOL_SOCKET = 0xffff;
	static const int SOMAXCONN = 128;
	static const int TCP_NODELAY = 0x01;
	
	typedef __uint32_t __darwin_socklen_t;
	typedef __darwin_socklen_t socklen_t;
	struct addrinfo {
	 int ai_flags;
	 int ai_family;
	 int ai_socktype;
	 int ai_protocol;
	 socklen_t ai_addrlen;
	 char *ai_canonname;
	 struct sockaddr *ai_addr;
	 struct addrinfo *ai_next;
	};
	
	struct sockaddr_storage {
	 __uint8_t ss_len;
	 sa_family_t ss_family;
	 char __ss_pad1[((sizeof(__int64_t)) - sizeof(__uint8_t) - sizeof(sa_family_t))];
	 __int64_t __ss_align;
	 char __ss_pad2[(128 - sizeof(__uint8_t) - sizeof(sa_family_t) - ((sizeof(__int64_t)) - sizeof(__uint8_t) - sizeof(sa_family_t)) - (sizeof(__int64_t)))];
	};
	
	struct in6_addr {
	 union {
	  __uint8_t __u6_addr8[16];
	  __uint16_t __u6_addr16[8];
	  __uint32_t __u6_addr32[4];
	 } __u6_addr;
	};
	
	struct sockaddr_in6 {
	 __uint8_t sin6_len;
	 sa_family_t sin6_family;
	 in_port_t sin6_port;
	 __uint32_t sin6_flowinfo;
	 struct in6_addr sin6_addr;
	 __uint32_t sin6_scope_id;
	};
	
]]

--[[ lib_thread.lua ]]
ffi.cdef[[
	struct __darwin_pthread_handler_rec
	{
	 void (*__routine)(void *);
	 void *__arg;
	 struct __darwin_pthread_handler_rec *__next;
	};
	
	struct _opaque_pthread_t { long __sig; struct __darwin_pthread_handler_rec *__cleanup_stack; char __opaque[1168]; };
	
	typedef struct _opaque_pthread_t
	   *__darwin_pthread_t;
	struct _opaque_pthread_attr_t { long __sig; char __opaque[56]; };
	
	typedef struct _opaque_pthread_attr_t
	   __darwin_pthread_attr_t;
	typedef __darwin_pthread_t pthread_t;
	typedef __darwin_pthread_attr_t pthread_attr_t;
	
	int pthread_create(pthread_t * ,
                         const pthread_attr_t * ,
                         void *(*)(void *),
                         void * );
	void pthread_exit(void *);
	int pthread_join(pthread_t , void **);
	pthread_t pthread_self(void);
]]

--[[ lib_util.lua ]]
ffi.cdef[[
	static const int _SC_NPROCESSORS_CONF = 57;
	static const int _SC_NPROCESSORS_ONLN = 58;
	
	typedef __uint32_t __darwin_useconds_t;
	typedef __int32_t __darwin_suseconds_t;
	struct timespec
	{
	 __darwin_time_t tv_sec;
	 long tv_nsec;
	};
	
	typedef __darwin_useconds_t useconds_t;
	struct timeval
	{
	 __darwin_time_t tv_sec;
	 __darwin_suseconds_t tv_usec;
	};
	
	
	int gettimeofday(struct timeval * , void * );
	int nanosleep(const struct timespec *, struct timespec *);
	int sched_yield(void);
	char *strerror(int);
	long sysconf(int);
	int usleep(useconds_t);
]]

--[[ TestAddrinfo.lua ]]
ffi.cdef[[
	static const int AI_CANONNAME = 0x00000002;
	static const int NI_MAXHOST = 1025;
	static const int NI_MAXSERV = 32;
	static const int NI_NAMEREQD = 0x00000004;
	static const int NI_NUMERICHOST = 0x00000002;
	static const int NI_NUMERICSERV = 0x00000008;
]]

--[[ TestAll.lua ]]
--[[ TestKqueue.lua ]]
ffi.cdef[[
	static const int EV_ADD = 0x0001;
	static const int EV_ENABLE = 0x0004;
	static const int EV_ONESHOT = 0x0010;
	static const int EVFILT_VNODE = (-4);
	static const int NOTE_ATTRIB = 0x00000008;
	static const int NOTE_DELETE = 0x00000001;
	static const int NOTE_EXTEND = 0x00000004;
	static const int NOTE_WRITE = 0x00000002;
	
	int kevent(int kq, const struct kevent *changelist, int nchanges,
      struct kevent *eventlist, int nevents,
      const struct timespec *timeout);
	int kqueue(void);
	int open(const char *, int, ...);
]]

--[[ TestLinux.lua ]]
ffi.cdef[[
	static const int O_EXCL = 0x0800;
]]

--[[ TestSharedMemory.lua ]]
--[[ TestSignal.lua ]]
--[[ TestSignal_bad.lua ]]
ffi.cdef[[
	int pause(void);
	void (*signal(int, void (*)(int)))(int);
]]

--[[ TestSocket.lua ]]
--[[ TestThread.lua ]]

--[[
not found calls = {
   [1] = "--- lib_date_time.lua ---";
   [2] = "--- lib_http.lua ---";
   [3] = "--- lib_kqueue.lua ---";
   [4] = "--- lib_poll.lua ---";
   [5] = "--- lib_shared_memory.lua ---";
   [6] = "CloseHandle";
   [7] = "CreateFileMappingA";
   [8] = "GetLastError";
   [9] = "MapViewOfFile";
   [10] = "OpenFileMappingA";
   [11] = "UnmapViewOfFile";
   [12] = "--- lib_signal.lua ---";
   [13] = "--- lib_socket.lua ---";
   [14] = "--- lib_tcp.lua ---";
   [15] = "--- lib_thread.lua ---";
   [16] = "CreateThread";
   [17] = "GetCurrentThreadId";
   [18] = "INFINITE";
   [19] = "WaitForSingleObject";
   [20] = "--- lib_util.lua ---";
   [21] = "ENABLE_ECHO_INPUT";
   [22] = "ENABLE_LINE_INPUT";
   [23] = "FORMAT_MESSAGE_FROM_SYSTEM";
   [24] = "FORMAT_MESSAGE_IGNORE_INSERTS";
   [25] = "GetConsoleMode";
   [26] = "GetStdHandle";
   [27] = "GetSystemInfo";
   [28] = "QueryPerformanceCounter";
   [29] = "QueryPerformanceFrequency";
   [30] = "ReadConsoleA";
   [31] = "SetConsoleMode";
   [32] = "Sleep";
   [33] = "STD_INPUT_HANDLE";
   [34] = "SwitchToThread";
   [35] = "--- TestAddrinfo.lua ---";
   [36] = "--- TestAll.lua ---";
   [37] = "--- TestKqueue.lua ---";
   [38] = "INFINITE";
   [39] = "--- TestLinux.lua ---";
   [40] = "--- TestSharedMemory.lua ---";
   [41] = "--- TestSignal.lua ---";
   [42] = "--- TestSignal_bad.lua ---";
   [43] = "--- TestSocket.lua ---";
   [44] = "SD_SEND";
   [45] = "--- TestThread.lua ---";
};
]]