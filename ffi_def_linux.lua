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

-- handmade basic types
ffi.cdef[[
	// these are/should be in sys/types.h, but is this safe universal way?
	
	// #define __char signed char
	typedef signed char __char;

]]

ffi.cdef[[
	// bad define macros, done by hand
	struct in6_addr
		{
			union
				{
		uint8_t	__u6_addr8[16];
		uint16_t __u6_addr16[8];
		uint32_t __u6_addr32[4];
				} __in6_u;
	};

	// bad order of generated calls
	
	// missing generation - code these
	static const int PF_INET = 2;
	static const int PF_INET6 = 10;
	
]]


ffi.cdef[[
	// bad enums, done by hand
	enum
  {
    _SC_ARG_MAX,
    _SC_CHILD_MAX,
    _SC_CLK_TCK,
    _SC_NGROUPS_MAX,
    _SC_OPEN_MAX,
    _SC_STREAM_MAX,
    _SC_TZNAME_MAX,
    _SC_JOB_CONTROL,
    _SC_SAVED_IDS,
    _SC_REALTIME_SIGNALS,
    _SC_PRIORITY_SCHEDULING,
    _SC_TIMERS,
    _SC_ASYNCHRONOUS_IO,
    _SC_PRIORITIZED_IO,
    _SC_SYNCHRONIZED_IO,
    _SC_FSYNC,
    _SC_MAPPED_FILES,
    _SC_MEMLOCK,
    _SC_MEMLOCK_RANGE,
    _SC_MEMORY_PROTECTION,
    _SC_MESSAGE_PASSING,
    _SC_SEMAPHORES,
    _SC_SHARED_MEMORY_OBJECTS,
    _SC_AIO_LISTIO_MAX,
    _SC_AIO_MAX,
    _SC_AIO_PRIO_DELTA_MAX,
    _SC_DELAYTIMER_MAX,
    _SC_MQ_OPEN_MAX,
    _SC_MQ_PRIO_MAX,
    _SC_VERSION,
    _SC_PAGESIZE,
    _SC_RTSIG_MAX,
    _SC_SEM_NSEMS_MAX,
    _SC_SEM_VALUE_MAX,
    _SC_SIGQUEUE_MAX,
    _SC_TIMER_MAX,
    _SC_BC_BASE_MAX,
    _SC_BC_DIM_MAX,
    _SC_BC_SCALE_MAX,
    _SC_BC_STRING_MAX,
    _SC_COLL_WEIGHTS_MAX,
    _SC_EQUIV_CLASS_MAX,
    _SC_EXPR_NEST_MAX,
    _SC_LINE_MAX,
    _SC_RE_DUP_MAX,
    _SC_CHARCLASS_NAME_MAX,
    _SC_2_VERSION,
    _SC_2_C_BIND,
    _SC_2_C_DEV,
    _SC_2_FORT_DEV,
    _SC_2_FORT_RUN,
    _SC_2_SW_DEV,
    _SC_2_LOCALEDEF,
    _SC_PII,
    _SC_PII_XTI,
    _SC_PII_SOCKET,
    _SC_PII_INTERNET,
    _SC_PII_OSI,
    _SC_POLL,
    _SC_SELECT,
    _SC_UIO_MAXIOV,
    _SC_IOV_MAX = _SC_UIO_MAXIOV,
    _SC_PII_INTERNET_STREAM,
    _SC_PII_INTERNET_DGRAM,
    _SC_PII_OSI_COTS,
    _SC_PII_OSI_CLTS,
    _SC_PII_OSI_M,
    _SC_T_IOV_MAX,
    _SC_THREADS,
    _SC_THREAD_SAFE_FUNCTIONS,
    _SC_GETGR_R_SIZE_MAX,
    _SC_GETPW_R_SIZE_MAX,
    _SC_LOGIN_NAME_MAX,
    _SC_TTY_NAME_MAX,
    _SC_THREAD_DESTRUCTOR_ITERATIONS,
    _SC_THREAD_KEYS_MAX,
    _SC_THREAD_STACK_MIN,
    _SC_THREAD_THREADS_MAX,
    _SC_THREAD_ATTR_STACKADDR,
    _SC_THREAD_ATTR_STACKSIZE,
    _SC_THREAD_PRIORITY_SCHEDULING,
    _SC_THREAD_PRIO_INHERIT,
    _SC_THREAD_PRIO_PROTECT,
    _SC_THREAD_PROCESS_SHARED,
    _SC_NPROCESSORS_CONF,
    _SC_NPROCESSORS_ONLN,
    _SC_PHYS_PAGES,
    _SC_AVPHYS_PAGES,
    _SC_ATEXIT_MAX,
    _SC_PASS_MAX,
    _SC_XOPEN_VERSION,
    _SC_XOPEN_XCU_VERSION,
    _SC_XOPEN_UNIX,
    _SC_XOPEN_CRYPT,
    _SC_XOPEN_ENH_I18N,
    _SC_XOPEN_SHM,
    _SC_2_CHAR_TERM,
    _SC_2_C_VERSION,
    _SC_2_UPE,
    _SC_XOPEN_XPG2,
    _SC_XOPEN_XPG3,
    _SC_XOPEN_XPG4,
    _SC_CHAR_BIT,
    _SC_CHAR_MAX,
    _SC_CHAR_MIN,
    _SC_INT_MAX,
    _SC_INT_MIN,
    _SC_LONG_BIT,
    _SC_WORD_BIT,
    _SC_MB_LEN_MAX,
    _SC_NZERO,
    _SC_SSIZE_MAX,
    _SC_SCHAR_MAX,
    _SC_SCHAR_MIN,
    _SC_SHRT_MAX,
    _SC_SHRT_MIN,
    _SC_UCHAR_MAX,
    _SC_UINT_MAX,
    _SC_ULONG_MAX,
    _SC_USHRT_MAX,
    _SC_NL_ARGMAX,
    _SC_NL_LANGMAX,
    _SC_NL_MSGMAX,
    _SC_NL_NMAX,
    _SC_NL_SETMAX,
    _SC_NL_TEXTMAX,
    _SC_XBS5_ILP32_OFF32,
    _SC_XBS5_ILP32_OFFBIG,
    _SC_XBS5_LP64_OFF64,
    _SC_XBS5_LPBIG_OFFBIG,
    _SC_XOPEN_LEGACY,
    _SC_XOPEN_REALTIME,
    _SC_XOPEN_REALTIME_THREADS,
    _SC_ADVISORY_INFO,
    _SC_BARRIERS,
    _SC_BASE,
    _SC_C_LANG_SUPPORT,
    _SC_C_LANG_SUPPORT_R,
    _SC_CLOCK_SELECTION,
    _SC_CPUTIME,
    _SC_THREAD_CPUTIME,
    _SC_DEVICE_IO,
    _SC_DEVICE_SPECIFIC,
    _SC_DEVICE_SPECIFIC_R,
    _SC_FD_MGMT,
    _SC_FIFO,
    _SC_PIPE,
    _SC_FILE_ATTRIBUTES,
    _SC_FILE_LOCKING,
    _SC_FILE_SYSTEM,
    _SC_MONOTONIC_CLOCK,
    _SC_MULTI_PROCESS,
    _SC_SINGLE_PROCESS,
    _SC_NETWORKING,
    _SC_READER_WRITER_LOCKS,
    _SC_SPIN_LOCKS,
    _SC_REGEXP,
    _SC_REGEX_VERSION,
    _SC_SHELL,
    _SC_SIGNALS,
    _SC_SPAWN,
    _SC_SPORADIC_SERVER,
    _SC_THREAD_SPORADIC_SERVER,
    _SC_SYSTEM_DATABASE,
    _SC_SYSTEM_DATABASE_R,
    _SC_TIMEOUTS,
    _SC_TYPED_MEMORY_OBJECTS,
    _SC_USER_GROUPS,
    _SC_USER_GROUPS_R,
    _SC_2_PBS,
    _SC_2_PBS_ACCOUNTING,
    _SC_2_PBS_LOCATE,
    _SC_2_PBS_MESSAGE,
    _SC_2_PBS_TRACK,
    _SC_SYMLOOP_MAX,
    _SC_STREAMS,
    _SC_2_PBS_CHECKPOINT,
    _SC_V6_ILP32_OFF32,
    _SC_V6_ILP32_OFFBIG,
    _SC_V6_LP64_OFF64,
    _SC_V6_LPBIG_OFFBIG,
    _SC_HOST_NAME_MAX,
    _SC_TRACE,
    _SC_TRACE_EVENT_FILTER,
    _SC_TRACE_INHERIT,
    _SC_TRACE_LOG,
    _SC_LEVEL1_ICACHE_SIZE,
    _SC_LEVEL1_ICACHE_ASSOC,
    _SC_LEVEL1_ICACHE_LINESIZE,
    _SC_LEVEL1_DCACHE_SIZE,
    _SC_LEVEL1_DCACHE_ASSOC,
    _SC_LEVEL1_DCACHE_LINESIZE,
    _SC_LEVEL2_CACHE_SIZE,
    _SC_LEVEL2_CACHE_ASSOC,
    _SC_LEVEL2_CACHE_LINESIZE,
    _SC_LEVEL3_CACHE_SIZE,
    _SC_LEVEL3_CACHE_ASSOC,
    _SC_LEVEL3_CACHE_LINESIZE,
    _SC_LEVEL4_CACHE_SIZE,
    _SC_LEVEL4_CACHE_ASSOC,
    _SC_LEVEL4_CACHE_LINESIZE,
    _SC_IPV6 = _SC_LEVEL1_ICACHE_SIZE + 50,
    _SC_RAW_SOCKETS,
    _SC_V7_ILP32_OFF32,
    _SC_V7_ILP32_OFFBIG,
    _SC_V7_LP64_OFF64,
    _SC_V7_LPBIG_OFFBIG,
    _SC_SS_REPL_MAX,
    _SC_TRACE_EVENT_NAME_MAX,
    _SC_TRACE_NAME_MAX,
    _SC_TRACE_SYS_MAX,
    _SC_TRACE_USER_EVENT_MAX,
    _SC_XOPEN_STREAMS,
    _SC_THREAD_ROBUST_PRIO_INHERIT,
    _SC_THREAD_ROBUST_PRIO_PROTECT
  };
]]


