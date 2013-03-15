--  TestLinux.lua
print()
print(" -- TestLinux.lua start -- ")
print()

local arg = {...}
local ffi = require("ffi")
local C = ffi.C

--local pthread = ffi.load("/lib/i386-linux-gnu/libpthread-2.15.so")
ffi.cdef[[
	typedef int64_t	off_t;
	typedef unsigned long int pthread_t;
	pthread_t pthread_self(void);

	// extern int shm_open
	int 		shm_unlink(const char *name);
	const char* gai_strerror(int ecode);
  void *dlopen(const char *filename, int flag);
	void      pthread_exit(void *);
	int       pthread_join(pthread_t , void **);

  /*
typedef struct {
    int __detachstate;
    int __schedpolicy;
    struct sched_param __schedparam;
    int __inheritsched;
    int __scope;
    size_t __guardsize;
    int __stackaddr_set;
    void *__stackaddr;
    unsigned long int __stacksize;
} pthread_attr_t;
	extern int pthread_create(pthread_t *, const pthread_attr_t *,
			  void *(*__pshared) (void *p1)
			  , void *);
			  */

	void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
	int munmap(void *addr, size_t length);
]]
print("  -- C.gai_strerror(-5): "..ffi.string(C.gai_strerror(-5)))
print("  -- C.pthread_self()  : "..tonumber(C.pthread_self()))
--[[  -- C.pthread_exit() works, will quit the program
print("  -- C.pthread_exit(11): ")
local arg_c = ffi.cast("void *", 11)
C.pthread_exit(arg_c)
]]

--print("  -- C.mmap(nil, 4096, 0, 0, nil, 0)")
--local sharedMemory = shm_open("shm_area.txt", O_CREAT | O_EXCL, S_IRUSR | S_IWUSR)

print("  -- C.mmap(nil, 4096, 0, 0, nil, 0)")
local mmapArea = C.mmap(nil, 4096, 0, 0, 0, 0)

print("  -- C.munmap(sharedMemory, 4096)")
local i = C.munmap(mmapArea, 4096)

print("  -- C.shm_unlink('asd')")
local arg_c = C.shm_unlink("asd")

--[[
local thread_c = ffi.new("pthread_t[1]")
local arg_c = ffi.cast("void *", 11) -- necessary if arg is not cstr, should we we check arg type?
--local res = C.pthread_create(thread_c, nil, nil, arg_c)

-- http://sourceware.org/ml/libc-help/2012-07/msg00028.html
local anl = ffi.load("anl")
local dl = ffi.load "dl"

--local RTLD_ALL = 266
--local r = dl.dlopen("libpthread.so.0", RTLD_ALL)
--local GAI_NOWAIT = 1
--local r = anl.getaddrinfo_a ( GAI_NOWAIT, list , n , sigevent )
anl.shm_unlink("asd")


--("/usr/lib/i386-linux-gnu/libpthread.so")
print(pthread)
pthread.shm_unlink("asd")
-- C.shm_unlink("asd")
]]

print()
print(" -- TestLinux.lua end -- ")
print()

