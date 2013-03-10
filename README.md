Luajit-Tcp-Server
=================

Trying to create fastest possible OSX and Windows tcp server and very simple http server with nothing but Lua code. Focus is making this very easy to understad to Lua newcomer.

Currently this just collection of test code.

All code will be OSX + Windows. Contributios are welcome.

##### SignalTest.lua

###### Usage

Start 2 terminals. In terminal 1 run 'luajit SignalTest.lua'. Program will print it's pid. In terminal 2 run 'luajit SignalTest.lua xxx 10000' where xxx is the pid of first program and number is how many times to signal it.

OSX.

##### SharedMemTest.lua

Creates shared memory area.

OSX + Windows.

##### ThreadTest.lua

Creates 2 os threads and runs new Lua state in those threads. Parameters can be given and thread join will return result parameter.

OSX.