-- everything above will stay, below will be generated --
-- ******************** --
-- generated code start --

--[[ lib_date_time.lua ]]
ffi.cdef[[
	 typedef long int __time_t;
	typedef __time_t time_t;
	
	double difftime (time_t __time1, time_t __time0)
    ;
	time_t time (time_t *__timer);
]]

--[[ lib_http.lua ]]
--[[ lib_kqueue.lua ]]
--[[ lib_poll.lua ]]
ffi.cdef[[
	static const int POLLERR = 0x008;
	static const int POLLHUP = 0x010;
	static const int POLLIN = 0x001;
	static const int POLLNVAL = 0x020;
	static const int POLLOUT = 0x004;
	
	struct pollfd
	  {
	    int fd;
	    short int events;
	    short int revents;
	  };
	
	
	void free (void *__ptr);
	void *realloc (void *__ptr, size_t __size)
    ;
]]

--[[ lib_shared_memory.lua ]]
ffi.cdef[[
	static const int MAP_SHARED = 0x01;
	static const int O_CREAT = 0100;
	static const int O_RDONLY = 00;
	static const int O_RDWR = 02;
	static const int PROT_READ = 0x1;
	static const int PROT_WRITE = 0x2;
	
	 typedef unsigned int __mode_t;
	 typedef long int __off_t;
	typedef __mode_t mode_t;
	
	int close (int __fd);
	int ftruncate (int __fd, __off_t __length);
	void *mmap (void *__addr, size_t __len, int __prot,
     int __flags, int __fd, __off_t __offset);
	int munmap (void *__addr, size_t __len);
	int shm_open (const char *__name, int __oflag, mode_t __mode);
	int shm_unlink (const char *__name);
	size_t strlen (const char *__s)
    ;
]]

