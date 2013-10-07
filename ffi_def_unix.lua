-- ffi_def_unix.lua
module(..., package.seeall)

local ffi = require "ffi"

local isMac = (ffi.os == "OSX")
local isLinux = (ffi.os == "Linux")
INVALID_SOCKET = -1

-- Lua state - creating a new Lua state to a new thread
ffi.cdef[[
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
	// OSX basic data types
	typedef int64_t	off_t;
	typedef uint16_t mode_t;
	typedef uint32_t useconds_t;
	typedef long time_t;
	typedef int32_t	suseconds_t;
	typedef unsigned long	__darwin_size_t;

	typedef int32_t	pid_t;  /* pid_t is int32_t at least in OSX */
	typedef uint32_t sigset_t; /* in OSX */
	typedef	int32_t		key_t;
	typedef uint32_t uid_t;
	typedef uint32_t gid_t;
	typedef unsigned short	shmatt_t;
]]

-- util
if isLinux then
  ffi.cdef[[
    static const int _SC_NPROCESSORS_CONF = 83; // for sysconf()
    static const int _SC_NPROCESSORS_ONLN = 84;
  ]]
elseif isMac then
  ffi.cdef[[
    static const int _SC_NPROCESSORS_CONF = 57; // for sysconf()
    static const int _SC_NPROCESSORS_ONLN = 58;
  ]]
end
ffi.cdef[[
		// http://www.opensource.apple.com/source/xnu/xnu-1456.1.26/bsd/i386/_types.h
	struct 	timeval {
             time_t       tv_sec;   /* seconds since Jan. 1, 1970 */
             suseconds_t  tv_usec;  /* and microseconds */
     				};
	struct 	timespec { int tv_sec; long tv_nsec; };
	int 		gettimeofday(struct timeval *restrict tp, void *restrict tzp);
	int 		nanosleep(const struct timespec *req, struct timespec *rem);
	int 		usleep(useconds_t useconds); // mac sleep
	int 		sched_yield(void); // mac yield
	long		sysconf(int name);
]]

-- shared_mem
if isMac then
	ffi.cdef[[

		static const int O_CREAT 	= 0x0200;		/* create if nonexistant */
		static const int O_TRUNC	= 0x0400;		/* truncate to zero length */
		static const int O_EXCL		= 0x0800;		/* error if already exists */
		struct ipc_perm { // osx
			uid_t		uid;		/* [XSI] Owner's user ID */
			gid_t		gid;		/* [XSI] Owner's group ID */
			uid_t		cuid;		/* [XSI] Creator's user ID */
			gid_t		cgid;		/* [XSI] Creator's group ID */
			mode_t		mode;		/* [XSI] Read/write permission */
			unsigned short	_seq;		/* Reserved for internal use */
			key_t		_key;		/* Reserved for internal use */
		};

		struct shmid_ds {
			struct ipc_perm shm_perm;	/* [XSI] Operation permission value */
			size_t		shm_segsz;	/* [XSI] Size of segment in bytes */
			pid_t		shm_lpid;	/* [XSI] PID of last shared memory op */
			pid_t		shm_cpid;	/* [XSI] PID of creator */
			shmatt_t	shm_nattch;	/* [XSI] Number of current attaches */
			time_t		shm_atime;	/* [XSI] Time of last shmat() */
			time_t		shm_dtime;	/* [XSI] Time of last shmdt() */
			time_t		shm_ctime;	/* [XSI] Time of last shmctl() change */
			void		*shm_internal;	/* reserved for kernel use */
		};
	]]
