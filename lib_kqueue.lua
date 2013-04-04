--  lib_kqueue.lua
module(..., package.seeall)

local ffi = require("ffi")
local C = ffi.C
--[[local bit = require("bit")
local band = bit.band
local bor = bit.bor]]
--local util = require "lib_util"
-- kqueue, kevent
--[[
https://bitbucket.org/armatys/perun/src/f106ac49f19ae6aa7a0615914420d2a7e7f370e6/lua/perun/init.lua
http://julipedia.meroh.net/2004/10/example-of-kqueue.html
]]


--[[
-- Constants
local eventcount = 512
local intptr_t = ffi.typeof('intptr_t')

local context = {}
function context:init()
	self.handlers = {} -- dictionary of handlers for given event family
	self.isrunning = false -- tells whether the loop should keep running
	self.kevents = ffi.new('struct kevent[?]', eventcount) -- Stores events fetched when polling the kqfd
	self.kqfd = C.kqueue() -- a file descriptor for the kqueue
	self.listeners = { ['read'] = {}, ['write'] = {}, ['timeout'] = {} } -- list of callbacks for particular events
	self.timerid = 1 -- a counter for timeout fd (for the use of kqueue)
	self.defers = {}
end
context:init()
--print(table_show(context, "context"))
]]

function kevent_get(ident, filter, flags, fflags, data, udata)
	local kev = ffi.new('struct kevent[1]')
	if ident then
		kev[0].ident = ident 		-- identifier for this event
	end
	if filter then
		kev[0].filter = filter	-- filter for event
	end
	if flags then
		kev[0].flags = flags		-- general flags
	end
	if fflags then
		kev[0].fflags = fflags	-- filter-specific flags
	end
	if data then
		kev[0].data = data			-- filter-specific data
	end
	if udata and udata ~= 0 then
		kev[0].udata = udata		-- opaque user data identifier
	end
	return kev
end

--[[
http://julipedia.meroh.net/2004/10/example-of-kqueue.html
	int f, kq, nev;
struct kevent change;
struct kevent event;

kq = kqueue();
if (kq == -1)
 perror("kqueue");

f = open("/tmp/foo", O_RDONLY);
if (f == -1)
	 perror("open");

EV_SET(&change, f, EVFILT_VNODE,
			EV_ADD | EV_ENABLE | EV_ONESHOT,
			NOTE_DELETE | NOTE_EXTEND | NOTE_WRITE | NOTE_ATTRIB,
			0, 0);

for (;;) {
	 nev = kevent(kq, &change, 1, &amp;event, 1, NULL);
	 if (nev == -1)
			 perror("kevent");
	 else if (nev > 0) {
			 if (event.fflags & NOTE_DELETE) {
					 printf("File deleted\n");
					 break;
			 }
			 if (event.fflags & NOTE_EXTEND ||
					 event.fflags & NOTE_WRITE)
					 printf("File modified\n");
			 if (event.fflags & NOTE_ATTRIB)
					 printf("File attributes modified\n");
	 }
}

close(kq);
close(f);
return EXIT_SUCCESS;
]]

--return 0 --EXIT_SUCCESS
