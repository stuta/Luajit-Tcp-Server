Luajit-Tcp-Server
=================

Trying to create fastest possible OSX and Windows tcp server and very simple http server with nothing but Lua code. Focus is making this very easy to understad to Lua newcomer.

Currently this just collection of test code.

All code will be OSX + Windows. Contributios are welcome.

##### Utility.lua
  - cstr(str)
  - cerr()
  - getPointer(cdata)
  - createAddressVariable(cdata)
  - createBufferVariable(datalen)
  - getOffsetPointer(cdata, offset)
  - toHexString(num)
  - waitKeyPressed() 
  - sleep(nanosec)
  - nanosleep(nanosec)
  - yield()
  - comma_value(amount, comma)
  - round(val, decimal)
  - format_num(amount, decimal, comma, prefix, neg_prefix)
  - table.show(t, name, indent)

##### SharedMemTest.lua

Creates shared memory area. Mac + Win.

##### ThreadTest.lua

Creates 2 os threads and runs new Lua state in those threads. Parameters can be given and thread join will return result parameter. Mac (Win coming).

##### SignalTest.lua

Start 2 terminals. In terminal 1 run 'luajit SignalTest.lua'. Program will print it's pid. In terminal 2 run 'luajit SignalTest.lua xxx 10000' where xxx is the pid of first program and number is how many times to signal it. Only Mac. Signals are slow and will not be used.