elseif isLinux then
	ffi.cdef[[
		typedef int __pid_t;
		typedef long __time_t;

		/* octal (8-base) values in Linux header file in fcntl.h
		dec:
		O_CREAT, O_EXCL: 64, 128
		S_IRUSR, S_IWUSR: 256, 128
		flags, flags_file: 192, 384
		OCTAL """
		static const int S_IRUSR	= 0400;	// Read by owner.
		static const int S_IWUSR	= 0200;	// Write by owner.
		static const int S_IXUSR	= 0100;	// Execute by owner.

		static const int O_CREAT	= 0100;
		static const int O_EXCL		= 0200;
		static const int O_TRUNC	= 01000;
		*/

		static const int O_CREAT	= 64;
		static const int O_EXCL		= 128;
		static const int O_TRUNC	= 512;

		struct ipc_perm { // Linux
			key_t          __key;    /* Key supplied to shmget(2) */
			uid_t          uid;      /* Effective UID of owner */
			gid_t          gid;      /* Effective GID of owner */
			uid_t          cuid;     /* Effective UID of creator */
			gid_t          cgid;     /* Effective GID of creator */
			unsigned short mode;     /* Permissions + SHM_DEST and
																	SHM_LOCKED flags */
			unsigned short __seq;    /* Sequence number */
		};

		// Data structure describing a shared memory segment.
		struct shmid_ds
		{
			struct ipc_perm shm_perm;		/* operation permission struct */
			size_t shm_segsz;			/* size of segment in bytes */
			__time_t shm_atime;			/* time of last shmat() */
			unsigned long int __unused1;
			__time_t shm_dtime;			/* time of last shmdt() */
			unsigned long int __unused2;
			__time_t shm_ctime;			/* time of last change by shmctl() */
			unsigned long int __unused3;
			__pid_t shm_cpid;			/* pid of creator */
			__pid_t shm_lpid;			/* pid of last shmop */
			shmatt_t shm_nattch;		/* number of current attaches */
			unsigned long int __unused4;
			unsigned long int __unused5;
		};
	]]
end
ffi.cdef[[
	// static const int MAP_FAILED	= ((void *)-1);	// [MF|SHM] mmap failed

	// Protections are chosen from these bits, or-ed together
	static const int PROT_NONE		= 0x00;	// [MC2] no permissions
	static const int PROT_READ		= 0x01;	// [MC2] pages can be read
	static const int PROT_WRITE		= 0x02;	// [MC2] pages can be written
	static const int PROT_EXEC		= 0x04;	// [MC2] pages can be executed

	// Flags contain sharing type and options.
	// Sharing types; choose one.
	static const int MAP_SHARED		= 0x0001;		// [MF|SHM] share changes
	static const int MAP_PRIVATE	= 0x0002;		// [MF|SHM] changes are private
	static const int MAP_ANON	= 0x1000;	/* allocated from memory, swap space */

	static const int IPC_SET	=	1;		/* Set `ipc_perm' options.  */
	int shmctl(int shmid, int cmd, struct shmid_ds *buf);

	int 		shm_open(const char *name, int oflag, mode_t mode);
	int 		shm_unlink(const char *name);
	int 		ftruncate(int fildes, off_t length);
	void* 	mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset);
	int 		close(int fildes);
	int 		munmap(void *addr, size_t len);
	int 		shm_unlink(const char *name);
  int 		mlock(void*, size_t);
  int 		munlock(void*, size_t);
	int 		mlockall(int);
  int 		munlockall();
  int 		mprotect(void*, size_t, int);

]]

--  thread.lua

if isLinux then
  if ffi.arch == "x64" then
		ffi.cdef[[
				static const int __SIZEOF_PTHREAD_ATTR_T = 56;
		]]
  else
		ffi.cdef[[
				static const int __SIZEOF_PTHREAD_ATTR_T = 36;
		]]
  end
	ffi.cdef[[
	typedef uint64_t pthread_t;

	typedef union {
		int8_t __size[__SIZEOF_PTHREAD_ATTR_T];
		int64_t __align;
	} pthread_attr_t;
	]]
elseif isMac then
	ffi.cdef[[
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
	]]
end


--  thread.lua
ffi.cdef[[
	int pthread_create(
		pthread_t *thread,
		const pthread_attr_t *attr,
		void *(*start_routine)(void *),
		void *arg
	);
	int pthread_join(
		pthread_t thread,
		void **value_ptr
	);
	int       pthread_detach(pthread_t );
	int       pthread_equal(pthread_t , pthread_t );
	void      pthread_exit(void *);
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

		void mutex_lock();
		bool mutex_try_lock();
		void mutex_unlock();
	*/

]]

-- file (kqueue)
ffi.cdef[[
	/* open-only flags */
	static const int O_RDONLY		= 0x0000;		/* open for reading only */
	static const int O_WRONLY		= 0x0001;		/* open for writing only */
	static const int O_RDWR			= 0x0002;		/* open for reading and writing */
	static const int O_ACCMODE	= 0x0003;		/* mask for above modes */

  int open(const char *, int, ...);
]]

