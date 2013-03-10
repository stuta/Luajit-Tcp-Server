--  ffi_def_util.lua
local ffi = require "ffi" 
local C = ffi.C
require "bit"

--[[
https://github.com/Wiladams/BanateCoreWin32
]]
ffi.cdef([[
	// OSX basic data types
	typedef int64_t	__darwin_off_t;	
	typedef __darwin_off_t		off_t;
	
	typedef uint16_t	__darwin_mode_t;	
	typedef	__darwin_mode_t		mode_t;
]])

ffi.cdef([[
	// Windows
	// win basic types
		// https://github.com/Wiladams/BanateCoreWin32/blob/master/WTypes.lua
	typedef unsigned char	BYTE;
	typedef long			BOOL;
	typedef BYTE			BOOLEAN;
	typedef char			CHAR;
	typedef wchar_t			WCHAR;
	typedef uint16_t		WORD;
	typedef unsigned long	DWORD;
	typedef uint32_t		DWORD32;
	typedef int				INT;
	typedef int32_t			INT32;
	typedef int64_t			INT64;
	typedef float 			FLOAT;
	typedef long			LONG;
	typedef signed int		LONG32;
	typedef int64_t			LONGLONG;
	typedef size_t			SIZE_T;

	typedef uint8_t			BCHAR;
	typedef unsigned char	UCHAR;
	typedef unsigned int	UINT;
	typedef unsigned int	UINT32;
	typedef unsigned long	ULONG;
	typedef unsigned int	ULONG32;
	typedef unsigned short	USHORT;
	typedef uint64_t		ULONGLONG;


	// Some pointer types
	typedef unsigned char	*PUCHAR;
	typedef unsigned int	*PUINT;
	typedef unsigned int	*PUINT32;
	typedef unsigned long	*PULONG;
	typedef unsigned int	*PULONG32;
	typedef unsigned short	*PUSHORT;
	typedef LONGLONG 		*PLONGLONG;
	typedef ULONGLONG 		*PULONGLONG;


	typedef void *			PVOID;
	typedef DWORD *			DWORD_PTR;
	typedef intptr_t		LONG_PTR;
	typedef uintptr_t		UINT_PTR;
	typedef uintptr_t		ULONG_PTR;
	typedef ULONG_PTR *		PULONG_PTR;


	typedef DWORD *			LPCOLORREF;

	typedef BOOL *			LPBOOL;
	typedef char *			LPSTR;
	typedef short *			LPWSTR;
	typedef const short *	LPCWSTR;
	typedef LPSTR			LPTSTR;

	typedef DWORD *			LPDWORD;
	typedef void *			LPVOID;
	typedef WORD *			LPWORD;

	typedef const char *	LPCSTR;
	typedef LPCSTR			LPCTSTR;
	typedef const void *	LPCVOID;


	typedef LONG_PTR		LRESULT;

	typedef LONG_PTR		LPARAM;
	typedef UINT_PTR		WPARAM;


	typedef unsigned char	TBYTE;
	typedef char			TCHAR;

	typedef USHORT			COLOR16;
	typedef DWORD			COLORREF;

	// Special types
	typedef WORD			ATOM;
	typedef DWORD			LCID;
	typedef USHORT			LANGID;

	// Various Handles
	typedef void *			HANDLE;
	typedef HANDLE			*PHANDLE;
	typedef HANDLE			LPHANDLE;
	typedef void *			HBITMAP;
	typedef void *			HBRUSH;
	typedef void *			HICON;
	typedef HICON			HCURSOR;
	typedef HANDLE			HDC;
	typedef void *			HDESK;
	typedef HANDLE			HDROP;
	typedef HANDLE			HDWP;
	typedef HANDLE			HENHMETAFILE;
	typedef INT				HFILE;
	typedef HANDLE			HFONT;
	typedef void *			HGDIOBJ;
	typedef HANDLE			HGLOBAL;
	typedef HANDLE 			HGLRC;
	typedef HANDLE			HHOOK;
	typedef void *			HINSTANCE;
	typedef void *			HKEY;
	typedef void *			HKL;
	typedef HANDLE			HLOCAL;
	typedef void *			HMEMF;
	typedef HANDLE			HMENU;
	typedef HANDLE			HMETAFILE;
	typedef void			HMF;
	typedef HINSTANCE		HMODULE;
	typedef HANDLE			HMONITOR;
	typedef HANDLE			HPALETTE;
	typedef void *			HPEN;
	typedef LONG			HRESULT;
	typedef HANDLE			HRGN;
	typedef void *			HRSRC;
	typedef void *			HSTR;
	typedef HANDLE			HSZ;
	typedef void *			HTASK;
	typedef void *			HWINSTA;
	typedef HANDLE			HWND;

	// Ole Automation
	typedef WCHAR			OLECHAR;
	typedef OLECHAR 		*LPOLESTR;
	typedef const OLECHAR	*LPCOLESTR;

	//typedef char      OLECHAR;
	//typedef LPSTR     LPOLESTR;
	//typedef LPCSTR    LPCOLESTR;

	typedef OLECHAR *BSTR;
	typedef BSTR *LPBSTR;

	typedef DWORD ACCESS_MASK;
	typedef ACCESS_MASK* PACCESS_MASK;

	typedef LONG FXPT16DOT16, *LPFXPT16DOT16;
	typedef LONG FXPT2DOT30, *LPFXPT2DOT30;
]])

