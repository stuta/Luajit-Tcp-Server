-- lib_poll.lua
-- partly copied from: https://github.com/chatid/fend/blob/master/poll.lua

local ffi = require "ffi"
local C = ffi.C
local bit = require "bit"
local band = bit.band
local bor = bit.bor
ffi.cdef[[
	void* calloc (size_t num, size_t size);
	void* realloc (void* ptr, size_t size);
	void free (void* ptr);
]]

local in_callback, out_callback, close_callback, error_callback
local arrFd, rfds, revents, fds, nfds
local fdsListSize, timeout, fdsListAddCount

local function poll_clear_all()
	in_callback = nil 		-- runs this function when data has come in
	out_callback = nil 		-- runs this function when you can write out
	close_callback = nil	-- runs this function when you need to close socket
	error_callback = nil	-- runs this function when error has happened
	arrFd = {}
	rfds = {}
	revents = {}
	fds = nil 			-- ffi.C memory area containing all (max. fdsListSize) "struct pollfd":s
	nfds = 0 				-- number of active fds
	fdsListSize = 0 -- how many fd's can fit in to fds memory size
	timeout = 0
	fdsListAddCount = 10
end
poll_clear_all()

local function poll_expand_fds(oldFds, countFds)
	print("poll_expand_fds: ", oldFds, countFds)
	local newFds
	if oldFds then
		ffi.gc(oldFds , nil)
		-- oldFds will be used in realloc, mut not garbage collect it, remove it's gc function
	end
	newFds = C.realloc(oldFds, ffi.sizeof("struct pollfd") * countFds)
	if newFds == nil then
		error("Cannot re-allocate memory (poll_expand_fds)")
	end
	local ret = ffi.cast("struct pollfd*", newFds)
	return ffi.gc(ret, ffi.C.free) -- assign ffi.C.free for garbage collect
end

function poll_add_fd(fd, events)
	--print("poll_add_fd: ", fd, events)
	if arrFd[fd] and arrFd[fd] ~= 0 then
		-- is old fd number, is ok when we reuse addresses ???
		print("Fd was already added to index (poll_add_fd): ", arrFd[fd], fd)
	else
		if nfds >= fdsListSize then -- expand nfds C memory area
			fdsListSize = fdsListSize + fdsListAddCount
			fds = poll_expand_fds(fds, fdsListSize)
		end
		arrFd[fd] = nfds -- set arrFd array value to it's index in fd list
	end
	fds[nfds].fd 			= fd -- set C struct pollfd field fd, same as fds[nfds].fd = fd
	fds[nfds].events 	= events -- bor(C.POLLIN, C.POLLOUT, C.POLLRDHUP)
	-- fds[nfds].revents 	= 0 -- no need to set
	nfds = nfds + 1 -- fds is C-mem area and 0-based
end


function poll_remove_fd(fd)
	--print("poll_remove_fd: ", fd)
	if arrFd[fd] == nil then
		print("Fd was not found from array (poll_remove_fd): ", fd)
		return
	end
	local index = arrFd[fd]
	if index == nfds then -- if not last item, move an item from end of list to fill the empty spot
		local lastfd = fds[nfds].fd
		local lastevent = fds[nfds].events
		fds[index].fd = lastfd
		fds[index].events = lastevent
	end
	-- now last item is free, let's clear it
	nfds = nfds - 1
	fds[nfds].fd = 0
	fds[nfds].events = 0
	arrFd[fd] = 0
end


function poll_remove_all(close_func)
	for i=1,nfds-1,1 do
		print("poll_remove_all: ", fds[i].fd)
		close_func(fds[i].fd)
	end
	poll_clear_all()
end

function poll_fd_count()
	return nfds
end

function poll_timeout_set(timeOut)
	timeout = timeOut
end
function poll_in_callback_set(func)
	in_callback = func
end
function poll_out_callback_set(func)
	out_callback = func
end
function poll_close_callback_set(func)
	close_callback = func
end
function poll_error_callback_set(func)
	error_callback = func
end



function poll_poll()
	local ret = C.poll(fds, nfds, timeout)
	if ret == -1 then
		print("poll returned -1 (poll_poll)")
		error(ffi.string(C.strerror(ffi.errno())))
	end

	-- loop all events, break loop as soon as possible
	local served = 0
	for i=0,nfds-1,1 do
		local evt = fds[i].revents
		if  evt~= 0 then
			local fd = fds[i].fd
			-- recheck from documentation which events can happen simultaneously (if vs elseif)
			if band(evt, C.POLLIN) ~= 0 then
				-- POLLIN
				-- print("POLLIN: idx="..i..", evt="..evt..", fd="..fd)
				in_callback(fd)
			end
			-- POLLPRI, not used (yet?)
			if band(evt, C.POLLOUT) ~= 0 then
				-- POLLOUT
				print("POLLOUT: idx="..i..", evt="..evt..", fd="..fd)
				out_callback(fd)
			elseif band(evt, C.POLLHUP) ~= 0 then
				-- POLLHUP, output only
				-- "POLLHUP and POLLOUT are mutually exclusive and should never be present in the revents bitmask at the same time."
				print("POLLHUP: idx="..i..", evt="..evt..", fd="..fd)
				close_callback(fd)
			end
			if band(evt, C.POLLERR) ~= 0 then
				-- POLLERR, output only
				print("POLLERR: idx="..i..", evt="..evt..", fd="..fd)
				error_callback(fd, "POLLERR")
			end
			if band(evt, C.POLLNVAL) ~= 0 then
				-- POLLNVAL, output only
				print("POLLNVAL: idx="..i..", evt="..evt..", fd="..fd)
				error_callback(fd, "POLLNVAL")
			end
			--[[if band(evt, C.POLLRDHUP) ~= 0 then
				-- POLLRDHUP
				print("POLLRDHUP: ", i, evt, fd)
				poll_remove_fd(fd)
				close_callback(fd)
			end]]
		end
		if served == ret then break end -- break loop as soon as possible
	end

	return ret
end