-- kqueue
ffi.cdef[[

	static const int EVFILT_READ		= (-1);
	static const int EVFILT_WRITE		= (-2);
	static const int EVFILT_AIO			= (-3);	/* attached to aio requests */
	static const int EVFILT_VNODE		= (-4);	/* attached to vnodes */
	static const int EVFILT_PROC		= (-5);	/* attached to struct proc */
	static const int EVFILT_SIGNAL	= (-6);	/* attached to struct proc */
	static const int EVFILT_TIMER		= (-7);	/* timers */
	static const int EVFILT_MACHPORT = (-8);	/* Mach portsets */
	static const int EVFILT_FS			= (-9);	/* Filesystem events */
	static const int EVFILT_USER  	= (-10);   /* User events */
					/* (-11) unused */
	static const int EVFILT_VM			= (-12);	/* Virtual memory events */

/* actions */
	static const int EV_ADD 		= 0x0001;		/* add event to kq (implies enable) */
	static const int EV_DELETE	= 0x0002;		/* delete event from kq */
	static const int EV_ENABLE	= 0x0004;		/* enable event */
	static const int EV_DISABLE	= 0x0008;		/* disable event (not reported) */
	static const int EV_RECEIPT	= 0x0040;		/* force EV_ERROR on success, data == 0 */

/* flags */
	static const int EV_ONESHOT	 	= 0x0010;		/* only report one occurrence */
	static const int EV_CLEAR	 		= 0x0020;		/* clear event state after reporting */
	static const int EV_DISPATCH 	= 0x0080;          /* disable event after reporting */

	static const int EV_SYSFLAGS	= 0xF000;		/* reserved by system */
	static const int EV_FLAG0	 		= 0x1000;		/* filter-specific flag */
	static const int EV_FLAG1	 		= 0x2000;		/* filter-specific flag */

/* returned values */
	static const int EV_EOF			= 0x8000;		/* EOF detected */
	static const int EV_ERROR	 	= 0x4000;		/* error, data contains errno */

/*
 * data/hint fflags for EVFILT_VNODE, shared with userspace
 */
	static const int NOTE_DELETE	= 0x00000001;		/* vnode was removed */
	static const int NOTE_WRITE		= 0x00000002;		/* data contents changed */
	static const int NOTE_EXTEND	= 0x00000004;		/* size increased */
	static const int NOTE_ATTRIB	= 0x00000008;		/* attributes changed */
	static const int NOTE_LINK		= 0x00000010;		/* link count changed */
	static const int NOTE_RENAME	= 0x00000020;		/* vnode was renamed */
	static const int NOTE_REVOKE	= 0x00000040;		/* vnode access was revoked */
	static const int NOTE_NONE		= 0x00000080;		/* No specific vnode event: to test for EVFILT_READ activation*/


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

	*/
]]

-- ffi_def_signal.lua
ffi.cdef[[
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

]]


-- poll
ffi.cdef[[

	// OSX:
	/*
	 * Requestable events.  If poll(2) finds any of these set, they are
	 * copied to revents on return.
	 */
	static const int POLLIN		= 0x0001;		/* any readable data available */
	static const int POLLPRI		= 0x0002;		/* OOB/Urgent readable data */
	static const int POLLOUT		= 0x0004;		/* file descriptor is writeable */
	static const int POLLRDNORM	= 0x0040;		/* non-OOB/URG data available */
	static const int POLLWRNORM	= POLLOUT;		/* no write type differentiation */
	static const int POLLRDBAND	= 0x0080;		/* OOB/Urgent readable data */
	static const int POLLWRBAND	= 0x0100;		/* OOB/Urgent data can be written */

	/*
	 * FreeBSD extensions: polling on a regular file might return one
	 * of these events (currently only supported on local filesystems).
	 */
	static const int POLLEXTEND	= 0x0200;		/* file may have been extended */
	static const int POLLATTRIB	= 0x0400;		/* file attributes may have changed */
	static const int POLLNLINK	= 0x0800;		/* (un)link/rename may have happened */
	static const int POLLWRITE	= 0x1000;		/* file's contents may have changed */

	/*
	 * These events are set if they occur regardless of whether they were
	 * requested.
	 */
	static const int POLLERR		= 0x0008;		/* some poll error occurred */
	static const int POLLHUP		= 0x0010;		/* file descriptor was "hung up" */
	static const int POLLNVAL	= 0x0020;		/* requested events "invalid" */

	//static const int POLLSTANDARD	= (POLLIN|POLLPRI|POLLOUT|POLLRDNORM|POLLRDBAND|POLLWRBAND|POLLERR|POLLHUP|POLLNVAL);

	struct pollfd {
		 int    fd;       /* file descriptor */
		 short  events;   /* events to look for */
		 short  revents;  /* events returned */
	};

	int poll(struct pollfd *fds, unsigned long nfds, int timeout); // mac sleep + poll

	// fcntl definitions
	static const int O_NONBLOCK	= 0x0004;		/* no delay */
	/* command values */
	static const int F_DUPFD		= 0;		/* duplicate file descriptor */
	static const int F_GETFD		= 1;		/* get file descriptor flags */
	static const int F_SETFD		= 2;		/* set file descriptor flags */
	static const int F_GETFL		= 3;		/* get file status flags */
	static const int F_SETFL		= 4;		/* set file status flags */
	int fcntl(int fildes, int cmd, ...);
]]