ffi.cdef([[
	// Windows
	// win basic structures
	typedef struct _SECURITY_ATTRIBUTES {
		DWORD nLength;
		LPVOID lpSecurityDescriptor;
		BOOL bInheritHandle;
	} SECURITY_ATTRIBUTES,  *PSECURITY_ATTRIBUTES,  *LPSECURITY_ATTRIBUTES;
]])

ffi.cdef([[
	void 	Sleep(int ms); // win sleep
	int 	poll(struct pollfd *fds, unsigned long nfds, int timeout); // mac sleep
	
	// mac gettimeofday
		// http://www.opensource.apple.com/source/xnu/xnu-1456.1.26/bsd/i386/_types.h
	typedef long time_t; // = typedef long __darwin_time_t;
	typedef int32_t	suseconds_t; // __darwin_suseconds_t;	/* [???] microseconds */
	struct timeval {
             time_t       tv_sec;   /* seconds since Jan. 1, 1970 */
             suseconds_t  tv_usec;  /* and microseconds */
     				};
	int 	gettimeofday(struct timeval *restrict tp, void *restrict tzp);
	
	 // mac nanosleep
	struct timespec { int tv_sec; long tv_nsec; };
	int 	nanosleep(const struct timespec *req, struct timespec *rem);
	
	int 	sched_yield(void); // mac yield
	bool  SwitchToThread(void); // win yield
     
	 
	// win QueryPerformanceCounter
	typedef union _LARGE_INTEGER { 
		struct {
			DWORD LowPart;
			LONG  HighPart;
		} ;
		struct {
			DWORD LowPart;
			LONG  HighPart;
		} u;
		LONGLONG QuadPart;
	} LARGE_INTEGER, *PLARGE_INTEGER;
	
	BOOL QueryPerformanceFrequency( // BOOL WINAPI QueryPerformanceFrequency
  	LARGE_INTEGER *lpFrequency // _Out_  LARGE_INTEGER *lpFrequency
	);
	BOOL QueryPerformanceCounter( // BOOL WINAPI QueryPerformanceCounter
  	LARGE_INTEGER *lpPerformanceCount // _Out_  LARGE_INTEGER *lpPerformanceCount
	);
	int MultiByteToWideChar(UINT CodePage,
			DWORD    dwFlags,
			LPCSTR   lpMultiByteStr, int cbMultiByte,
			LPWSTR  lpWideCharStr, int cchWideChar);
	int WideCharToMultiByte(UINT CodePage,
			DWORD    dwFlags,
			LPCWSTR  lpWideCharStr, int cchWideChar,
			LPSTR   lpMultiByteStr, int cbMultiByte,
			LPCSTR   lpDefaultChar,
			LPBOOL  lpUsedDefaultChar);
]])

