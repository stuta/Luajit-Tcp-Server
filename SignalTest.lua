--  SignalTest.lua
print()
print(" -- SignalTest.lua start -- ")
print()

local arg = {...}
local ffi = require("ffi")
local C = ffi.C

local SIGINT = 2
local SIGUSR1 = 30
local SIGSEGV	= 11
local signalCatchCount = 0

local prsToSignal = tonumber(arg[1]) or 0
local signalSendCount = tonumber(arg[2]) or 1000

ffi.cdef([[
	int 	sched_yield(void); // mac
	bool  SwitchToThread(void); // win
]])
if ffi.os == "Windows" then
  function yield()
    C.SwitchToThread()
  end
else
  function yield()
    C.sched_yield() 
  end
end

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
]])

local pid = C.getpid()
print("pid : "..pid)

local function signalHandler()
	signalCatchCount = signalCatchCount + 1
	print("signalHandler(): "..signalCatchCount)
end

local function signalHandlerSet(signal, signalHandlerFunc)
	C.signal(signal, signalHandlerFunc)
end

local function signalSend(prsToSignal, signal)
	C.kill(prsToSignal, signal)
end

local function signalPause()
	C.pause()
end

if prsToSignal == 0 then
	print("signal repeat start")
	signalHandlerSet(SIGUSR1, signalHandler)
	local i = 0
	repeat
		i = i + 1
		print("signalHandlerSet() start: "..i)
		--print("signalPause()")
		signalPause()
	until false
	print("signal repeat after")
	C.kill(pid, SIGUSR1) -- will cause signalCatch() to run
	print("signal end")
else
	for i=1,signalSendCount do
		print("signalSend(prsToSignal, SIGUSR1) start: "..i)
		signalSend(prsToSignal, SIGUSR1)
		yield() --nanosleep(1) --	sleep(0)
	end 
	--C.kill(prsToSignal, SIGINT)
end

print()
print(" -- SignalTest.lua end -- ")
print()

