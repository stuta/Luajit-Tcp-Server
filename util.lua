--  ffi_def_util.lua
local ffi = require "ffi" 
local C = ffi.C
require "bit"

-- global utility
isWin = (ffi.os == "Windows")
isMac = (ffi.os == "OSX")
is64bit = ffi.abi("64bit")
is32bit = ffi.abi("32bit")
if isWin then
	dofile "ffi_def_win.lua"
else
	dofile "ffi_def_mac.lua"
end

-- common Win + OSX: C-functions
ffi.cdef([[
	char * strerror ( int errnum );
]])

-- Lua state - creating a new Lua state to a new thread
ffi.cdef([[
	typedef struct lua_State lua_State;
	lua_State *luaL_newstate(void);
	void luaL_openlibs(lua_State *L);
	void lua_close(lua_State *L);
	int luaL_loadstring(lua_State *L, const char *s);
	int lua_pcall(lua_State *L, int nargs, int nresults, int errfunc);
	
	static const int LUA_GLOBALSINDEX = -10002;
	void lua_getfield(lua_State *L, int index, const char *k);
	ptrdiff_t lua_tointeger(lua_State *L, int index);
	void lua_settop(lua_State *L, int index);
]])

function cstr(str)
	local len = str:len()+1
  local typeStr = "uint8_t[" .. len .. "]"
  return ffi.new( typeStr, str )
end

function cerr()
	error( ffi.string(ffi.C.strerror(ffi.errno())) )
end

function getPointer(cdata)
	if is64bit then
		return ffi.cast("int64_t", cdata)
	elseif is32bit then
		return ffi.cast("int32_t", cdata)
	end
	return nil
end

function createAddressVariable(cdata)
	local addr_var = ffi.new("uintptr_t[1]")
	addr_var[0] = getPointer(cdata)
	return addr_var
end

function createBufferVariable(datalen)
	return ffi.new("int8_t *[?]", datalen)
end

function getOffsetPointer(cdata, offset)
	return ffi.cast("int8_t *", getPointer(cdata) + offset)
end

function toHexString(num)
	if type(num) ~= "number" then
		num = tonumber(num) -- try to cast for ex. cdata[0]
	end
	if is64bit then
		return string.format("0x%016x", num)
	elseif is32bit then
		return string.format("0x%08x", num)
	end
	return nil
end

if isWin then

	function processorCoreCount() 
		local sysinfo = ffi.new("SYSTEM_INFO[1]")
		C.GetSystemInfo(sysinfo)
		print(sysinfo[0].dwNumberOfProcessors)
	end
 
	function waitKeyPressed() 
		--[[
		DWORD mode, count;
		HANDLE h = GetStdHandle( STD_INPUT_HANDLE );
		if (h == NULL) return 0;  // not a console
		GetConsoleMode( h, &mode );
		SetConsoleMode( h, mode & ~(ENABLE_LINE_INPUT | ENABLE_ECHO_INPUT) );
		TCHAR c = 0;
		ReadConsole( h, &c, 1, &count, NULL );
		SetConsoleMode( h, mode );
		]]
		print( C.STD_INPUT_HANDLE )
		local h = C.GetStdHandle( C.STD_INPUT_HANDLE )
		if not h then return 0 end-- not a console
		local mode = ffi.new("DWORD[1]")
		C.GetConsoleMode( h, mode )
		local modeSet = bit.band(mode[0], bit.bnot(bit.bor(C.ENABLE_LINE_INPUT, C.ENABLE_ECHO_INPUT)))
		C.SetConsoleMode( h, modeSet )
		local ch = ffi.new("DWORD[1]")
		local count = ffi.new("DWORD[1]")
		C.ReadConsoleA( h, ch, 1, count, nil )
		C.SetConsoleMode( h, mode[0] )
		return string.char(tonumber(ch[0]))
	end

  function yield()
    C.SwitchToThread()
  end
  
  function sleep(millisec)
    C.Sleep(millisec)
  end
  
	function nanosleep(nanosec)
		local millisec = math.floor(nanosec/1000) 
		--if millisec < 1 then
		--	millisec = 0 -- Sleep(0), best we can do
		--end
		C.Sleep(millisec) -- better solution for windows?
	end
	
