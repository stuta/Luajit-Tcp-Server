--  ffi_def_thread.lua
dofile "ffi_def_util.lua"
local ffi = require("ffi")
local C = ffi.C

-- kqueue, kevent
--[[
https://bitbucket.org/armatys/perun/src/f106ac49f19ae6aa7a0615914420d2a7e7f370e6/lua/perun/init.lua
http://julipedia.meroh.net/2004/10/example-of-kqueue.html
]]
ffi.cdef([[
  struct kevent {
    uintptr_t ident;    /* identifier for this event */
    short filter;       /* filter for event */
    unsigned short flags; /* action flags for kqueue */
    unsigned int fflags;  /* filter flag value */
    intptr_t data;        /* filter data value */
    void *udata;        /* opaque user data identifier */
  };

  int kqueue();
  int kevent(int kq, const struct kevent* changelist, int nchanges,
    struct kevent* eventlist, int nevents, void* timeout);
    
  /* -- not needed
  int kevent64(int kq, const struct kevent64_s *changelist, 
  	int nchanges, struct kevent64_s *eventlist, int nevents, 
  	unsigned int flags, const struct timespec *timeout);
	EV_SET(&kev, ident, filter, flags, fflags, data, udata);
	EV_SET64(&kev, ident, filter, flags, fflags, data, udata, ext[_], ext[1]);
	
	void mutex_lock();
	bool mutex_try_lock();
	void mutex_unlock();
	*/
	
]])

-- Constants
local eventcount = 512
local intptr_t = ffi.typeof('intptr_t')
local kevent_array1 = ffi.typeof('struct kevent[1]')

local context = {}
function context:init()
  self.handlers = {} -- dictionary of handlers for given event family
  self.isrunning = false -- tells whether the loop should keep running
  self.kevents = ffi.new('struct kevent[?]', eventcount) -- Stores events fetched when polling the kqfd
  self.kqfd = C.kqueue() -- a file descriptor for the kqueue
  self.listeners = { ['read'] = {}, ['write'] = {}, ['timeout'] = {} } -- list of callbacks for particular events
  self.timerid = 1 -- a counter for timeout fd (for the use of kqueue)
  self.defers = {}
end
context:init()
--print(table.show(context, "context"))

local function setkevent(kqfd, fd, filter, flags, fflags, data, udata)
  local kev = kevent_array_1()
  kev[0].ident = fd
  kev[0].filter = filter
  kev[0].flags = flags
  kev[0].fflags = fflags
  kev[0].data = data
  kev[0].udata = udata
  if C.kevent(kqfd, kev, 1, nil, 0, nil) == -1 then
    return nil
  end
  return fd
end


