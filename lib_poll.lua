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
local fds, nfds, pollCount
local fdsListSize, timeout, fdsListAddCount, debug
local fdAddCount, fdRemoveCount

local function poll_clear_all()
	in_callback = nil 		-- runs this function when data has come in
	out_callback = nil 		-- runs this function when you can write out
	close_callback = nil	-- runs this function when you need to close socket
	error_callback = nil	-- runs this function when error has happened
	fds = nil 			-- ffi.C memory area containing all (max. fdsListSize) "struct pollfd":s
	nfds = 0 				-- number of active fds
	pollCount = 0
	fdsListSize = 0 -- how many fd's can fit in to fds memory size
	timeout = 0
	fdsListAddCount = 10
	debug = false
	fdAddCount = 0
	fdRemoveCount = 0
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

local function fd_arr_index(fd)
	local idx = nfds - 1 -- better to loop from en, more likely to find correct
	while idx >= 0 do
		if fds[idx].fd == fd then return idx end
		idx = idx - 1
	end
	return -1
end

local function fd_arr_show()
	local idx = 0
	local txt = "fds["
	while idx < nfds do
		txt = txt..fds[idx].fd
		idx = idx + 1
		if idx < nfds then
			txt = txt..", "
		end
	end
	return txt.."], nfds="..nfds
end

function poll_add_fd(fd, events)
	fdAddCount = fdAddCount + 1
	local idx = fd_arr_index(fd)
	if idx >= 0 then
		-- is old fd number, is ok when we reuse addresses ???
		print("ERR: Fd was already added to array (poll_add_fd): idx="..idx..", fd="..fd..", nfds="..nfds)
		print(fd_arr_show())
	else
		if nfds >= fdsListSize then -- expand nfds C memory area
			fdsListSize = fdsListSize + fdsListAddCount
			fds = poll_expand_fds(fds, fdsListSize)
		end
	end
	fds[nfds].fd 			= fd -- set C struct pollfd field fd, same as fds[nfds].fd = fd
	fds[nfds].events 	= events -- bor(C.POLLIN, C.POLLOUT, C.POLLRDHUP)
	-- fds[nfds].revents 	= 0 -- no need to set
	nfds = nfds + 1 -- fds is C-mem area and 0-based, so add it only in the end
	if debug > 0 then print("  poll_add_fd: fd="..fd..", nfds="..nfds) end
end

function poll_remove_fd(fd)
	fdRemoveCount = fdRemoveCount + 1
	local idx = fd_arr_index(fd)
	if idx < 0 then
		print("ERR: Fd was not found from array (poll_remove_fd): fd="..fd..", nfds="..nfds)
		print(fd_arr_show())
		return
	end
	if idx ~= nfds-1 then -- if not last item, move an item from end of list to fill the empty spot
		if debug > 0 then
			print("  poll_remove_fd from middle: idx=".. idx+1 ..", fd="..fd..", nfds="..nfds)
			print("  "..fd_arr_show())
		end
		nfds = nfds - 1 -- decrease nfds count so that fds[nfds] is zero-based
		local lastfd = fds[nfds].fd
		local lastevent = fds[nfds].events
		fds[idx].fd = lastfd
		fds[idx].events = lastevent
		if debug > 0 then
			print("  "..fd_arr_show())
		end
	else
		nfds = nfds - 1 -- decrease nfds count so that fds[nfds] is zero-based
		fds[idx].fd = -1
		if debug > 0 then
			print("  poll_remove_fd from end   : idx=".. idx+1 ..", fd="..fd..", nfds="..nfds)
			print("  "..fd_arr_show())
		end
	end
end


function poll_remove_all(close_func)
	for i=0,nfds-1 do
		print("poll_remove_all: ", fds[i].fd)
		close_func(fds[i].fd)
	end
	poll_clear_all()
end

function poll_poll_count()
	return pollCount
end

function poll_fd_count()
	return nfds
end

function poll_fd_add_count()
	return fdAddCount
end

function poll_fd_remove_count()
	return fdRemoveCount
end

function poll_debug_set(deBug)
	debug = deBug
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
	pollCount = pollCount + 1
	local ret = socket_poll(fds, nfds, timeout)
	if ret == -1 then
		print(pollCount..". poll, nfds="..nfds)
		socket_cleanup(fds[0].fd, ret, "socket_poll failed with error: ")
	elseif ret == 0 then
		return 0
	end

	-- loop all events, break loop as soon as possible
	local served = 0
	for i=1,nfds do
		local evt = fds[i-1].revents
		if evt~= 0 then
			local fd = fds[i-1].fd
			-- recheck from documentation which events can happen simultaneously (if vs elseif)
			-- http://www.greenend.org.uk/rjk/tech/poll.html

			if band(evt, C.POLLHUP) ~= 0 then -- C.POLLIN | C.POLLHUP, but we don't want C.POLLIN
				-- POLLHUP, output only
				if debug > 0 then print(pollCount..". POLLHUP : idx="..i..", evt="..evt..", fd="..fd..", nfds="..nfds) end
				close_callback(fd)
			elseif band(evt, C.POLLIN) ~= 0 then
				-- POLLIN
				if debug > 0 then print(pollCount..". POLLIN  : idx="..i..", evt="..evt..", fd="..fd..", nfds="..nfds) end
				in_callback(fd)
			elseif band(evt, C.POLLPRI) ~= 0 then
				--[[POLLPRI	Priority data may be read without blocking. This flag is not supported by the Microsoft Winsock provider.]]
				if debug > 0 then print(pollCount..". POLLPRI : idx="..i..", evt="..evt..", fd="..fd..", nfds="..nfds) end
				in_callback(fd)
			end
			if band(evt, C.POLLOUT) ~= 0 then
				-- POLLOUT
				-- "POLLHUP and POLLOUT are mutually exclusive and should never be present in the revents bitmask at the same time."
				-- because we exclude POLLHUP and POLLIN we cand exclude POLLOUT
				if debug > 0 then print(pollCount..". POLLOUT : idx="..i..", evt="..evt..", fd="..fd..", nfds="..nfds) end
				out_callback(fd)
			end
			if band(evt, C.POLLERR) ~= 0 then
				-- POLLERR, output only
				if debug > 0 then print(pollCount..". POLLERR : idx="..i..", evt="..evt..", fd="..fd..", nfds="..nfds) end
				error_callback(fd, "POLLERR")
			end
			if band(evt, C.POLLNVAL) ~= 0 then
				-- POLLNVAL, output only
				if debug > 0 then print(pollCount..". POLLNVAL: idx="..i..", evt="..evt..", fd="..fd..", nfds="..nfds) end
				error_callback(fd, "POLLNVAL")
			end
			--[[if band(evt, C.POLLRDHUP) ~= 0 then
				-- POLLRDHUP
				print("POLLRDHUP: ", i, evt, fd)
				close_callback(fd)
			end]]
		end
		if served == ret then break end -- break loop as soon as possible
	end

	return ret
end