--[[ lib_signal.lua ]]
ffi.cdef[[
	typedef struct
	  {
	    unsigned long int __val[(1024 / (8 * sizeof (unsigned long int)))];
	  } __sigset_t;
	
	typedef __sigset_t sigset_t;
	 typedef int __pid_t;
	
	__pid_t getpid (void);
	int kill (__pid_t __pid, int __sig);
	int pthread_sigmask (int __how,
       const __sigset_t *__newmask,
       __sigset_t *__oldmask)__attribute__ ((__nothrow__ , __leaf__));
	int sigaddset (sigset_t *__set, int __signo);
	int sigemptyset (sigset_t *__set);
	int sigwait (const sigset_t *__set, int *__sig)
    ;
]]

--[[ lib_socket.lua ]]
ffi.cdef[[
	static const int F_GETFL = 3;
	static const int F_SETFL = 4;
	static const int O_NONBLOCK = 04000;
	
	typedef uint32_t in_addr_t;
	typedef unsigned short int sa_family_t;
	typedef unsigned long int nfds_t;
	typedef uint16_t in_port_t;
	
	 typedef int __ssize_t;
	struct sockaddr
	  {
	    sa_family_t sa_family;
	    char sa_data[14];
	  };
	
	typedef __ssize_t ssize_t;
	struct in_addr
	  {
	    in_addr_t s_addr;
	  };
	
	 typedef unsigned int __socklen_t;
	typedef __socklen_t socklen_t;
	struct sockaddr_in
	  {
	    sa_family_t sin_family;
	    in_port_t sin_port;
	    struct in_addr sin_addr;
	    unsigned char sin_zero[sizeof (struct sockaddr) -
	      (sizeof (unsigned short int)) -
	      sizeof (in_port_t) -
	      sizeof (struct in_addr)];
	  };
	
	struct addrinfo
	{
	  int ai_flags;
	  int ai_family;
	  int ai_socktype;
	  int ai_protocol;
	  socklen_t ai_addrlen;
	  struct sockaddr *ai_addr;
	  char *ai_canonname;
	  struct addrinfo *ai_next;
	};
	
	
	int accept (int __fd, struct sockaddr *__addr,
     socklen_t *__addr_len);
	int bind (int __fd, const struct sockaddr * __addr, socklen_t __len)
    ;
	int connect (int __fd, const struct sockaddr * __addr, socklen_t __len);
	int fcntl (int __fd, int __cmd, ...);
	const char *gai_strerror (int __ecode);
	int getaddrinfo (const char *__name,
   const char *__service,
   const struct addrinfo *__req,
   struct addrinfo **__pai);
	int getnameinfo (const struct sockaddr *__sa,
   socklen_t __salen, char *__host,
   socklen_t __hostlen, char *__serv,
   socklen_t __servlen, int __flags);
	int getpeername (int __fd, struct sockaddr *__addr,
   socklen_t *__len);
	int getsockopt (int __fd, int __level, int __optname,
         void *__optval,
         socklen_t *__optlen);
	uint16_t htons (uint16_t __hostshort)
    ;
	const char *inet_ntop (int __af, const void *__cp,
    char *__buf, socklen_t __len)
    ;
	int listen (int __fd, int __n);
	uint16_t ntohs (uint16_t __netshort)
    ;
	int poll (struct pollfd *__fds, nfds_t __nfds, int __timeout);
	ssize_t recv (int __fd, void *__buf, size_t __n, int __flags);
	ssize_t send (int __fd, const void *__buf, size_t __n, int __flags);
	int setsockopt (int __fd, int __level, int __optname,
         const void *__optval, socklen_t __optlen);
	int shutdown (int __fd, int __how);
	int socket (int __domain, int __type, int __protocol);
]]

