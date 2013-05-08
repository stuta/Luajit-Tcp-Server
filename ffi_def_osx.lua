-- ffi_def_osx.lua
module(..., package.seeall)

local ffi = require "ffi"
-- generated code start --

--[[ lib_date_time.lua ]]
ffi.cdef[[
	typedef long __darwin_time_t;
	typedef __darwin_time_t time_t;

	double difftime(time_t, time_t);
	time_t time(time_t *);
]]

--[[ lib_kqueue.lua ]]
--[[ lib_poll.lua ]]
ffi.cdef[[
	void free(void *);
	void *realloc(void *, size_t);
]]

--[[ lib_shared_memory.lua ]]
--[[ lib_signal.lua ]]
ffi.cdef[[
	typedef unsigned int __uint32_t;
	typedef __uint32_t __darwin_sigset_t;
	typedef __darwin_sigset_t sigset_t;

	int pthread_sigmask(int, const sigset_t *, sigset_t *);
]]

--[[ lib_socket.lua ]]
--[[ lib_tcp.lua ]]
--[[ lib_thread.lua ]]
ffi.cdef[[
	struct _opaque_pthread_t { long __sig; struct __darwin_pthread_handler_rec *__cleanup_stack; char __opaque[1168]; }
	struct __darwin_pthread_handler_rec{ void (*__routine)(void *); void *__arg; struct __darwin_pthread_handler_rec *__next;}
	struct _opaque_pthread_attr_t { long __sig; char __opaque[56]; }
	typedef struct _opaque_pthread_t *__darwin_pthread_t;
	typedef struct _opaque_pthread_attr_t __darwin_pthread_attr_t;
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
	typedef int __int32_t;
	typedef __int32_t __darwin_suseconds_t;
	struct timeval{ __darwin_time_t tv_sec; __darwin_suseconds_t tv_usec;}
	struct timespec{ __darwin_time_t tv_sec; long tv_nsec;}

	int gettimeofday(struct timeval * , void * );
	int nanosleep(const struct timespec *, struct timespec *);
]]
