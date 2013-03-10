--  ffi_def_signal.lua
dofile "ffi_def_util.lua"
local ffi = require("ffi")
local C = ffi.C

-- http://www.cis.temple.edu/~giorgio/cis307/readings/signals.html
-- You may see what are the defined signals with the shell command
--    % kill -l
-- see: /System/Library/Frameworks/Kernel.framework/Versions/A/Headers/sys/signal.h

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
  
   /* kqueue */
	#pragma pack(4)
 	struct kevent {
    uintptr_t ident;    /* identifier for this event */
    short filter;       /* filter for event */
    unsigned short flags; /* action flags for kqueue */
    unsigned int fflags;  /* filter flag value */
    intptr_t data;        /* filter data value */
    void *udata;        /* opaque user data identifier */
  };

	int kqueue(void);
  int kevent(int kq, const struct kevent* changelist, int nchanges, struct kevent* eventlist, int nevents, void* timeout);
  int kevent64(int kq, const struct kevent64_s *changelist, int nchanges, struct kevent64_s *eventlist, int nevents, unsigned int flags, const struct timespec *timeout);
  
]])

-- http://www.cis.temple.edu/~giorgio/cis307/readings/signals.html
-- You may see what are the defined signals with the shell command
--    % kill -l
-- see: /System/Library/Frameworks/Kernel.framework/Versions/A/Headers/sys/signal.h


-- Flags for sigprocmask:
SIG_BLOCK = 1	-- /* block specified signal set */
SIG_UNBLOCK = 2	-- /* unblock specified signal set */
SIG_SETMASK = 3	-- /* set specified signal set */


local signal_name = {}
SIGHUP	= 1	-- /* hangup */
signal_name[1] = "SIGHUP - hangup"
SIGINT	= 2	-- /* interrupt */
signal_name[2] = "SIGINT - interrupt"
SIGQUIT	= 3	-- /* quit */
signal_name[3] = "SIGQUIT - quit"
SIGILL	= 4	-- /* illegal instruction (not reset when caught) */
signal_name[4] = "SIGILL - illegal instruction (not reset when caught)"
SIGTRAP	= 5	-- /* trace trap (not reset when caught) */
signal_name[5] = "SIGTRAP - trace trap (not reset when caught)"
SIGABRT	= 6	-- /* abort() */
signal_name[6] = "SIGABRT - abort"
--#if  (defined(_POSIX_C_SOURCE) && !defined(_DARWIN_C_SOURCE))
SIGPOLL	= 7	-- /* pollable event ([XSR] generated, not supported) */
signal_name[7] = "SIGPOLL - pollable event ([XSR] generated, not supported)"
--#else	-- /* (!_POSIX_C_SOURCE || _DARWIN_C_SOURCE) */
--SIGIOT	SIGABRT	-- /* compatibility */
--SIGEMT	7	-- /* EMT instruction */
--#endif	-- /* (!_POSIX_C_SOURCE || _DARWIN_C_SOURCE) */
SIGFPE	= 8	-- /* floating point exception */
signal_name[8] = "SIGFPE - floating point exception"
SIGKILL	= 9	-- /* kill (cannot be caught or ignored) */
signal_name[9] = "SIGKILL - kill (cannot be caught or ignored)"
SIGBUS	= 10	-- /* bus error */
signal_name[10] = "SIGBUS - bus error"
SIGSEGV	= 11	-- /* segmentation violation */
signal_name[11] = "SIGSEGV - segmentation violation"
SIGSYS	= 12	-- /* bad argument to system call */
signal_name[12] = "SIGSYS - bad argument to system call"
SIGPIPE	= 13	-- /* write on a pipe with no one to read it */
signal_name[13] = "SIGPIPE - write on a pipe with no one to read it"
SIGALRM	= 14	-- /* alarm clock */
signal_name[14] = "SIGALRM - alarm clock"
SIGTERM	= 15	-- /* software termination signal from kill */
signal_name[15] = "SIGTERM - software termination signal from kill"
SIGURG	= 16	-- /* urgent condition on IO channel */
signal_name[16] = "SIGURG - urgent condition on IO channel"
SIGSTOP	= 17	-- /* sendable stop signal not from tty */
signal_name[17] = "SIGSTOP - sendable stop signal not from tty"
SIGTSTP	= 18	-- /* stop signal from tty */
signal_name[18] = "SIGTSTP - stop signal from tty"
SIGCONT	= 19	-- /* continue a stopped process */
signal_name[19] = "SIGCONT - continue a stopped process"
SIGCHLD	= 20	-- /* to parent on child stop or exit */
signal_name[20] = "SIGCHLD - to parent on child stop or exit"
SIGTTIN	= 21	-- /* to readers pgrp upon background tty read */
signal_name[21] = "SIGTTIN - to readers pgrp upon background tty read"
SIGTTOU	= 22	-- /* like TTIN for output if (tp->t_local&LTOSTOP) */
signal_name[22] = "SIGTTOU - like TTIN for output if (tp->t_local&LTOSTOP)"
--#if  (!defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE))
SIGIO	= 23	-- /* input/output possible signal */
signal_name[23] = "SIGIO - ut/output possible signal"
--#endif
SIGXCPU	= 24	-- /* exceeded CPU time limit */
signal_name[24] = "SIGXCPU - exceeded CPU time limit"
SIGXFSZ	= 25	-- /* exceeded file size limit */
signal_name[25] = "SIGXFSZ - exceeded file size limit"
SIGVTALRM = 26	-- /* virtual time alarm */
signal_name[26] = "SIGVTALRM - virtual time alarm"
SIGPROF	= 27	-- /* profiling time alarm */
signal_name[27] = "SIGPROF - profiling time alarm"
--#if  (!defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE))
SIGWINCH = 28	-- /* window size changes */
signal_name[28] = "SIGWINCH - window size changes"
SIGINFO	= 29	-- /* information request */
signal_name[29] = "SIGINFO - information request"
--#endif
SIGUSR1 = 30	-- /* user defined signal 1 */
signal_name[30] = "SIGUSR1 - user defined signal 1"
SIGUSR2 = 31	-- /* user defined signal 2 */
signal_name[31] = "SIGUSR2 - user defined signal 2"


function processId()
	return C.getpid()
end

function signalName(i)
	if i == 0 then return #signal_name end
	return signal_name[i]
end

function signalHandlerSet(signalToWait)
	-- https://github.com/chatid/fend/blob/master/signalfd.lua
	-- usually signalToWait == SIGUSR1
  sig = ffi.new("int[1]")
  set = ffi.new("sigset_t[1]")
  if C.sigemptyset(set) 				== -1 then cerr() end
  if signalToWait == 0 then 
  	-- wait for all signals
  	for sig=1,31 do
  		if C.sigaddset(set, sig) == -1 then cerr() end
  	end
  else
  	if C.sigaddset(set, signalToWait) == -1 then cerr() end
  end
  
  local ret = C.pthread_sigmask(SIG_BLOCK, set, nul)
	print("pthread_sigmask: "..ret)
	return sig,set
end

function signalWait(set, sig)
	if C.sigwait(set, sig) == -1 then cerr() end
end

function signalSend(prsToSignal, signal)
	C.kill(prsToSignal, signal)
end
