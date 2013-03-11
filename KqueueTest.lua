--  KqueueTest.lua
print()
print(" -- KqueueTest.lua start -- ")
print()

local arg = {...}
dofile "kqueue.lua"
local ffi = require("ffi")
local C = ffi.C
local bit = require("bit")
local band = bit.band
local bor = bit.bor

local filename = arg[1] or "/Users/pasi/svnroot/cpp/MA_Lua/github_repos/Luajit-Tcp-Server/KqueueTest.lua"
print("Kqueue test was copied from: http://julipedia.meroh.net/2004/10/example-of-kqueue.html")
print("...watching changes for file: ")
print("   "..filename)

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
local change = keventGet(fd, C.EVFILT_VNODE, flags, fflags, 0, 0)
local event  = keventGet() --ffi.new('struct kevent[1]')

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

print()
print(" -- KqueueTest.lua end -- ")
print()

