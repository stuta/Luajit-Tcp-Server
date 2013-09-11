--  TestKqueue.lua
print()
print(" -- TestKqueue.lua start -- ")
print()

local arg = {...}
local util = require "lib_util" 
local kqueue = require "lib_kqueue" 
local ffi = require("ffi")
local C = ffi.C
local bit = require("bit")
local band = bit.band
local bor = bit.bor

local filename = arg[1] or "/Users/pasi/svnroot/cpp/MA_Lua/github_repos/Luajit-Tcp-Server/TestKqueue.lua"
print("Kqueue test was copied from: http://julipedia.meroh.net/2004/10/example-of-kqueue.html")
print("...watching changes for file: ")
print("   "..filename)

if util.isWin then
	--[[
	windows IOCP
	http://stackoverflow.com/questions/4093185/whats-the-difference-between-epoll-poll-threadpool
	]]

	local iocp = CreateIoCompletionPort(INVALID_HANDLE_VALUE, 0, 0, 0) -- equals epoll_create
	iocp = CreateIoCompletionPort(mySocketHandle, iocp, 0, 0) -- equals epoll_ctl(EPOLL_CTL_ADD)

	local o --OVERLAPPED o;
	while true do
	local status = GetQueuedCompletionStatus(iocp, number_bytes, key, o, C.INFINITE) --(iocp, &number_bytes, &key, &o, INFINITE)
    if status then -- equals epoll_wait()
      print("do_something()")
    end
  end

else
	-- OSX, others
	-- Kqueue test was copied from: http://julipedia.meroh.net/2004/10/example-of-kqueue.html
	-- https://bitbucket.org/armatys/perun/src/73691238301fe07d6727bda7933901f8bda83258/lua/perun/init.lua

	local kq = C.kqueue()
	if kq == -1 then
		error("kqueue")
	end
	local fd = C.open(filename, C.O_RDONLY)
	if fd == -1 then
		 error("open")
	end
	local flags = bor(C.EV_ADD, C.EV_ENABLE, C.EV_ONESHOT)
	local fflags = bor(C.NOTE_DELETE, C.NOTE_EXTEND, C.NOTE_WRITE, C.NOTE_ATTRIB)
	local change = kqueue.kevent_get(fd, C.EVFILT_VNODE, flags, fflags, 0, 0)
	local event  = kqueue.kevent_get() --ffi.new('struct kevent[1]')

	while true do
		local flags
		local nev = C.kevent(kq, change, 1, event, 1, nil)
		if nev == -1 then
			error("kevent")
		elseif nev > 0 then

			flags = band(event[0].fflags, C.NOTE_DELETE)
			if flags ~= 0 then
				 print("File deleted")
				 break
			end

			flags = bor(band(event[0].fflags, C.NOTE_EXTEND), band(event[0].fflags, C.NOTE_WRITE))
			if flags ~= 0 then
				 print("File modified")
			end

			flags = band(event[0].fflags, C.NOTE_ATTRIB)
			if flags ~= 0 then
				 print("File attributes modified")
			end
		else
			print("not hadled kevent: "..nev)
		end
	end

	C.close(kq)
	C.close(fd)
end

print()
print(" -- TestKqueue.lua end -- ")
print()

