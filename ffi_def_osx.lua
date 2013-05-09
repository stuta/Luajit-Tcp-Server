-- ffi_def_osx.lua
module(..., package.seeall)

local ffi = require "ffi"

-- Lua state - creating a new Lua state to a new thread
ffi.cdef([[
	/* garbage-collection function and options */
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
]])


-- ******************** --
-- everything above this will stay, below will change --
-- generated code start --

--[[ lib_date_time.lua ]]
ffi.cdef[[
	typedef long __darwin_time_t;
	typedef __darwin_time_t time_t;
	
	double difftime(time_t, time_t);
	typedef signed char __int8_t;
]]

--[[ lib_kqueue.lua ]]
ffi.cdef[[
	int kqueue(void);
]]

--[[ lib_poll.lua ]]
ffi.cdef[[
	static const int POLLERR = 0x0008;
	static const int POLLHUP = 0x0010;
	static const int POLLIN = 0x0001;
	static const int POLLNVAL = 0x0020;
	static const int POLLOUT = 0x0004;
	static const int POLLPRI = 0x0002;
	
	void free(void *);
	void *realloc(void *, size_t);
]]

--[[ lib_shared_memory.lua ]]
ffi.cdef[[
	static const int IPC_SET = 1;
	static const int MAP_SHARED = 0x0001;
	static const int O_CREAT = 0x0200;
	static const int O_EXCL = 0x0800;
	static const int O_RDONLY = 0x0000;
	static const int O_RDWR = 0x0002;
	static const int PROT_READ = 0x01;
	static const int PROT_WRITE = 0x02;
	
	typedef long long __int64_t;
	typedef __uint32_t __darwin_gid_t;
	typedef unsigned short __uint16_t;
	typedef __uint16_t __darwin_mode_t;
	typedef int __int32_t;
	typedef unsigned int __uint32_t;
	typedef __int32_t __darwin_pid_t;
	typedef __int64_t __darwin_off_t;
	typedef __darwin_gid_t gid_t;
	typedef __uint32_t __darwin_uid_t;
	typedef __int32_t key_t;
	typedef __darwin_mode_t mode_t;
	typedef __darwin_uid_t uid_t;
	#pragma pack(4)
	struct ipc_perm
	{
	 uid_t uid;
	 gid_t gid;
	 uid_t cuid;
	 gid_t cgid;
	 mode_t mode;
	 unsigned short _seq;
	 key_t _key;
	};
	#pragma pack()
	typedef __darwin_off_t off_t;
	typedef __darwin_pid_t pid_t;
	typedef unsigned short shmatt_t;
	struct __shmid_ds_new
	{
	 struct ipc_perm shm_perm;
	 size_t shm_segsz;
	 pid_t shm_lpid;
	 pid_t shm_cpid;
	 shmatt_t shm_nattch;
	 time_t shm_atime;
	 time_t shm_dtime;
	 time_t shm_ctime;
	 void *shm_internal;
	};
	
	int close(int);
	int ftruncate(int, off_t);
	void * mmap(void *, size_t, int, int, int, off_t);
	int munmap(void *, size_t);
	int shm_open(const char *, int, ...);
	int shm_unlink(const char *);
	int shmctl(int, int, struct __shmid_ds_new *);
	size_t strlen(const char *);
]]

--[[ lib_signal.lua ]]
ffi.cdef[[
	typedef __uint32_t __darwin_sigset_t;
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
	const char *gai_strerror(int);
]]

--[[ lib_tcp.lua ]]
ffi.cdef[[
	static const int AF_INET = 2;
	static const int AF_INET6 = 30;
	static const int AI_PASSIVE = 0x00000001;
	static const int INADDR_ANY = (u_int32_t)0x00000000;
	static const int INET6_ADDRSTRLEN = 46;
	static const int INET_ADDRSTRLEN = 16;
	static const int IPPROTO_TCP = 6;
	static const int NI_MAXHOST = 1025;
	static const int NI_MAXSERV = 32;
	static const int SO_RCVBUF = 0x1002;
	static const int SO_REUSEADDR = 0x0004;
	static const int SO_SNDBUF = 0x1001;
	static const int SO_USELOOPBACK = 0x0040;
	static const int SOCK_STREAM = 1;
	static const int SOL_SOCKET = 0xffff;
	static const int SOMAXCONN = 128;
	static const int TCP_NODELAY = 0x01;
	
	typedef __uint32_t in_addr_t;
	struct in_addr {
	 in_addr_t s_addr;
	};
	
	int inet_aton(const char *, struct in_addr *);
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
	struct _opaque_pthread_attr_t { long __sig; char __opaque[56]; };
	typedef struct _opaque_pthread_t
	   *__darwin_pthread_t;
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
	static const int POLLIN = 0x0001;
	
	typedef __uint32_t __darwin_useconds_t;
	typedef __darwin_useconds_t useconds_t;
	typedef __int32_t __darwin_suseconds_t;
	struct timeval
	{
	 __darwin_time_t tv_sec;
	 __darwin_suseconds_t tv_usec;
	};
	struct timespec;
	
	int gettimeofday(struct timeval * , void * );
	int nanosleep(const struct timespec *, struct timespec *);
	extern int sched_yield(void);
	char *strerror(int);
	long sysconf(int);
	int usleep(useconds_t);
]]


--[[
not found calls = {
   [1] = "--- lib_date_time.lua ---";
   [2] = "--- lib_kqueue.lua ---";
   [3] = "--- lib_poll.lua ---";
   [4] = "POLLRDHUP";
   [5] = "--- lib_shared_memory.lua ---";
   [6] = "CloseHandle";
   [7] = "CreateFileA";
   [8] = "CreateFileMappingA";
   [9] = "DeleteFileA";
   [10] = "GetFileSize";
   [11] = "GetLastError";
   [12] = "MapViewOfFile";
   [13] = "OpenFileMappingA";
   [14] = "UnmapViewOfFile";
   [15] = "--- lib_signal.lua ---";
   [16] = "--- lib_socket.lua ---";
   [17] = "--- lib_tcp.lua ---";
   [18] = "--- lib_thread.lua ---";
   [19] = "CreateThread";
   [20] = "GetCurrentThreadId";
   [21] = "INFINITE";
   [22] = "WaitForSingleObject";
   [23] = "--- lib_util.lua ---";
   [24] = "ENABLE_ECHO_INPUT";
   [25] = "ENABLE_LINE_INPUT";
   [26] = "ENABLE_PROCESSED_INPUT";
   [27] = "FORMAT_MESSAGE_FROM_SYSTEM";
   [28] = "FORMAT_MESSAGE_IGNORE_INSERTS";
   [29] = "GetConsoleMode";
   [30] = "GetStdHandle";
   [31] = "GetSystemInfo";
   [32] = "QueryPerformanceCounter";
   [33] = "QueryPerformanceFrequency";
   [34] = "ReadConsoleA";
   [35] = "SetConsoleMode";
   [36] = "Sleep";
   [37] = "STD_INPUT_HANDLE";
   [38] = "SwitchToThread";
};
]]