-- socket
-- https://gist.github.com/cyberroadie/3490843
ffi.cdef[[
	// Definitions of bits in internet address integers.
	// On subnets, the decomposition of addresses to host and net parts
	// is done according to subnet mask, not the masks here.
	static const int	 INADDR_ANY				= 0x00000000;
	static const int	 INADDR_BROADCAST	= 0xffffffff;	/* must be masked */


	// Types
	static const int  SOCK_STREAM = 1	;	/* stream socket */
	static const int  SOCK_DGRAM	= 2;		/* datagram socket */
	static const int  SOCK_RAW	= 3;		/* raw-protocol interface */
	static const int  SOCK_RDM	= 4;		/* reliably-delivered message */
	static const int  SOCK_SEQPACKET	= 5;		/* sequenced packet stream */


	static const int  	TCP_NODELAY             = 0x01;    /* don't delay send to coalesce packets */
	static const int  	TCP_MAXSEG              = 0x02;    /* set maximum segment size */
	static const int   TCP_NOPUSH              = 0x04;    /* don't push last block of write */
	static const int   TCP_NOOPT               = 0x08;    /* don't use TCP options */
	static const int   TCP_KEEPALIVE           = 0x10;    /* idle time used when SO_KEEPALIVE is enabled */
	static const int   TCP_CONNECTIONTIMEOUT   = 0x20;    /* connection timeout */
	static const int   PERSIST_TIMEOUT					= 0x40;	/* time after which a connection in
					 *  persist timeout will terminate.
					 *  see draft-ananth-tcpm-persist-02.txt
					 */
	static const int   TCP_RXT_CONNDROPTIME	= 0x80;	/* time after which tcp retransmissions will be
					 * stopped and the connection will be dropped
					 */
	static const int   TCP_RXT_FINDROP	= 0x100;	/* when this option is set, drop a connection
					 * after retransmitting the FIN 3 times. It will
					 * prevent holding too many mbufs in socket
					 * buffer queues.
					 */

	// Additional options, not kept in so_options.
	static const int  SO_SNDBUF	= 0x1001;		/* send buffer size */
	static const int  SO_RCVBUF	= 0x1002;		/* receive buffer size */
	static const int  SO_SNDLOWAT	= 0x1003;		/* send low-water mark */
	static const int  SO_RCVLOWAT	= 0x1004;		/* receive low-water mark */
	static const int  SO_SNDTIMEO	= 0x1005;		/* send timeout */
	static const int  SO_RCVTIMEO	= 0x1006;		/* receive timeout */
	static const int  SO_ERROR	= 0x1007;		/* get error status and clear */
	static const int  SO_TYPE		= 0x1008;		/* get socket type_ */
	// #if !defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE)
	static const int  SO_PRIVSTATE	= 0x1009;		   /* get/deny privileged state */
	static const int  SO_LABEL        = 0x1010;          /* socket's MAC label */
	static const int  SO_PEERLABEL    = 0x1011;          /* socket's peer MAC label */
	// #ifdef __APPLE__
	static const int  SO_NREAD	= 0x1020;		/* APPLE: get 1st-packet byte count */
	static const int  SO_NKE		= 0x1021;		/* APPLE: Install socket-level NKE */
	static const int  SO_NOSIGPIPE	= 0x1022;		/* APPLE: No SIGPIPE on EPIPE */
	static const int  SO_NOADDRERR	= 0x1023;		/* APPLE: Returns EADDRNOTAVAIL when src is not available anymore */
	static const int  SO_NWRITE	= 0x1024;		/* APPLE: Get number of bytes currently in send socket buffer */
	static const int  SO_REUSESHAREUID	= 0x1025;		/* APPLE: Allow reuse of port/socket by different userids */
	// #ifdef __APPLE_API_PRIVATE
	static const int  SO_NOTIFYCONFLICT	= 0x1026;	/* APPLE: send notification if there is a bind on a port which is already in use */
	static const int  SO_UPCALLCLOSEWAIT	= 0x1027;	/* APPLE: block on close until an upcall returns */
	// #endif
	static const int  SO_LINGER_SEC	= 0x1080;          /* linger on close if data present (in seconds) */
	static const int  SO_RESTRICTIONS	= 0x1081;	/* APPLE: deny inbound/outbound/both/flag set */
	static const int  SO_RESTRICT_DENYIN		= 0x00000001;	/* flag for SO_RESTRICTIONS - deny inbound */
	static const int  SO_RESTRICT_DENYOUT		= 0x00000002;	/* flag for SO_RESTRICTIONS - deny outbound */
	static const int  SO_RESTRICT_DENYSET		= 0x80000000;	/* flag for SO_RESTRICTIONS - deny has been set */
	static const int  SO_RANDOMPORT   = 0x1082;  /* APPLE: request local port randomization */
	static const int  SO_NP_EXTENSIONS	= 0x1083;	/* To turn off some POSIX behavior */
	// #endif

	// Address families.
	static const int  AF_UNSPEC 	= 0;		/* unspecified == give any listening address */
	static const int  AF_UNIX 		= 1;		/* local to host (pipes) */
	static const int  AF_INET 		= 2;		/* internetwork: UDP, TCP, etc. */

	// Protocols (RFC 1700)
	static const int  IPPROTO_TCP = 6;		/* tcp */
	static const int  IPPROTO_UDP = 17;		/* user datagram protocol */

	static const int 	SOMAXCONN = 128;	// Maximum queue length specifiable by listen.
	static const int AI_PASSIVE = 0x00000001; /* get address to use bind() */

	typedef long				ssize_t;	/* byte count or error */
	typedef uint32_t			socklen_t;
	typedef	uint8_t			sa_family_t;
	typedef	uint16_t		in_port_t;
	typedef	uint32_t		in_addr_t;	/* base type for internet address */
]]
if isLinux then
	ffi.cdef[[

		static const int SOL_SOCKET = 1;

		static const int  SO_REUSEADDR	= 1;		/* allow local address reuse */
		static const int  SO_KEEPALIVE	= 9;		/* keep connections alive */
		static const int  SO_DONTROUTE	= 5;		/* just use interface addresses */

		/* Structure describing a generic socket address.  */
		struct sockaddr {
			sa_family_t	sa_family;		/* Common data: address family and length.  */
			char		sa_data[14];	/* Address data.  */
		};
		struct addrinfo {
			int ai_flags;           /* input flags. AI_PASSIVE, AI_CANONNAME, AI_NUMERICHOST */
			int ai_family;          /* protocol family for socket. PF_xxx */
			int ai_socktype;        /* socket type. SOCK_xxx */
			int ai_protocol;        /* protocol for socket, 0 or IPPROTO_xxx for IPv4 and IPv6 */
			socklen_t ai_addrlen;   /* length of socket-address, length of ai_addr */
			struct sockaddr *ai_addr; /* socket-address for socket, binary address */
			char *ai_canonname;     /* canonical name for service location, canonical name for hostname */
			struct addrinfo *ai_next; /* pointer to next in list, next structure in linked list */
		 };
	]]
