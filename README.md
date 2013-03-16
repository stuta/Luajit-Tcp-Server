Luajit-Tcp-Server
=================

Trying to create fastest possible OSX and Windows tcp server and very simple http server with nothing but Lua code. Focus is making this very easy to understad to Lua newcomer. I'm architect, database and 4D programmer, not a C or Lua programmer. This is a learning process. And these bits and bytes are too small fo by laser-operated eyes :).

Currently this just collection of test code, tested with Luajit.

WTypes.lua, WinBase.lua guiddef.lua, kernel32_ffi.lua and win_socket.lua have been copied from https://github.com/Wiladams/TINN.

All code will be OSX + Windows + Linux. Contributios are welcome.

##### Test status

Linux tests were done in great "Linux Mint 14 MATE" 32-bit, 400 mb ram is enough in VirtualBox. In Linux install file lj.sh, read instructions from the file. Mac needs symlink too. Mac tests have been done in OSX 10.8. Windows tests have been done in XP and Win7.

__Works__:

  * TestAddrinfo: linux (partially)
  * TestKqueue: osx
  * TestLinux: osx + linux
  * TestSharedMem: osx + win + linux 
  * no need: [[ TestSignal: osx + linux ("Bad system call"" with many signals) ]]
  * TestSocket: osx + win + linux
  * TestThread: osx + (win soon) + linux 
  	* return values has been disabled
  * TestUtil: osx + win + linux

__Current issues__:

  * AddrinfoTest.lua
  	- what is correct way to call **data parameters, is it data\*[1] ?
  	- set correct parameters to addrinfo calls
  * TestSocket: osx + win + linux
  	 - in XP: lib_socket.lua:57: socket_recv failed with error: (-1), why? Win7 works.
  
##### TestAll.lua

Runs all TestXxx.lua code in directory. You can cance running test with ctrl-c and continue to next test.

##### TestAddrinfo.lua

This does no need any other files, it runs in mac+win+linux.

Test getaddrinfo and getnameinfo. This is not working very well. I uess that either there is a problem with luajit **param or wrong flags. All ideas / fixes are welcome.

##### TestKqueue.lua

Run: 'luajit KqueueTest.lua somePath'. Monitors changes to file or folder. 

By definition OSX and FreeBSD only (where kqueue exists). In Linux should be epoll and in Windows IO Competion Ports.

http://www.linuxsymposium.org/archives/OLS/Reprints-2004/LinuxSymposium2004_All.pdf#page=217

http://www.eecs.berkeley.edu/~sangjin/2012/12/21/epoll-vs-kqueue.html

##### TestLinux.lua

Linux-specific issues, things that work in osx.

##### TestSharedMem.lua

Creates shared memory area. Mac + Win + Linux. Problems with Linux where "shm_" calls are not recognized. Why?

##### TestSignal.lua

Start 2 terminals. In terminal 1 run 'luajit SignalTest.lua'. Program will print it's pid. In terminal 2 run 'luajit SignalTest.lua xxx 10000' where xxx is the pid of first program and number is how many times to signal it. Only Mac. Signals are slow and will not be used.

##### TestSocket.lua

Start test and refresh twice in browser address http://127.0.0.1:5001/.

In Linx: lib_socket.lua:76: socket_bind failed with error: (-1) Bad value for ai_flags. What flags? Are ffi.cdef different in linux than osx?

##### TestThread.lua

Creates 2 os threads and runs new Lua state in those threads. Parameters can be given and thread join will return result parameter. Mac (Win coming). Problems with Linux.

##### TestUtil.lua
  - cstr(str)
  - cerr()
  - createBuffer(datalen)
  - getOffsetPointer(cdata, offset)
  - toHexString(num)
  - processorCoreCount()
  - waitKeyPressed() 
  - yield()
  - sleep(millisec)
  - nanosleep(nanosec)
  - seconds(prev_sec)
  - milliSeconds(prev_millisec)
  - microSeconds(prev_microsec)
  - directory_files
  - comma_value(amount, comma)
  - round(val, decimal)
  - format_num(amount, decimal, comma, prefix, neg_prefix)  
  - table.show(t, name, indent)