else -- OSX, Posix, Linux?

	function processorCoreCount()
		-- http://www.gnu.org/software/libc/manual/html_node/Processor-Resources.html 
		local count = C.sysconf(C._SC_NPROCESSORS_ONLN) -- returns int64_t
		return tonumber(count)
	end
	
	function waitKeyPressed() 
    --http://lua.2524044.n2.nabble.com/How-to-get-one-keystroke-without-hitting-Enter-td5858614.html
    os.execute("stty cbreak </dev/tty >/dev/tty 2>&1") 
    local key = io.read(1) 
    os.execute("stty -cbreak </dev/tty >/dev/tty 2>&1"); 
    return(key);    
  end
  
  function yield()
    C.sched_yield() 
  end
  
  function sleep(millisec)
    --C.poll(nil, 0, millisec)
  	local microseconds = millisec * 1000
  	C.usleep (microseconds)
  end
  
	function nanosleep(nanosec)
		local t = ffi.new("struct timespec", {tv_sec = 0, tv_nsec = nanosec})
		return C.nanosleep(t, nil) -- assert(C.nanosleep(t, nil) == 0)
	end
	
end

function get_seconds( multiplier, prevMs )
	local returnValue64_c -- = ffi.new("int64_t")
	local returnValueMsb = 0
	local returnValueLsb = 0
	local returnValue = 0 -- lua double

	if isWin then
		--  Get the high resolution counter's accuracy.
		local ticksPerSecond = ffi.new("LARGE_INTEGER")
		C.QueryPerformanceFrequency (ticksPerSecond)
	
		--  What time is it?
		local tick = ffi.new("LARGE_INTEGER")
		C.QueryPerformanceCounter (tick) -- tick[0] ??
		--  Convert the tick number into the number of seconds since the system was started.
		returnValue64_c = (tick.QuadPart * 100000) / (ticksPerSecond.QuadPart / 1000) -- time in microseconds
	else
		-- OSX, Posix, Linux?
		-- Use POSIX gettimeofday function to get precise time.
		local tv = ffi.new("struct timeval")
		local rc = C.gettimeofday (tv, nil)
		if rc ~= 0 then
			returnValue64_c = ffi.new("int64_t", -1) -- error here, we need to have returnValue64_c always ctype<int64_t>
		else
			returnValue64_c = (tv.tv_sec * 1000000) + tv.tv_usec
		end
	end

	--[[
	 in Lua 0x001fffffffffffff is the (about) biggest value that does not change when 
	 converting to Lua double with 'tonumber(returnValue64_c)'
   returnValue64_c = bit.band(returnValue64_c, 0x00ffffff) -- get rid of highest bits
	 bit.band() does not work before Luajit 2.1 with 64 bit integers
	]]
	-- best way to get rid of highest bits, better to have unsigned int in timer:
	returnValue = tonumber(ffi.cast("uint32_t", returnValue64_c)) 
	
	if isWin then
		if multiplier == 1 then
			returnValue = returnValue / 100000000  -- seconds -> microseconds
		elseif multiplier == 2 then
			returnValue = returnValue / 100000 -- seconds -> milliseconds
		else
			returnValue = returnValue / 100
		end
	else
  	-- OSX, Posix, Linux?
		if multiplier == 1 then
			returnValue = returnValue / 1000000 -- microseconds -> second
		elseif multiplier == 2 then
			returnValue = returnValue / 1000 -- microseconds -> milliseconds
		end
	end
	
	if prevMs then
		if prevMs > returnValue then
			returnValue = prevMs - returnValue
		else
			returnValue = returnValue - prevMs
		end
	end
  return returnValue
end

function seconds( prevMs )
  return get_seconds(1, prevMs)
end

function milliSeconds(prevMs)
  return get_seconds(2, prevMs)
end

function microSeconds( prevMs )
  return get_seconds(3, prevMs)
end


-- add comma to separate thousands
function comma_value(amount, comma)
	comma = comma or ' ' -- in us comma = ','
	if comma == '' then comma = ' ' end -- must be something or will not work
  local formatted = amount

  local k
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1' .. comma .. '%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function round(val, decimal)
  if decimal then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

