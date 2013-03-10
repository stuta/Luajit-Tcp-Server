-- ffi_def_mac.lua
local ffi = require "ffi" 

ffi.cdef([[
	// OSX basic data types
	typedef int64_t	off_t;
	typedef uint16_t mode_t;
	typedef uint32_t useconds_t;
	typedef long time_t;
	typedef int32_t	suseconds_t;
]])

ffi.cdef([[
		// http://www.opensource.apple.com/source/xnu/xnu-1456.1.26/bsd/i386/_types.h
	struct 	timeval {
             time_t       tv_sec;   /* seconds since Jan. 1, 1970 */
             suseconds_t  tv_usec;  /* and microseconds */
     				};
	struct 	timespec { int tv_sec; long tv_nsec; };
	
	int 		gettimeofday(struct timeval *restrict tp, void *restrict tzp);
	int 		nanosleep(const struct timespec *req, struct timespec *rem);
	int			usleep(useconds_t useconds); // mac sleep
	int 		poll(struct pollfd *fds, unsigned long nfds, int timeout); // mac sleep
	int 		sched_yield(void); // mac yield
]])

-- ffi_def_shared_mem.lua
ffi.cdef([[
	int 		shm_open(const char *name, int oflag, mode_t mode); // The parameter "mode_t mode" is optional.
	// int 		shm_open(const char *name, int oflag);
	int 		shm_unlink(const char *name);
	int 		ftruncate(int fildes, off_t length);
	void* 	mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset);
	int			close(int fildes);
	int			munmap(void *addr, size_t len);
	int			shm_unlink(const char *name);
  int 		mlock(void*, size_t);
  int 		munlock(void*, size_t);
	int 		mlockall(int);
  int 		munlockall();
  int 		mprotect(void*, size_t, int);
]])

--  ffi_def_thread.lua
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
	
]])


ffi.cdef([[
  // kqueue
	#pragma pack(4)
  struct kevent {
    uintptr_t ident;    // identifier for this event
    short filter;       // filter for event 
    unsigned short flags; // action flags for kqueue 
    unsigned int fflags;  // filter flag value 
    intptr_t data;        // filter data value 
    void *udata;        // opaque user data identifier 
  };
  
	int kqueue(void);
  int kevent(int kq, const struct kevent* changelist, int nchanges, struct kevent* eventlist, int nevents, void* timeout);
  
  
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

-- ffi_def_signal.lua
ffi.cdef([[
	typedef int32_t	pid_t;  /* pid_t is int32_t at least in OSX */
	typedef uint32_t sigset_t; /* in OSX */
	struct sigaction {
		void (*sa_handler) (int); /* address of signal handler */
		sigset_t  sa_mask;        /* signals to block in addition to the one being handled */
		int  sa_flags;
	};
     /* struct sigaction specifies special handling for a signal. 
     		For simplicity we will assume it is 0.
     		The possible values of sa_handler are:
					SIG_IGN:    ignore the signal
					SIG_DFL:    do the default action for this signal
					or the address of the signal handler
				There is also a more complex form of this structure with information
				for using alternate stacks to handle interrupts */
	
	pid_t getpid();
  int kill(pid_t process_id, int sign); 
     /* Sends the signal sign to the process process_id.
				[kill may also be used to send signals to groups of processes.] */
	int pause(void);
     /* It requests to be put to sleep until the process receives a signal.
        It always returns -1. */
  void (*signal(int sign, void(*function)(int)))(int);
     /* The signal function takes two parameters, an integer
	 			and the address of a function of one integer argument which
	 			gives no return. Signal returns the address of a function of
	 			one integer argument that returns nothing. 
        sign identifies a signal
        the second argument is either SIG_IGN (ignore the signal)
	 			or SIG_DFL (do the default action for this signal), or
	 			the address of the function that will handle the signal.
	 			It returns the previous handler to the sign signal.
        The signal function is still available in modern Unix
        systems, but only for compatibility reasons.
        It is better to use sigaction. */
	void sigaction(int signo, const struct sigaction *action, struct sigaction *old_action);	
	int sigemptyset(sigset_t * sigmask);
	int sigaddset(sigset_t * sigmask, const int signal_num);
	int sigdelset(sigset_t * sigmask, const int signal_num);
	int sigfillset(sigset_t * sigmask);
	int sigismember(const sigset_t * sigmask, const int signal_num);
	int sigprocmask(int cmd, const sigset_t* new_mask, sigset_t* old_mask);
     /* where the parameter cmd can have the values
				SIG_SETMASK:  sets the system mask to new_mask
				SIG_BLOCK:    Adds the signals in new_mask to the system mask
				SIG_UNBLOCK:  Removes the signals in new_mask from system mask
    		If old_mask is not null, it is set to the previous value of the system mask */
	unsigned int alarm(unsigned int n);
     /* It requests the delivery in n seconds of a SIGALRM signal.
        If n is 0 it cancels a requested alarm.
        It returns the number of seconds left for the previous call to
        alarm (0 if none is pending). */
  int sigsuspend(const sigset_t *sigmask);
     /* It saves the current (blocking) signal mask and sets it to
				sigmask. Then it waits for a non-blocked signal to arrive.
				At which time it restores the old signal mask, returns -1,
        and sets errno to EINTR (since the system service was
        interrupted by a signal).
				It is used in place of pause when afraid of race conditions
				in the situation where we block some signals, then we unblock
        and would like to wait for one of them to occur. */
  int sigwait(const sigset_t *restrict set, int *restrict sig);
  int pthread_sigmask(int how, const sigset_t *restrict set, sigset_t *restrict oset);
  
]])