Luajit-Tcp-Server
=================

Trying to create fastest possible OSX and Windows tcp server and very simple http server with nothing but Lua code. Focus is making this very easy to understad to Lua newcomer. I'm architect, database and 4D programmer, not a C or Lua programmer. This is a learning process ... and these bits and bytes are too small fo by laser-operated eyes :).

Currently this just collection of test code, tested with Luajit.

WTypes.lua, WinBase.lua guiddef.lua, kernel32_ffi.lua and win_socket.lua have been copied from [https://github.com/Wiladams/TINN](https://github.com/Wiladams/TINN).

All code will be OSX + Windows + Linux. Contributios are welcome.

## Performance

In OSX , 3,6 GHz Intel i5, 4 cores and hyperthreading.

  - **4,8 million** roundtrip messages / second with shared memory between 2 _applications_
  - **105 000** roundtrip messages / second with tcp between 2 applications 
  	- httperf --port=5001 --verbose --rate=1000 --num-conns=8 --num-calls=100000
    
In OSX 27" late 2009 iMac, 3,06 GHz Intel Core 2 Duo, no hyperthreading.

  - **2,5 million** roundtrip messages / second with shared memory between 2 _applications_
  - **27 000** roundtrip messages / second with tcp between 2 applications 
  	- Nginx gives 9 000 messages / second in this same machine

In modern (2012) Core i5 machine you can get double speed. **Shut down other programs in the test machine, they will affect surprisingly much to the test results.**

### AppServer.lua

Install [httperf](http://www.hpl.hp.com/research/linux/httperf/). Other performace tools (ab, siege) break connection and crete always a new socket. In OSX those results are completely unreliable and will cause sockets to end and resulst will go down very soon until you wait system to release unused socket to use (can somebody explain this better?). Httperf will not disconnect open sockets and it gives consistent results.

In one terminal window run "lj AppServer.lua". In another teminal run httperf as shown below.
 
##### Apache

  - httperf --port=80 --verbose --rate=1000 --num-conns=4 --num-calls=2000 --
  - Request rate, max: **5 083.6** req/s
  - typically **4 500**

##### Nginx

  - httperf --port=80 --verbose --rate=1000 --num-conns=4 --num-calls=2000
  - Request rate, max: **9 219.6** req/s
  - typically **8 000**

##### Luajit-Tcp-Server

Single-threaded simple version using traditional poll and WSAPoll (WSAPoll does not work in Windows XP).

  - with 2,4 GHz Intel Core 2 Duo Macboo Pro 13"
  	- wrk -t3 -d5 -c60 http://127.0.0.1:5001/
  		- Request rate typically: **33 500** req/s
  	- httperf --port=5001 --verbose --rate=1000 --num-conns=4 --num-calls=2000
  		- Request rate, max: **24 227.8** req/s
  		- typically **23 500**
  		- in longer test (20 million calls) maximum was **26 746**, typically **26 000**
  - with 4 core i5, 3.6GHz, wrk or httperf about the same result
  	- Request rate max: **105 000** req/s, typically **103 800** req/s
  	- httperf --port=5001 --verbose --rate=1000 --num-conns=8 --num-calls=20000
  	- wrk -t3 -d5 -c60 http://127.0.0.1:5001/

This version just serves static content, does not even change the date of reply headers so it is unfair to others, but the point was to get baseline where to compare after more realistic features. This is the first working version, alternative speed tests have not been done (see "Design principles").


### AppSharedMemory.lua

In one terminal window run "lj AppSharedMemory.lua s". In another teminal run "lj AppSharedMemory.lua c".

Client sends a message to server and waits for an answer. Server copies read message to send buffer. After answer client sends another message. This happens 5 million times in less than 2 seconds, that means 2.5 million roundtrip-messages in second = 200 nanoseconds for one message to go to one direction. With tcp server we get 26 000 roundtrip messages in second. 

Code is not optimized, this is first working version.

This version simply waits for an answer before sending next message. It could be optimized to use sendbuffer in client. Server should read all messages in the readbuffer and singnal client to send more messages while working with answers.

From ZeroMQ page: _"It seems that using appoximately 30 messages a batch yields the best results. Note that batching up to 8 messages is not worth of doing because the overhead associated with the batching makes it even slower than one-by-one message transfer."_

```
 ..for loop=1, 5 000 000 write+read time: 1.9428 sec
 ..sentCount: 5 000 000, readCount: 5 000 000, messageCount: 10 000 000
 ..for loop: 2 573 630 loop / sec
 ..for loop: 5 147 261 msg  / sec
 ..for loop: 194 ns / msg
 ..latency : 389 ns / msg
 ..for loop max message len: 11
 ..status read wait count  : 5 984 305
change data in every loop: FALSE
read reply (2-way communication): TRUE
```

with 4 core i5, 3.6GHz:

```
..for loop=1, 5 000 000 write+read time: 1.0375 sec
 ..sentCount: 5 000 000, readCount: 5 000 000, messageCount: 10 000 000
 ..for loop: 4 819 426 loop / sec
 ..for loop: 9 638 852 msg  / sec
 ..for loop: 104 ns / msg
 ..latency : 207 ns / msg
 ..for loop max message len: 11
 ..status read wait count  : 8 688 380
change data in every loop: FALSE
read reply (2-way communication): TRUE
```

## Design Principles

- all code is pure Luajit (and possibly Lua 5.1 + ffi library)
- no external libraries = easy to port to other platforms (Rapsberry, iOS, Android, ...)
- runs in OSX, Windows and Linux

Outside critical path write clean simple code and don't think about optimizations. 

Inside critical path do these things:

- test all, test often
- therories are nice to have, but test results tell the truth
- test many ways to do same things in critical path (ffi cdata vs Lua tables)
- avoid memory allocation
	- allocate memory beforehand and grow in bigger chunks
- do not pass arguments if you don't have to
	- use set_xx -functions before critical path
- do things only when they are really needed
	- for ex. do not parse all http headers, only those that are needed
	- headers can be parsed directly from inbuffer using ffi.C -calls
- cache things that are really needed, nothing else
- no bookkeeping data unless really needed
	- for ex. socket poll cdata is it's own bookeeping data
- avoid memory copy, but small memory copy is fast (see [ZeroMQ page](http://www.zeromq.org/results:copying))
- no more threads than cores in machine
- less lines is usually faster code

---

### Test Status

Linux tests were done in great "Linux Mint 14 MATE" 32-bit, with 512 mb ram in VirtualBox. In Linux install file lj.sh, read instructions from the file. Also Mac needs "lj"-symlink. Windows binaries are included in repo. Mac tests have been done in OSX 10.8. Windows tests have been done in XP and Win7.

__Works__:

  * TestAddrinfo: linux (partially)
  * TestKqueue: osx
  * TestLinux: osx + linux
  * TestSharedMem: osx + win + linux 
  * no need: [[ TestSignal: osx + linux ("Bad system call"" with many signals) ]]
  * TestSocket: osx + win + linux
  * TestThread: osx + win + linux 
  	- thread return values have been disabled
  * TestUtil: osx + win + linux

__Some open issues__:

  * Read Lua manuals and Luajit ffi manuals, learn the language ;)
  * Automatize ffi.cdef creation
  * Linux ffi constants differ from OSX, AppServer.lua does not work in Linux
  * Move to native win socket code for IOCP support.
  * AddrinfoTest.lua
  	- what is correct way to call **data parameters, is it data\*[1] ?
  	- set correct parameters to addrinfo calls
  * TestSocket: osx + win + linux
  	 - in XP: lib_socket.lua:57: socket_recv failed with error: (-1), why? Win7 works.
  
### Test Programs

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

Some helper functions.

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