-- given a numeric value formats output with comma to separate thousands
-- and rounded to given decimal places
function format_num(amount, decimal, comma, prefix, neg_prefix)
  local formatted, famount, remain
  decimal = decimal or 2  -- default 2 decimal places
  comma = comma or ' '
  neg_prefix = neg_prefix or "-" -- default negative sign
  famount = math.abs(round(amount,decimal))
  famount = math.floor(famount)
  remain = round(math.abs(amount) - famount, decimal)
        -- comma to separate the thousands
  if( comma~='' ) then
  	formatted = comma_value(famount, comma)
  else
  	formatted = tostring(famount)
  end
        -- attach the decimal portion
  if (decimal > 0) then
    remain = string.sub(tostring(remain),3)
    formatted = formatted .. "." .. remain ..
                string.rep("0", decimal - string.len(remain))
  end
        -- attach prefix string e.g '$' 
  formatted = (prefix or "") .. formatted 
        -- if value is negative then format accordingly
  if (amount<0) then
    if (neg_prefix=="()") then
      formatted = "("..formatted ..")"
    else
      formatted = neg_prefix .. formatted 
    end
  end
  return formatted
end


-- === external utilities === --

-- http://lua-users.org/wiki/TableSerialization
--[[
   Author: Julio Manuel Fernandez-Diaz
   Date:   January 12, 2007
   (For Lua 5.1)
   
   Modified slightly by RiciLake to avoid the unnecessary table traversal in tablecount()

   Formats tables with cycles recursively to any depth.
   The output is returned as a string.
   References to other tables are shown as values.
   Self references are indicated.

   The string returned is "Lua code", which can be procesed
   (in the case in which indent is composed by spaces or "--").
   Userdata and function keys and values are shown as strings,
   which logically are exactly not equivalent to the original code.

   This routine can serve for pretty formating tables with
   proper indentations, apart from printing them:

      print(table.show(t, "t"))   -- a typical use
   
   Heavily based on "Saving tables with cycles", PIL2, p. 113.

   Arguments:
      t is the table.
      name is the name of the table (optional)
      indent is a first indentation (optional).
--]]
function table.show(t, name, indent)
   local cart     -- a container
   local autoref  -- for self references

   --[[ counts the number of elements in a table
   local function tablecount(t)
      local n = 0
      for _, _ in pairs(t) do n = n+1 end
      return n
   end
   ]]
   -- (RiciLake) returns true if the table is empty
   local function isemptytable(t) return next(t) == nil end

   local function basicSerialize (o)
      local so = tostring(o)
      if type(o) == "function" then
         local info = debug.getinfo(o, "S")
         -- info.name is nil because o is not a calling level
         if info.what == "C" then
            return string.format("%q", so .. ", C function")
         else 
            -- the information is defined through lines
            return string.format("%q", so .. ", defined in (" ..
                info.linedefined .. "-" .. info.lastlinedefined ..
                ")" .. info.source)
         end
      elseif type(o) == "number" or type(o) == "boolean" then
         return so
      else
         return string.format("%q", so)
      end
   end

   local function addtocart (value, name, indent, saved, field)
      indent = indent or ""
      saved = saved or {}
      field = field or name

      cart = cart .. indent .. field

      if type(value) ~= "table" then
         cart = cart .. " = " .. basicSerialize(value) .. ";\n"
      else
         if saved[value] then
            cart = cart .. " = {}; -- " .. saved[value] 
                        .. " (self reference)\n"
            autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
         else
            saved[value] = name
            --if tablecount(value) == 0 then
            if isemptytable(value) then
               cart = cart .. " = {};\n"
            else
               cart = cart .. " = {\n"
               for k, v in pairs(value) do
                  k = basicSerialize(k)
                  local fname = string.format("%s[%s]", name, k)
                  field = string.format("[%s]", k)
                  -- three spaces between levels
                  addtocart(v, fname, indent .. "   ", saved, field)
               end
               cart = cart .. indent .. "};\n"
            end
         end
      end
   end

   name = name or "__unnamed__"
   if type(t) ~= "table" then
      return name .. " = " .. basicSerialize(t)
   end
   cart, autoref = "", ""
   addtocart(t, name, indent)
   return cart .. autoref
end