--[[ lib_tcp.lua ]]
ffi.cdef[[
	static const int AF_INET = PF_INET;
	static const int AF_INET6 = PF_INET6;
	static const int AI_PASSIVE = 0x0001;
	static const int INET6_ADDRSTRLEN = 46;
	static const int INET_ADDRSTRLEN = 16;
	static const int SO_RCVBUF = 8;
	static const int SO_REUSEADDR = 2;
	static const int SO_SNDBUF = 7;
	static const int SOL_SOCKET = 1;
	static const int SOMAXCONN = 128;
	static const int TCP_NODELAY = 1;
	
	struct sockaddr_storage
	  {
	    sa_family_t ss_family;
	    unsigned long int __ss_align;
	    char __ss_padding[(128 - (2 * sizeof (unsigned long int)))];
	  };
	
	struct sockaddr_in6
	  {
	    sa_family_t sin6_family;
	    in_port_t sin6_port;
	    uint32_t sin6_flowinfo;
	    struct in6_addr sin6_addr;
	    uint32_t sin6_scope_id;
	  };
	
	
	enum
  {
    IPPROTO_IP = 0,
    IPPROTO_HOPOPTS = 0,
    IPPROTO_ICMP = 1,
    IPPROTO_IGMP = 2,
    IPPROTO_IPIP = 4,
    IPPROTO_TCP = 6,
    IPPROTO_EGP = 8,
    IPPROTO_PUP = 12,
    IPPROTO_UDP = 17,
    IPPROTO_IDP = 22,
    IPPROTO_TP = 29,
    IPPROTO_DCCP = 33,
    IPPROTO_IPV6 = 41,
    IPPROTO_ROUTING = 43,
    IPPROTO_FRAGMENT = 44,
    IPPROTO_RSVP = 46,
    IPPROTO_GRE = 47,
    IPPROTO_ESP = 50,
    IPPROTO_AH = 51,
    IPPROTO_ICMPV6 = 58,
    IPPROTO_NONE = 59,
    IPPROTO_DSTOPTS = 60,
    IPPROTO_MTP = 92,
    IPPROTO_ENCAP = 98,
    IPPROTO_PIM = 103,
    IPPROTO_COMP = 108,
    IPPROTO_SCTP = 132,
    IPPROTO_UDPLITE = 136,
    IPPROTO_RAW = 255,
    IPPROTO_MAX
  };
	    struct in6_addr sin6_addr;
	    in_port_t sin6_port;
	enum __socket_type
{
  SOCK_STREAM = 1,
  SOCK_DGRAM = 2,
  SOCK_RAW = 3,
  SOCK_RDM = 4,
  SOCK_SEQPACKET = 5,
  SOCK_DCCP = 6,
  SOCK_PACKET = 10,
  SOCK_CLOEXEC = 02000000,
  SOCK_NONBLOCK = 04000
};
]]

