Luajit-Tcp-Server
=================

Trying to create fastest possible OSX and Windows tcp server end very simple http server with nothing but Lua code.

Currently this just collection of test code.

##### SignalTest.lua

###### Usage

Start 2 terminals. In terminal 1 run 'luajit SignalTest.lua'. Program will print it's pid. In terminal 2 run 'luajit SignalTest.lua xxx 10000' where xxx is the pid of first program and number is how many times to signal it.

Currently this first version crashes in OSX 10.8.2 after few thousand signals.