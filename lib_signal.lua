--  lib_signal.lua
module(..., package.seeall)

local ffi = require("ffi")
local C = ffi.C

-- http://www.cis.temple.edu/~giorgio/cis307/readings/signals.html
-- You may see what are the defined signals with the shell command
--    % kill -l
-- see: /System/Library/Frameworks/Kernel.framework/Versions/A/Headers/sys/signal.h


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

  local ret = C.pthread_sigmask(SIG_BLOCK, set, nil)
	print("pthread_sigmask: "..ret)
	return sig,set
end

function signalWait(set, sig)
	if C.sigwait(set, sig) == -1 then cerr() end
end

function signalSend(prsToSignal, signal)
	C.kill(prsToSignal, signal)
end