--[[ lib_thread.lua ]]
ffi.cdef[[
	typedef union
	{
	  char __size[36];
	  long int __align;
	} pthread_attr_t;
	typedef unsigned long int pthread_t;
	int pthread_create (pthread_t *__newthread,
      const pthread_attr_t *__attr,
      void *(*__start_routine) (void *),
      void *__arg);
	void pthread_exit (void *__retval);
	int pthread_join (pthread_t __th, void **__thread_return);
	pthread_t pthread_self (void);
]]

--[[ lib_util.lua ]]
ffi.cdef[[
	struct timezone
	  {
	    int tz_minuteswest;
	    int tz_dsttime;
	  };
	
	 typedef long int __suseconds_t;
	 typedef unsigned int __useconds_t;
	struct timespec
	  {
	    __time_t tv_sec;
	    long int tv_nsec;
	  };
	
	typedef struct timezone *__timezone_ptr_t;
	struct timeval
	  {
	    __time_t tv_sec;
	    __suseconds_t tv_usec;
	  };
	
	
	int gettimeofday (struct timeval *__tv,
    __timezone_ptr_t __tz);
	int nanosleep (const struct timespec *__requested_time,
        struct timespec *__remaining);
	int sched_yield (void);
	char *strerror (int __errnum);
	long int sysconf (int __name);
	int usleep (__useconds_t __useconds);
]]

