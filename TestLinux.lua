--  TestLinux.lua
print()
print(" -- TestLinux.lua start -- ")
print()

local arg = {...}
local ffi = require "ffi" 
local C = ffi.C
local bit = require "bit"

--local pthread = ffi.load("/lib/i386-linux-gnu/libpthread-2.15.so")
ffi.cdef[[
	typedef int64_t	off_t;
	typedef uint16_t mode_t;
	typedef unsigned long int pthread_t;
	pthread_t pthread_self(void);

	int 		shm_open(const char *name, int oflag, mode_t mode);
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
print()

if ffi.os == "OSX" then
	print("OSX")
	ffi.cdef[[
		static const int O_CREAT 	= 0x0200;		/* create if nonexistant */
		static const int O_TRUNC	= 0x0400;		/* truncate to zero length */
		static const int O_EXCL		= 0x0800;		/* error if already exists */
	]]
else
	print("Linux")
	ffi.cdef[[
		/* octal (8-base) values in Linux header file in fcntl.h
		dec:
		O_CREAT, O_EXCL: 64, 128
		S_IRUSR, S_IWUSR: 256, 128
		flags, flags_file: 192, 384

		static const int	S_IRUSR	= 0400;	// Read by owner.
		static const int	S_IWUSR	= 0200;	// Write by owner.
		static const int	S_IXUSR	= 0100;	// Execute by owner.

		static const int O_CREAT	= 0100;
		static const int O_EXCL		= 0200;
		static const int O_TRUNC	= 01000;
		*/
		static const int O_CREAT	= 64;
		static const int O_EXCL		= 128;
		static const int O_TRUNC	= 512;

	]]
end

local flags = bit.bor(C.O_CREAT, C.O_EXCL)
local flags_file = 755 --bit.bor(C.S_IRUSR, C.S_IWUSR)
print("  -- C.O_CREAT, C.O_EXCL): ", C.O_CREAT, C.O_EXCL)
--print("  -- C.S_IRUSR, C.S_IWUSR): ", C.S_IRUSR, C.S_IWUSR)
print("  -- flags, flags_file): ", flags, flags_file)
local sharedMemory = C.shm_open("shm_area1.txt", flags, flags_file)
print("  -- C.shm_open('shm_area1.txt', flags, flags_file): ", sharedMemory)

local mmapArea = C.mmap(nil, 4096, 0, 0, 0, 0)
print("  -- C.mmap(nil, 4096, 0, 0, nil, 0): ", mmapArea)

local i = C.munmap(mmapArea, 4096)
print("  -- C.munmap(sharedMemory, 4096): ", i)

local arg_c = C.shm_unlink("shm_area1.txt")
print("  -- C.shm_unlink('shm_area1.txt'): ", arg_c)

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