-- global utility
isWin = (ffi.os == "Windows")
isMac = (ffi.os == "OSX")
is64bit = ffi.abi("64bit")
is32bit = ffi.abi("32bit")

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
			return string.char(tonumber(c))
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
    C.poll(nil, 0, millisec)
  	--local microseconds = s*1000
  	--usleep (microseconds)
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
	print() -- 0x004fffffffffffba
	local value64_c
	value64_c = ffi.new("int64_t", 0x003fffffffffffba)
	print("value64_c", value64_c, ffi.cast("void *", value64_c))
	value64_c = ffi.new("int64_t", 0x004fffffffffffba)
	print("value64_c", value64_c, ffi.cast("void *", value64_c))
	
	local val2 = ffi.cast("int64_t", returnValue64_c)
	print("val2", val2, ffi.cast("void *", val2))
	
	
	local value32 = tonumber(ffi.cast("int32_t", returnValue64_c))
	print("value32        ", type(value32), value32, string.format("%x", value32))

	local addr_var = ffi.new("intptr_t[1]") -- createAddressVariable
	addr_var[0] = ffi.cast("int64_t", returnValue64_c) 
	-- if we don't convert int64_t to array type ffi.copy will "segfault 11"
	print("addr_var        ", type(addr_var), addr_var, toHexString(addr_var[0]))
	
	local buffer = createBufferVariable(8 ) -- 8 bytes = 64 bits
	local addr_ptr = getOffsetPointer(addr_var, 0)
	local buffer_ptr = getOffsetPointer(buffer, 0)
	ffi.copy(buffer_ptr, addr_var, 64)
	print("buffer_ptr      ", type(buffer_ptr), buffer_ptr, toHexString(buffer_ptr[0]))
	
	local ret = createBufferVariable(4) -- 4 bytes = 32 bits
	local ret_ptr = getOffsetPointer(ret, 0)
	ffi.copy(ret_ptr, buffer_ptr, 4)
	print("ret lsb         ", type(ret), ret[0]) --, toHexString(ret[0]))
	
	local buffer_ptr = getOffsetPointer(buffer, 4)
	ffi.copy(ret_ptr, buffer_ptr, 4)
	print("ret msb         ", type(ret), ret[0]) --, toHexString(ret[0]))
	--print("ret_ptr      ", type(ret_ptr), ret_ptr, toHexString(ret_ptr[0]))
	]]
	
--[[
	
	buffer =  ffi.new("uint32_t *[?]", 128) --createBufferVariable
	print("buffer          ", type(buffer), buffer, buffer[0]) --, toHexString(buffer[0]))
	ffi.copy(buffer, addr_var[0], 32)
	print("buffer          ", buffer[0], buffer[1]) --, toHexString(buffer[0]))
	print("buffer          ", buffer[2], buffer[3]) --, toHexString(buffer[0]))
	]]
	
	-- in Lua 0x001fffffffffffff is the biggest value that does not change when converting to Lua double with 'tonumber(returnValue64_c)'
  --returnValue64_c = bit.band(returnValue64_c, 0x00ffffff) -- get rid of highest bits
  returnValue = tonumber(returnValue64_c)  -- this can do overflow
	
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

function microSeconds( prevMs )
  return get_seconds(3, prevMs)
end

function milliSeconds(prevMs)
  return get_seconds(2, prevMs)
end

function seconds( prevMs )
  return get_seconds(1, prevMs)
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


function cstr(str)
	local len = str:len()+1
  local typeStr = "uint8_t[" .. len .. "]"
  return ffi.new( typeStr, str )
end

function cerr()
	error( ffi.string(ffi.C.strerror(ffi.errno())) )
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