--[[ TestAddrinfo.lua ]]
ffi.cdef[[
	static const int AI_CANONNAME = 0x0002;
	static const int NI_MAXHOST = 1025;
	static const int NI_MAXSERV = 32;
	static const int NI_NAMEREQD = 8;
	static const int NI_NUMERICHOST = 1;
	static const int NI_NUMERICSERV = 2;
]]

--[[ TestAll.lua ]]
--[[ TestKqueue.lua ]]
ffi.cdef[[
	int open (const char *__file, int __oflag, ...);
]]

--[[ TestLinux.lua ]]
ffi.cdef[[
	static const int O_EXCL = 0200;
]]

--[[ TestSharedMemory.lua ]]
--[[ TestSignal.lua ]]
--[[ TestSignal_bad.lua ]]
ffi.cdef[[
	typedef void (*__sighandler_t) (int);
	
	int pause (void);
	__sighandler_t signal (int __sig, __sighandler_t __handler)
    ;
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
   [14] = "closesocket";
   [15] = "ioctlsocket";
   [16] = "WSAAddressToStringA";
   [17] = "WSACleanup";
   [18] = "WSAGetLastError";
   [19] = "WSAPoll";
   [20] = "WSAStartup";
   [21] = "--- lib_tcp.lua ---";
   [22] = "SO_USELOOPBACK";
   [23] = "--- lib_thread.lua ---";
   [24] = "CreateThread";
   [25] = "GetCurrentThreadId";
   [26] = "INFINITE";
   [27] = "WaitForSingleObject";
   [28] = "--- lib_util.lua ---";
   [29] = "ENABLE_ECHO_INPUT";
   [30] = "ENABLE_LINE_INPUT";
   [31] = "FORMAT_MESSAGE_FROM_SYSTEM";
   [32] = "FORMAT_MESSAGE_IGNORE_INSERTS";
   [33] = "GetConsoleMode";
   [34] = "GetStdHandle";
   [35] = "GetSystemInfo";
   [36] = "QueryPerformanceCounter";
   [37] = "QueryPerformanceFrequency";
   [38] = "ReadConsoleA";
   [39] = "SetConsoleMode";
   [40] = "Sleep";
   [41] = "STD_INPUT_HANDLE";
   [42] = "SwitchToThread";
   [43] = "--- TestAddrinfo.lua ---";
   [44] = "--- TestAll.lua ---";
   [45] = "--- TestKqueue.lua ---";
   [46] = "EV_ADD";
   [47] = "EV_ENABLE";
   [48] = "EV_ONESHOT";
   [49] = "EVFILT_VNODE";
   [50] = "INFINITE";
   [51] = "kevent";
   [52] = "kqueue";
   [53] = "NOTE_ATTRIB";
   [54] = "NOTE_DELETE";
   [55] = "NOTE_EXTEND";
   [56] = "NOTE_WRITE";
   [57] = "--- TestLinux.lua ---";
   [58] = "--- TestSharedMemory.lua ---";
   [59] = "--- TestSignal.lua ---";
   [60] = "--- TestSignal_bad.lua ---";
   [61] = "--- TestSocket.lua ---";
   [62] = "SD_SEND";
   [63] = "--- TestThread.lua ---";
};
]]