elseif isMac then -- "*ai_canonname" and "*ai_addr" are in different order than in Linux
	ffi.cdef[[

		static const int SOL_SOCKET = 0xffff;


		// Option flags per-socket.
		static const int  SO_DEBUG	= 0x0001;		/* turn on debugging info recording */
		static const int  SO_ACCEPTCONN	= 0x0002;		/* socket has had listen() */
		static const int  SO_REUSEADDR	= 0x0004;		/* allow local address reuse */
		static const int  SO_KEEPALIVE	= 0x0008;		/* keep connections alive */
		static const int  SO_DONTROUTE	= 0x0010;		/* just use interface addresses */
		static const int  SO_BROADCAST	= 0x0020;		/* permit sending of broadcast msgs */
		// #if !defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE)
		static const int  SO_USELOOPBACK	= 0x0040;		/* bypass hardware when possible */
		static const int  SO_LINGER	= 0x0080;          /* linger on close if data present (in ticks) */
		// #else
		// static const int  SO_LINGER	= 0x1080;          /* linger on close if data present (in seconds) */
		// #endif	/* (!_POSIX_C_SOURCE || _DARWIN_C_SOURCE) */
		static const int  SO_OOBINLINE	= 0x0100;		/* leave received OOB data in line */
		// #if !defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE)
		static const int  SO_REUSEPORT	= 0x0200;		/* allow local address & port reuse */
		static const int  SO_TIMESTAMP	= 0x0400;		/* timestamp received dgram traffic */
		static const int  SO_TIMESTAMP_MONOTONIC	= 0x0800;	/* Monotonically increasing timestamp on rcvd dgram */
		// #ifndef __APPLE__
		// static const int  SO_ACCEPTFILTER	= 0x1000;		/* there is an accept filter */
		// #else
		static const int  SO_DONTTRUNC	= 0x2000;		/* APPLE: Retain unread data */
						/*  (ATOMIC proto) */
		static const int  SO_WANTMORE	= 0x4000;		/* APPLE: Give hint when more data ready */
		static const int  SO_WANTOOBFLAG	= 0x8000;		/* APPLE: Want OOB in MSG_FLAG on receive */
		// #endif  /* (!__APPLE__) */
		// #endif	/* (!_POSIX_C_SOURCE || _DARWIN_C_SOURCE) */

		/* Structure describing a generic socket address.  */
		struct sockaddr {
			uint8_t	sa_len;		/* total length */
			sa_family_t	sa_family;	/* [XSI] address family */
			char		sa_data[14];	/* [XSI] addr value (actually larger) */
		};
		struct addrinfo {
			int ai_flags;           /* input flags. AI_PASSIVE, AI_CANONNAME, AI_NUMERICHOST */
			int ai_family;          /* protocol family for socket. PF_xxx */
			int ai_socktype;        /* socket type. SOCK_xxx */
			int ai_protocol;        /* protocol for socket, 0 or IPPROTO_xxx for IPv4 and IPv6 */
			socklen_t ai_addrlen;   /* length of socket-address, length of ai_addr */
			char *ai_canonname;     /* canonical name for service location, canonical name for hostname */
			struct sockaddr *ai_addr; /* socket-address for socket, binary address */
			struct addrinfo *ai_next; /* pointer to next in list, next structure in linked list */
		 };
	]]