-- thread
--[[
https://github.com/hnakamur/luajit-examples/blob/master/pthread/thread1.lua
http://pubs.opengroup.org/onlinepubs/007908799/xsh/pthread.h.html
/System/Library/Frameworks/Kernel.framework/Versions/A/Headers/kern/thread.h 
/System/Library/Frameworks/Kernel.framework/Versions/A/Headers/sys/_types.h 
/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/usr/include/pthread.h
]]
ffi.cdef([[
	static const int __PTHREAD_SIZE__ = 1168;
	struct __darwin_pthread_handler_rec
	{
		void           (*__routine)(void *);	/* Routine to call */
		void           *__arg;			/* Argument to pass */
		struct __darwin_pthread_handler_rec *__next;
	};
	struct _opaque_pthread_t { long __sig; struct __darwin_pthread_handler_rec  *__cleanup_stack
			; char __opaque[__PTHREAD_SIZE__]; };
	typedef struct _opaque_pthread_t *__darwin_pthread_t;
	
	typedef __darwin_pthread_t		pthread_t; // OSX
	//typedef unsigned long int pthread_t;  // Linux?
	
	static const int __PTHREAD_ATTR_SIZE__ = 56;
	struct _opaque_pthread_attr_t { long __sig; char __opaque[__PTHREAD_ATTR_SIZE__]; };
	typedef struct _opaque_pthread_attr_t __darwin_pthread_attr_t;
	typedef __darwin_pthread_attr_t		pthread_attr_t;

	int       pthread_create(pthread_t * __restrict,
                         const pthread_attr_t * __restrict,
                         void *(*)(void *),
                         void * __restrict);
	int       pthread_detach(pthread_t );
	int       pthread_equal(pthread_t , pthread_t );
	void      pthread_exit(void *);
	int       pthread_join(pthread_t , void **);
	pthread_t pthread_self(void);
	
	/* from: https://github.com/hnakamur/luajit-examples/blob/master/pthread/thread1.lua */
	// needed inluaThreadCreate(): ffi.cast("thread_func", func_ptr)
	typedef void *(*thread_func)(void *); 

	/*
		// Code for simulating pthreads API on Windows.
		// https://github.com/FrancescAlted/blosc/blob/master/blosc/win32/pthread.c
		int  pthread_create(pthread_t *thread, pthread_attr_t *attr, void *(*start_routine) (void *), void *arg);
		int  pthread_join (pthread_t th, void **thread_return);
		void pthread_exit (void *retval);

		int pthread_mutex_init (pthread_mutex_t *mutex, pthread_mutexattr_t *mutex_attr);
		int pthread_mutex_destroy (pthread_mutex_t *mutex);
		int pthread_mutex_lock (pthread_mutex_t *mutex);
		int pthread_mutex_unlock (pthread_mutex_t *mutex);
	*/
	
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


-- Lua state - creating a new Lua state to a new thread
ffi.cdef([[
	typedef struct lua_State lua_State;
	lua_State *luaL_newstate(void);
	void luaL_openlibs(lua_State *L);
	void lua_close(lua_State *L);
	int luaL_loadstring(lua_State *L, const char *s);
	int lua_pcall(lua_State *L, int nargs, int nresults, int errfunc);
	
	static const int LUA_GLOBALSINDEX = -10002;
	void lua_getfield(lua_State *L, int index, const char *k);
	ptrdiff_t lua_tointeger(lua_State *L, int index);
	void lua_settop(lua_State *L, int index);
]])

function threadFuncToAddress(thread_entry) 
  return tonumber(ffi.cast('intptr_t', ffi.cast('void *(*)(void *)', thread_entry)))
end

function threadToId(thread) 
  -- return tonumber(ffi.cast('intptr_t', ffi.cast('void *', thread[0])))
  -- return ffi.string(ffi.cast('intptr_t', ffi.cast('void *', thread[0])))
  -- return tostring(ffi.cast('void *', thread))
  return tostring(ffi.cast('intptr_t', ffi.cast('void *', thread[0]))) -- is this ok?
end

function threadSelf()
	local id = C.pthread_self()
	--if ffi.os == "OSX" then 
	return threadToId(id)
	--return tostring(ffi.cast("char *", pid)) --tonumber(ffi.cast("uint32_t", id)) 		--tonumber(pid)
end

-- create a separate Lua state first
-- define a callback function in *that* created state
function luaStateCreate(lua_code)
	local L = C.luaL_newstate()
	assert(L ~= nil)
	C.luaL_openlibs(L)
	
	assert(C.luaL_loadstring(L, lua_code) == 0)
	local res = C.lua_pcall(L, 0, 1, 0) -- runs code 
	-- defines functions and variables, we need thread_entry_address -variable
	-- that is the thread_entry() -function memory pointer Lua-number
	assert(res == 0)
	
	-- get function thread_entry() address from calling thread
	-- http://pgl.yoyo.org/luai/i/lua_call
	C.lua_getfield(L, C.LUA_GLOBALSINDEX, "thread_entry_address") -- function to be called
	local func_ptr = C.lua_tointeger(L, -1); -- lua_getfield value
	C.lua_settop(L, -2); -- set stack to correct (prev call params -1?)
	return L, func_ptr
end


-- Destroys all objects in the given Lua state
-- if Lua state is still running you WILL get crash
function luaStateDelete(luaState) 
	C.lua_close(luaState)
end

-- then use pthread_create() from the original state, passing the callback address of the other state
function luaThreadCreate(func_ptr, arg)
	local thread_c = ffi.new("pthread_t[1]")
	local arg_c = ffi.cast("void *", arg) -- necessary if arg is not cstr, should we we check arg type?
	local res = C.pthread_create(thread_c, nil, ffi.cast("thread_func", func_ptr), arg_c)
	assert(res == 0)
	return thread_c -- thread_c,threadToId(thread_c)
end

function threadJoin(thread_id)
	local return_val = ffi.new("int[1]")
	local return_ptr = ffi.cast('void *', return_val)
	local res = C.pthread_join(thread_id[0], return_ptr) -- and IN thread C.pthread_exit(100)
	return return_val[0]
end

function threadExit(return_val)
	local return_ptr = ffi.cast('void *', return_val)
	ffi.C.pthread_exit(return_ptr)
end

--[[
NOTES
       POSIX.1 allows an implementation wide freedom in choosing the type used to
       represent a thread ID; for example, representation using either an
       arithmetic type or a structure is permitted.  Therefore, variables of type
       pthread_t can't portably be compared using the C equality operator (==);
       use pthread_equal(3) instead.

       Thread identifiers should be considered opaque: any attempt to use a thread
       ID other than in pthreads calls is nonportable and can lead to unspecified
       results.

       Thread IDs are only guaranteed to be unique within a process.  A thread ID
       may be reused after a terminated thread has been joined, or a detached
       thread has terminated.

       The thread ID returned by pthread_self() is not the same thing as the
       kernel thread ID returned by a call to gettid(2).
]]