end
ffi.cdef[[

	static const int SD_RECEIVE = 0; // Shutdown receive operations.
	static const int SD_SEND 		= 1; // Shutdown send operations.
	static const int SD_BOTH 		= 2; // Shutdown both send and receive operations.

	static const int INET6_ADDRSTRLEN	= 46;
	static const int INET_ADDRSTRLEN	= 16;

	// Socket address conversions
	static const int NI_MAXHOST = 1025;
	static const int NI_MAXSERV = 32;

	struct in_addr {
		in_addr_t s_addr;
	};

	// Socket address, internet style.
	struct sockaddr_in {
		uint8_t	sin_len;
		sa_family_t	sin_family;
		in_port_t	sin_port;
		struct	in_addr sin_addr;
		char		sin_zero[8];
	};

	static const int _SS_MAXSIZE		= 128;
	static const int _SS_ALIGNSIZE 	= (sizeof(int64_t));
	static const int _SS_PAD1SIZE		= (_SS_ALIGNSIZE - sizeof(uint8_t) - sizeof(sa_family_t));
	static const int _SS_PAD2SIZE		= (_SS_MAXSIZE - sizeof(uint8_t) - sizeof(sa_family_t) - _SS_PAD1SIZE - _SS_ALIGNSIZE);

	struct sockaddr_storage {
		uint8_t	ss_len;		/* address length */
		sa_family_t	ss_family;	/* [XSI] address family */
		char			__ss_pad1[_SS_PAD1SIZE];
		int64_t	__ss_align;	/* force structure storage alignment */
		char			__ss_pad2[_SS_PAD2SIZE];
	};

	int 	getaddrinfo(const char *hostname, const char *servname, const struct addrinfo *hints, struct addrinfo **res);
	void 	freeaddrinfo(struct addrinfo *ai);
	int 	getnameinfo(const struct sockaddr *sa, socklen_t salen, char *host, socklen_t hostlen, char *serv, socklen_t servlen, int flags);

	const char* gai_strerror(int ecode);
	uint16_t htons(uint16_t hostshort);
	// Socket address conversions END

	ssize_t read(int fildes, void *buf, size_t nbyte);

	int accept(int socket, struct sockaddr *restrict address, socklen_t *restrict address_len);
	// int select(int nfds, fd_set *restrict readfds, fd_set *restrict writefds, fd_set *restrict errorfds, struct timeval *restrict timeout);
	int bind(int socket, const struct sockaddr *address, socklen_t address_len);
	int connect(int socket, const struct sockaddr *address, socklen_t address_len);
	int getpeername(int, struct sockaddr * __restrict, socklen_t * __restrict);
	int getsockname(int socket, struct sockaddr *restrict address, socklen_t *restrict address_len);
	int getsockopt(int socket, int level, int option_name, void *restrict option_value, socklen_t *restrict option_len);
	int listen(int socket, int backlog);
	ssize_t	recv(int socket, void *buffer, size_t length, int flags);
	ssize_t	recvfrom(int socket, void *restrict buffer, size_t length, int flags, struct sockaddr *restrict address, socklen_t *restrict address_len);
	ssize_t	recvmsg(int socket, struct msghdr *message, int flags);
	ssize_t	send(int socket, const void *buffer, size_t length, int flags);
	ssize_t sendmsg(int socket, const struct msghdr *message, int flags);
	ssize_t	sendto(int socket, const void *buffer, size_t length, int flags, const struct sockaddr *dest_addr, socklen_t dest_len);
	int setsockopt(int socket, int level, int option_name, const void *option_value, socklen_t option_len);
	int shutdown(int socket, int how);
	int sockatmark(int);
	int socket(int domain, int type, int protocol);
	int socketpair(int, int, int, int *);
	int sendfile(int, int, off_t, off_t *, struct sf_hdtr *, int);
	void	pfctlinput(int, struct sockaddr *);
	int setsockopt(int socket, int level, int option_name, const void *option_value, socklen_t option_len);
	int getsockopt(int socket, int level, int option_name, void *restrict option_value, socklen_t *restrict option_len);


	in_addr_t	 inet_addr(const char *);
	char		*inet_ntoa(struct in_addr);
	const char	*inet_ntop(int, const void *, char *, socklen_t);
	int 	 inet_pton(int, const char *, void *);
	int 	 ascii2addr(int, const char *, void *);
	char		*addr2ascii(int, const void *, int, char *);
	int 	 inet_aton(const char *, struct in_addr *);
	in_addr_t	 inet_lnaof(struct in_addr);
	struct in_addr	 inet_makeaddr(in_addr_t, in_addr_t);
	in_addr_t	 inet_netof(struct in_addr);
	in_addr_t	 inet_network(const char *);
	char		*inet_net_ntop(int, const void *, int, char *, __darwin_size_t);
	int 	 inet_net_pton(int, const char *, void *, __darwin_size_t);
	char	 	*inet_neta(in_addr_t, char *, __darwin_size_t);
	unsigned int  inet_nsap_addr(const char *, unsigned char *, int maxlen);
	char	*inet_nsap_ntoa(int, const unsigned char *, char *ascii);

	uint32_t htonl(uint32_t hostlong);
	uint16_t htons(uint16_t hostshort);
	uint32_t ntohl(uint32_t netlong);
	uint16_t ntohs(uint16_t netshort);
]]
