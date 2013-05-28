--  ffi_def_create.lua

print()
print(" -- ffi_def_create.lua start -- ")
if jit then
	print(jit.version)
	--require("jit.v").start("ffi_def_create_jit.txt")
else
	print(_VERSION)
end
print()

local arg = {...}
local util = require "lib_util"
local json = require "dkjson"
local osname
if true then -- keep ffi valid only inside if to make ZeroBrane debugger work
	local ffi = require("ffi")
	osname = string.lower(ffi.os)
end
-- osname = "linux" -- if you want to create linux with osx
osname = "windows" -- if you want to create windows with osx

local timeUsed = util.seconds()

local openResult, openPrf, saveModifiedHeader, openModifiedHeader
if arg[1] then
  openResult = string.lower(arg[1]) == "o"
  openPrf = string.lower(arg[1]) == "p"
end
if arg[2] then
	local arg2 = string.lower(arg[2])
  saveModifiedHeader = arg2:find("s")
  openModifiedHeader = arg2:find("o")
end
local prfFileName = "ffi_def_create_prf.json"
local basic_types = {
	"void", "...", "double", "char",
	"short", "int", "long", "long int", "long long",
	"unsigned", --"unsigned short int", "unsigned int", "unsigned long", "unsigned long int", "unsigned long long",
	"__int8", "__int16", "__int32", "__int64",
	"int8_t", "int16_t", "int32_t", "int64_t",
	"uint8_t", "uint16_t", "uint32_t", "uint64_t",
	"__int8_t", "__int16_t", "__int32_t", "__int64_t",
	"__uint8_t", "__uint16_t", "__uint32_t", "__uint64_t",
	"intptr_t", "uintptr_t",
	"ptrdiff_t", "size_t", "wchar_t",
	"va_list", "__builtin_va_list", "__gnuc_va_list",
}
local not_found_basic_types = {}

if false then
	local test = "row1\n /*comment*/ \n /***\nasd\ndsa\n */\n // asd\nrow2\n"
	local test =[[

	//   _Pre_\_Post_ Layer:
//
// e.g. int strlen( _Pre_z_ const char* sz );
	//   _Pre_\_Post_ Layer:
//

]]
	print("-------test:\n"..test)
	local test2 = test:gsub("\n(%s*)/%*(.-)%*/" ,"") -- remove line starting "/* sdasdf */" -comments
	print("-------test2:\n"..test2)
	local test2 = test:gsub("\n(%s*)//(.-)(%s*)\n" ,"\n") -- remove line starting "//" -comments
	local test2 = test2:gsub("\n(%s*)//(.-)(%s*)\n" ,"\n") -- remove line starting "//" -comments
	print("-------test2:\n"..test2)
	os.exit()
end

local replace_pattern = {
	-- "xxx(.-)\n" == delete all to end of line including xxx
  "# (%d+) \"(.-)\"(.-)\n", -- delete gcc header links
  "#pragma once(.-)\n",
  "#pragma warning(.-)\n",
  "#pragma comment(.-)\n",
  "#pragma (.-)\n",

  "WINBASEAPI\n",
  "__drv_reportError(.-)\n",
  "__drv_when(.-)\n",
  "__out\n",

  "deprecated%((.-)%)( *)", -- must be before "__declspec%((.-)%)"
	"__attribute__%(%((.-)%)%)( *)",
	"__const( *)",
	"__asm%((.-)%)( *)",
	"__inline( *)",
  "__restrict( *)",
  "extern( *)",
  "__extension__( *)",
  "__extension__( *)",
  "__MINGW_NOTHROW( *)",
  "_CRTIMP( *)",
  "__cdecl( *)",
  "PASCAL( *)",
  "__checkReturn( *)",
  "DECLSPEC_IMPORT( *)",
  "DECLSPEC_NORETURN( *)",
  "FARPROC( *)",
  "WINAPI( *)",
  "CONST ",
  "__declspec%((.-)%)( *)",
  "__success%((.-)%)( *)",
  "__field_bcount%((.-)%)( *)",

  "__out_%wcount_full( ?)%((.-)%)( *)",
  "__out_%wcount_part_opt( ?)%((.-)%)( *)",
  "__out_%wcount_part( ?)%((.-)%)( *)",
  "__out_%wcount_opt( ?)%((.-)%)( *)",
  "__out_%wcount( ?)%((.-)%)( *)",

  "__in_%wcount_full( ?)%((.-)%)( *)",
  "__in_%wcount_part_opt( ?)%((.-)%)( *)",
  "__in_%wcount_part( ?)%((.-)%)( *)",
  "__in_%wcount_opt( ?)%((.-)%)( *)",
  "__in_%wcount( ?)%((.-)%)( *)",
  "__%wcount_opt( ?)%((.-)%)( *)",
  "_%wcount_part_opt( ?)%((.-)%)( *)",
  "_%wcount_part( ?)%((.-)%)( *)",
  "_%wcount_opt( ?)%((.-)%)( *)",
  "_%wcount( ?)%((.-)%)( *)",

  "__out_data_source%((.-)%)( *)",
  "__drv_preferredFunction%((.-)%)( *)",
  "__deref_opt_out_%wcount_full%((.-)%)( *)",
  "__drv_freesMem%((.-)%)( *)",

  "__post( *)",
  "__notvalid( *)",

  "__deref_opt_out_opt( *)",
  "__deref_opt_out( *)",
  "__deref_out( *)",
  "__deref_inout( *)",
  "__deref( *)",
  "__inout_opt( *)",
  "__in_opt( *)",
  "__out_opt( *)",
  "__inout( *)",
  "__in ",
  "__out ",
  "__opt ",
  "__reserved ",
  "__stdcall( *)",
  "__nullnullterminated( *)",
  "__callback( *)",
  "__drv_aliasesMem( *)",
}

local replace_pattern_param = {
  -- ["%)"] = "",
}

-- name_separator, separating chars before and after function or definition name
local name_separator = "[^_%w]"
local define_param_separator = "|" --"[|,;]"
local c_call_patterns = {
	"%WC%.([_%w]*)",
	"%Wkernel32%.([_%w]*)",
	--"%Wwin32%.([_%w]*)",
	"%Ws%.([_%w]*)",
}
local c_type_patterns = {
	"ffi.new%(%'(.-)%'",
	"ffi.new%(%\"(.-)%\"",
	"ffi.cast%(%'(.-)'",
	"ffi.cast%(%\"(.-)\"",
}
-- http://lua-users.org/wiki/StringRecipes

--[[
-- c_type_patterns test
local source ="  	local kev = ffi.new('struct kevent[1]')"
local source = source..'\n  	local kev = ffi.new("struct kevent[1]")'
local source = source..'\n  local err_c = ffi.cast("int", err)")'
	for _,patt in pairs(c_type_patterns) do
		local txt = source:match(patt)
		for params in source:gmatch(patt) do
			print(params, patt)
		end
	end
]]

local generated_start = "-- generated code start --"
local sourcefiles = {
	"lib_date_time.lua", "lib_http.lua", "lib_kqueue.lua", "lib_poll.lua",
	"lib_shared_memory.lua", "lib_signal.lua", 	"lib_socket.lua",
	"lib_tcp.lua", "lib_thread.lua", "lib_util.lua",

	"TestAddrinfo.lua", "TestAll.lua", "TestKqueue.lua",
	"TestLinux.lua", "TestSharedMemory.lua", "TestSignal.lua",
	"TestSignal_bad.lua", "TestSocket.lua", "TestThread.lua",
}
local headerfile = "c_include/_system_/ffi_types.h"
local target_ffi_file = "ffi_def__system_.lua"
local pref = {
	["basic_types"] = basic_types,
	["name_separator"] = name_separator,
	["c_call_patterns"] = c_call_patterns,
	["c_type_patterns"] = c_type_patterns,
	["replace_pattern"] = replace_pattern,
	["replace_pattern_param"] = replace_pattern_param,
	["generated_start"] = generated_start,
	["sourcefiles"] = sourcefiles,
	["headerfile"] = headerfile,
	["target_ffi_file"] = target_ffi_file,
}

if not util.file_exists(prfFileName) then
	local jsonTxt = json.encode(pref, { indent = true })
	io.output(prfFileName)
	io.write(jsonTxt)
	io.output():close()
else
	io.input(prfFileName)
	local jsonTxt = io.read("*all")
	io.input():close()
	local pref = json.decode(jsonTxt)
	if pref.basic_types then basic_types = pref.basic_types end
	if pref.name_separator then name_separator = pref.name_separator end
	if pref.c_call_patterns then c_call_patterns = pref.c_call_patterns end
	if pref.c_type_patterns then c_type_patterns = pref.c_type_patterns end
	if pref.replace_pattern then replace_pattern = pref.replace_pattern end
	if pref.replace_pattern_param then replace_pattern_param = pref.replace_pattern_param end
	if pref.generated_start then generated_start = pref.generated_start end
	if pref.sourcefiles then sourcefiles = pref.sourcefiles end
	if pref.headerfile then headerfile = pref.headerfile end
	if pref.target_ffi_file then target_ffi_file = pref.target_ffi_file end
end
headerfile = headerfile:gsub("_system_", osname)
target_ffi_file = target_ffi_file:gsub("_system_", osname)
basic_types = util.table_invert(basic_types)
local type_done = {
	["struct"] = 0, -- prevent addind basic types, mark as already done
}
local type_defines = {}

if #sourcefiles < 1 then
	print("error: no input files given")
	os.exit()
end

local function removeAllLineComments(txt)
	txt = txt:gsub("/%*(.-)%*/" ,"") -- remove "/* */" -comments
	local txtall = {}
	for line in txt:gmatch("[^\n]+") do
		local s = line:find("//")
		if s then
			line = line:sub(1, s - 1) -- remove "//" -comments
		end
		txtall[#txtall+1] = line
	end
	--[[if #txtall > 0 then
		txtall = txtall:sub(1, #txtall - 1) -- remove last "\n"
	end]]
	txtall = table.concat(txtall, "\n")
	return txtall
end

local function removeLineStartComments(txt)
	txt = txt:gsub("\n(%s-)/%*(.-)%*/" ,"") -- remove line starting "/* */" -comments
	txt = txt:gsub("^(%s-)/%*(.-)%*/" ,"") -- remove first line starting "/* */" -comments
	repeat
		txt = txt:gsub("\n(%s-)//(.-)\n" ,"\n") -- remove line starting "//" -comments
	until not txt:find("\n(%s-)//(.-)\n")
	repeat
		txt = txt:gsub("^(%s-)//(.-)\n" ,"\n") -- remove first line starting "//" -comments
	until not txt:find("^(%s-)//(.-)\n")
	return txt
end

local function replaceText(txt)
	-- replace not-wanted parts. __asm, __attribute__, ...
	for i=1,#replace_pattern do
		local pat = replace_pattern[i]
		--repeat
		txt = txt:gsub(pat, "")
		--until not txt:find(pat)
	end

	--txt = removeLineStartComments(txt)
	txt = txt:gsub("\n(%s-)/%*(.-)%*/" ,"") -- remove line starting "/* */" -comments
	repeat
		txt = txt:gsub("\n(%s-)//(.-)\n" ,"\n") -- remove line starting "//" -comments
	until not txt:find("\n(%s-)//(.-)\n")

	repeat
		txt = txt:gsub("\n\n", "\n")
	until not txt:find("\n\n")
	txt = txt:gsub("\n \n", "\n")

	txt = txt:gsub("\n(%s-);\n", ";\n") -- lonely ";" back to previous line end
	txt = txt:gsub("%)(%s-);\n", ");\n") -- lonely ") ;" --> ");"

	return txt
end

local function replaceLine(line)
	--line = line:gsub("\r\n", "\n")
	line = line:match("^\n*(.-)\n*$") -- remove leading and trailing linefeed
	line = line:match("^%s*(.-)%s*$") -- remove leading and trailing whitespace
	--[[if line:find("struct") then
		if line:find("\n") then
			line = line.."\n" -- add extra if multiline struct
		end
	end
	line = line:match("^%s*(.-)%s*$") -- remove leading and trailing whitespace
	]]
	return line
end

local function readHeaderFile()
	local file,err = io.input(headerfile)
	if err then
		print(headerfile.." does not exist, error: "..err)
		os.exit()
	end
	local header = io.read("*all")
	io.input():close()
	print(headerfile.." size: "..util.fileSize(#header, 2))
	if #header==0 then
		print(headerfile.." is empty")
		os.exit()
	end

	io.write("  replacing header: "..headerfile.."...")
	io.flush()
	header = replaceText(header)
	local _,count = header:gsub("\n","\n")
	print(", "..util.format_num(count, 0).." lines")
	if saveModifiedHeader then
		local filename = headerfile:gsub("%.h", "_replaced.h")
		print("  replaced header : "..filename)
		util.writeFile(filename, header)
		if openModifiedHeader then
			util.openFile(filename)
		end
	end
	return header
end
local header = readHeaderFile()

-- read target ffi.cdef file
local code
if util.file_exists(target_ffi_file) then
	file = io.input(target_ffi_file)
	code = io.read("*all")
	io.input():close()
	if generated_start then
		local posStart,posEnd = code:find(generated_start)
		if posEnd then
			code = code:sub(1, posEnd+1).."\n"
		end
	end
else
	code = ""
end

local function validType(def)
	def = removeAllLineComments(def)
	local s = def:find(" ")
	if s then  -- define must not contain space
		def = def:sub(1, s - 1) -- return part before space
	end
	local first_char = def:sub(1, 1)
	if first_char == "(" or first_char == "[" or first_char == "{" or first_char == "*" then
	  return ""
	end
	def = def:match( "^%s*(.-)%s*$" ) -- remove leading and trailing whitespace
	def = def:gsub( "%)", "" ) -- remove ")"
	return def
end

local function stringBetweenPosition(str, startpos, endpos, startstr, endstr)
	-- loop startpos backwards to startstr
	local findlen = startstr:len() - 1
	while startpos > 0 do
		local str = str:sub(startpos, startpos + findlen)
		if str == startstr then
			break
		else
			startpos = startpos - 1
		end
	end
	-- find endstr in forward direction, set endpos
	local s,e = str:find(endstr, endpos)
	if e then
		endpos = e
	end
	return startpos, endpos
end


local function typeDoneAdd(params_orig, sep)
	local findpos = 1
	local params = params_orig
	while #params > 0 do
		local def
		local s,e = params:find(sep, findpos, true)
		if s then
			def = params:sub(1, s - 1)
			params = params:sub(e + 1)
		else
			def = params
			params = ""
		end
		if def then
			def = def:match("^%s*(.-)%s*$") -- remove leading and trailing spaces
			def = def:gsub("%*", "") -- remove pointer marks
			print("    define type added: '"..def.."'")
			type_done[def] = 0
			type_defines[def] = nil -- remove if was in list to search
		end
	end
end


local function paramsAdd(params_orig, sep)
	if not params_orig then return end
	local findpos = 1
	local params = params_orig
	if params:find("typedef enum") then
		return
	end
	while #params > 0 do
		local def
		local s,e = params:find(sep, findpos, true)
		if s then
			def = params:sub(1, s - 1)
			params = params:sub(e + 1)
		else
			def = params
			params = ""
		end
		local basetype = ""
		if def then
			if not def:find("static const ") then
				def = def:gsub("\n", "")
				def = def:gsub("const", "")
				def = def:gsub(" %*", " ")
				def = def:gsub("%* ", " ")
				def = def:gsub("%*", "")
				def = def:gsub("%(%)", " ")
				repeat
					def = def:match( "^%s*(.-)%s*$" ) -- remove leading and trailing spaces
					-- http://rosettacode.org/wiki/Strip_whitespace_from_a_string/Top_and_tail#Lua
					local posStart,posEnd = def:find(name_separator)
					if posStart then
						basetype = def:sub(1, posStart - 1)
						def = def:sub(posStart)
					end
				until posStart == nil or posStart == 1 or def == ""
				if basetype ~= "" and basetype ~= "struct" then
					def = basetype
				end
				def = def:gsub("%(void %)", "")
				def = def:gsub("%(void%)", "")
				def = def:gsub("%(%)", "")
				def = def:gsub("(.-)%-%>", "")
				--def = def:gsub("(.-)%.", "")
				def = def:match( "^%s*(.-)%s*$" ) -- remove leading and trailing whitespace
				def = validType(def)
				if def ~= "" and not basic_types[def] and not type_defines[def] then
					if not basic_types[basetype] then -- def is just a name
						print("    parameter type added: '"..def.."'")
						type_defines[def] = 0
					end
				end
			end

		end
	end
end


local not_found_calls = {}
-- main loop, go through all files
for _,sourcefile in pairs(sourcefiles) do

	local source
	-- create source text
	local function createSourceText()
		local file,err = io.input(sourcefile)
		if err then
			print(sourcefile.." does not exist, error: "..err)
			os.exit()
		end
		source = io.read("*all")
		io.input():close()

		--local crlfLen = #source
		--source = source:gsub("\r\n", "\n") -- does not work?
		print()
		print("*** "..sourcefile.." size: "..util.fileSize(#source, 2)) -- / "..(crlfLen - #source))
		-- Lua pattern for matching Lua multi-line comment.
		source = source:gsub("(%-%-%[(=*)%[.-%]%2%])", "") -- remove block comments
		-- Lua pattern for matching Lua single line comment.
		source = source:gsub("(%-%-[^\n]*)", "")-- remove single line comments
	end
	createSourceText()

	-- add ffi.new and ffi.cast type parameters
	local function addCTypeParameters()
		for _,patt in pairs(c_type_patterns) do
			for params in source:gmatch(patt) do
				params = removeAllLineComments(params)
				local s = params:find("%[")
				if s then
					params = params:sub(1, s - 1)
				end
				paramsAdd(params, ",")
			end
		end
	end
	addCTypeParameters()

	local calls = {}
	local function addCalls()
		local count = 0
		for _,patt in pairs(c_call_patterns) do
			for call in source:gmatch(patt) do
				if call ~= "" and not calls[call] then
					count = count + 1
					calls[call] = count
				end
			end
		end

		calls = util.table_invert(calls)
		table.sort(calls, function(a,b) -- case-insensitive sort
				return a:lower() < b:lower()
			end
		)
		print(util.table_show(calls, "calls"))
	end
	addCalls()

	local new_calls = {}
	-- create not-found new definitions table "new_calls"
	local function createNotFoundNewDefinitions()
		for i=1,#calls do
			local call = calls[i]
			local pattern = name_separator..call..name_separator
			local posStart,posEnd = code:find(pattern)

			-- check if function was already defined as struct
			if posStart then
				local code_call = code:sub(posStart - 7, posEnd) -- 7 = #("struct ")
				if code_call:find("struct "..call) then
					posStart = nil -- add function
				end
			end

			if not posStart then
				table.insert(new_calls, call) --code:sub(posStart, posEnd))
			end
		end
		print("new calls found: "..#new_calls)
	end
	createNotFoundNewDefinitions()

	local function_lines = {}
	local static_const_lines = {}
	-- create missing definitions from header file
	local function createMissingDefinitionsFromHeader()
		for i=1,#new_calls do
			local postfix = ""
			local findpos = 1
			local findcall = new_calls[i]
			if findcall:find("IN6_SET_ADDR_UNSPECIFIED") then -- for trace
				findcall = findcall .. ""
			end
			local pattern = name_separator..findcall..name_separator --"%f[%a]"..findcall.."%f[%A]"
			local startpos,endpos = header:find(pattern, findpos)
			while startpos do
				local line_start,line_end = stringBetweenPosition(header, startpos, endpos, ";", ";")
				local pragma_pack
				if line_start then
					local line = header:sub(line_start + 1, line_end)

					line = removeAllLineComments(line)
					-- skip wrong finds, re-find after removing comments
					local s,e = line:find(pattern)
					if not s then
						line_start = nil -- wrong -> find next
						findpos = endpos + 1  -- set next find pos
					end

					--[[skip pre-} and post { -- , see difftime
						  xxx;
						}
						static __inline double __attribute__((__cdecl__)) difftime(time_t _Time1, time_t _Time2)
						{
							 return _difftime64(_Time1,_Time2);
						}
					]]
					local s,e = line:find(pattern) -- re-find after removing comments
					s2,e2 = line:find("{")
					if e and s2 then
						if s2 > e then
							postfix = ";"
							line_end = line_end - (#line - s2 + 1)
							line = header:sub(line_start + 1, line_end)
							if line:sub(#line, #line) == "\n" then
								line_end = line_end - 1
								line = header:sub(line_start + 1, line_end)
							end
							line = line:gsub("\n", "")..postfix
						end
					end
					local s2,e2 = line:find("}")
					if s and e2 then
						if e2 < s  then
							line_start = line_start + e2 + 1
							line = header:sub(line_start + 1, line_end)..postfix
						end
					end

					if line_start then
						-- function name is same struct name (osx kevent and struct kevent)
						local pos_struct = line:find("%Wstruct "..findcall.."%W")
						if pos_struct then
							local pos_call = line:find(findcall.."%W")
							if pos_call > pos_struct then
								line_start = nil -- wrong -> find next
								findpos = endpos + 1  -- set next find pos
							end
						end
					end

					 -- function on the right side of "=" fix (osx pthread_self)
					if line_start then
						local s,e = line:find("= "..findcall)
						if s then
							line_start = nil -- wrong -> find next
							findpos = endpos + 1  -- set next find pos
						end
					end

					if line_start then
						 -- pragma pack fix
						local s,e = line:find("pragma pack")
						if e then
							local s = line:find("\n", e)
							pragma_pack = header:sub(line_start + 2, line_start + s - 1)
							line_start = line_start + s - 1
							local s2,e2 = header:find("pragma pack%(%)", line_start + e)
							line_end = e2
							line = header:sub(line_start, line_end)
						end
					end
				end

				if line_start then

					line_start = line_start + 1 -- remove next "\n"
					local line = header:sub(line_start + 1, line_end)..postfix
					local lineEndDebud = line:sub(#line - 30, #line)
					findpos = line_end + 1  -- set next find pos
					-- remove front linefeeds
					while line:sub(1, 1) == "\n" do
						line = line:sub(2)
					end

					line = removeAllLineComments(line)
					line = replaceLine(line)

					new_calls[i] = "" -- mark as used
					if line ~= "" then
						local def = header:sub(line_start + 1, startpos - 1)
						repeat
							while def:sub(-1) == " " do -- remove trailing spaces
								def = def:sub(1, def:len() - 1)
							end
							local posStart,posEnd = def:find(name_separator)
							if posStart then
								def = def:sub(posStart)
							end
						until posStart == nil or posStart == 1

						if pragma_pack then
							line = pragma_pack.."\n"..line
							line = line:gsub("\n", "\n")
							line = line:gsub("#pragma pack", "// #pragma pack")
						end
						print("  "..line)
						--[[if line:find("RaiseException") then
							line = line..""
						end]]
						local static_const = line:find("static const ")
						if static_const == 1 then
							table.insert(static_const_lines, line)
							local params = line:match("%((.-)%)")
							if params then
								paramsAdd(params, define_param_separator)
							end
						else
							if line:find("\n") then
								line = "\n"..line -- add extra line in front if is multiline definition
							end
							table.insert(function_lines, line)

							def = def:gsub("const ", "")
							def = def:gsub("^%s+", "")
							def = def:gsub("\n", "")
							def = validType(def)

							if def ~= "" and not basic_types[def] and not type_done[def] then
								if line:find("enum") == 1 then
									def = def..""  -- for trace
								else
									print("    type added: '"..def.."'")
									type_defines[def] = 0
								end
							end

							line = removeAllLineComments(line)
							local param_delim
							local param_start, param_end = line:find("%{.-%}") -- struct params
							if param_start then
								param_delim = ";"
							else
								param_start, param_end = line:find("%(.-%)") -- function params
								param_delim = ","
							end
							if param_start then
								if line:find("enum") == 1 then
									param_delim = "" -- for trace
								else
									local params = line:sub(param_start + 1, param_end - 1)
									paramsAdd(params, param_delim)
								end
							end
						end
					end -- if line ~= "" then

					break -- break out of inner loop
				end
				startpos,endpos = header:find(pattern, findpos)
			end
		end
	end
	createMissingDefinitionsFromHeader()


	-- collect not found calls
	local function collectNotFoundCalls()
		table.insert(not_found_calls, "--- "..sourcefile.." ---")
		for i=1,#new_calls do
			if new_calls[i] ~= "" then
				table.insert(not_found_calls, new_calls[i])
			end
		end
	end
	collectNotFoundCalls()

	local function typeNotFoundAdd(type_str)
		print("    type_not_found: '"..type_str.."'")
		type_defines[type_str] = nil
		basic_types[type_str] = 0 -- add to basic types
		table.insert(not_found_basic_types, type_str)
	end

	local type_lines_basic = {}
	local type_lines = {}
	local struct_lines = {}
	local type_lines_content = {}
	local type_not_found = {}
	-- convert types to basic types
	local function convertTypesToBasicTypes()
		local loopCount = 0
		while next(type_defines) do
			print()
			loopCount = loopCount + 1
			print(loopCount..". convert types to basic types:")
			for type_str,_ in pairs(type_defines) do
				if type_done[type_str] then
					type_defines[type_str] = nil
				else
					print("  '"..type_str.."'")

					-- for trace
					if type_str:find("sockaddr") then
						if jit then
							print(jit.version)
						else
							print(_VERSION)
						end
					end

					-- find type from target ffi.cdef file
					local pattern = name_separator..type_str..name_separator
					local posStart, posEnd = code:find(pattern)
					if posStart then
						print("  previous type found: "..type_str) --pattern, code:sub(posStart-20, posEnd+20))
						type_defines[type_str] = nil  -- was already in target ffi.cdef file
					else
						if type_not_found[type_str] then
							typeNotFoundAdd(type_str)
							break
						else

							type_not_found[type_str] = 0
							local findpos = 1
							local startpos,endpos = header:find(pattern, findpos)
							while startpos do
								local line_start,line_end = stringBetweenPosition(header, startpos, endpos, ";", ";")
								local line
								if not line_start then
										typeNotFoundAdd(type_str)
								else
									line_start = line_start + 1 -- remove next "\n"
									line = header:sub(line_start + 1, line_end)
									line = removeLineStartComments(line)

									local line2 = removeAllLineComments(line)
									-- skip wrong finds, re-find after removing comments
									local s = line2:find(pattern)
									if not s then
										line_start = nil -- wrong -> find next
										findpos = endpos + 1  -- set next find pos
									else
										-- part of another definition inside (function) parameters  -- Linux __sighandler_t
										if line:find("(.-)%((.-)"..type_str.."(.-)%)") then
											line_start = nil -- part of some other static const
											findpos = endpos + 1  -- set next find pos
											-- continue and find next
										end
										if line_start then
											-- part of another definition inside (structure) parameters
											if line:find("(.-)%{(.-)"..type_str) then -- Linux __sighandler_t
												line_start = nil -- part of some other static const
												findpos = endpos + 1  -- set next find pos
												-- continue and find next
											end
										end
									end
								end

								if line_start then
									local line_pos = line:find(type_str)
									local curly_end = line:find("}")
									if curly_end and curly_end < line_pos then
										-- find previous "typedef union" or "typedef struct", use later found
										local s,e = stringBetweenPosition(header, startpos, endpos, "typedef union", ";")
										line_start,line_end = stringBetweenPosition(header, startpos, endpos, "typedef struct", ";")
										if s > line_start then
											line_start,line_end = s,e
										end
										line = header:sub(line_start , line_end)
									else
										local curly_start = line:find("{")
										if curly_start then
											curly_start = curly_start + line_start
											local curly_end = header:find("}", curly_start)
											if curly_end then
												curly_end = header:find(";", curly_end + 1)
												line_end = curly_end -- "};" is 2 chars
											end
											line = header:sub(line_start + 1, line_end)
										end
									end

									findpos = line_end + 1  -- set next find pos
									line = replaceLine(line)
									local line_orig = line
									line = removeAllLineComments(line)
									--line = line:gsub("\n", "")
									while line:find("  ") do -- remove double spaces
										line = line:gsub("  ", " ")
									end

									local posStart,posEnd
									if line:find("static const(.-)"..type_str..";") then
										posStart = nil -- part of some other static const
										-- continue and find next
									else
										posStart,posEnd = line:find(pattern)
									end

									if posStart then
										local def = line:sub(1, posStart - 1)
										repeat
											while def:sub(-1) == " " do -- remove trailing spaces
												def = def:sub(1, def:len() - 1)
											end
											local posStart,posEnd = def:find(name_separator)
											if posStart then
												def = def:sub(posStart + 1)
											end
										until posStart == nil or posStart == 1

										def = def:match( "^%s*(.-)%s*$" ) -- remove leading and trailing whitespace
										if not type_lines_content[line] then
											type_lines_content[line] = 1
											if def:find("pragma pack(.-)struct") then
												def = ""
												if not line_orig:find("pragma pack%(%)") then
													line_orig = line_orig.."\n#pragma pack()"
													line_orig = line_orig:gsub("#pragma pack", "// #pragma pack")
												end
											end

											def = validType(def)
											if def == "" then
												type_done[type_str] = 0
											elseif not basic_types[def] and not type_done[def] then
												print("    new type found: '"..def.."'") --, line)
												type_defines[def] = 0
											else
												type_done[type_str] = 0
											end

											if line_orig ~= "" then
												if line_orig:find("\n") then
													line_orig = "\n"..line_orig -- add extra line in front if is multiline definition
												end
												local static_const = line:find("static const ")
												if static_const == 1 then
													table.insert(static_const_lines, 1, line_orig) -- add to start
													local params = line:match("%((.-)%)")
													if params then
														paramsAdd(params, define_param_separator)
													end
												elseif basic_types[def] then
													table.insert(type_lines_basic, 1, line_orig) -- add to start
												else
													table.insert(type_lines, 1, line_orig)
												end
												if line:find("typedef struct ") then
													local params = line:match("%{(.-)%}")
													paramsAdd(params, ";")
													local types = line:match("%}(.-)%;")
													if types then
														typeDoneAdd(types, ",")
													end
												end
											end
											local static_const = line:find("static const ")
											if static_const == 1 then
												static_const = 1
											else
												local param_start, param_end = line:find("%{.-%}")
												if param_start then
													local params = line:sub(param_start + 1, param_end - 1)
													paramsAdd(params, ";")
													local types = line:match("%}(.-)%;")
													if types and line:match("typedef struct") then
														typeDoneAdd(types, ",")
													end
												end
											end
										end

										type_defines[type_str] = nil --table.remove(type_defines, i)
										type_not_found[type_str] = nil
										startpos = nil -- break out of inner loop
									end
								end
								if startpos then
									startpos,endpos = header:find(pattern, findpos)
									if not startpos then
										typeNotFoundAdd(type_str)
									end
								end
							end -- while

						end
					end
				end

			end -- for
		end -- while next(type_defines) do
	end
	convertTypesToBasicTypes()

	-- add new definitions to target ffi.cdef file
	local function addNewDefinitionsToTargetCdefFile()
		code = code.."\n--[[ "..sourcefile.." ]]"
		if #static_const_lines > 0 or #type_lines_basic > 0 or #type_lines > 0 or #struct_lines > 0 or #function_lines > 0 then
			code = code.."\nffi.cdef[[\n"

			if #static_const_lines > 0 then
				code = code..table.concat(static_const_lines, "\n")
				if #type_lines > 0 or #struct_lines > 0 or #function_lines > 0 then
					code = code.."\n\n"
				end
			end

			if #type_lines_basic > 0 then
				code = code..table.concat(type_lines_basic, "\n")
				if #type_lines > 0 then
					code = code.."\n\n"
				end
			end

			if #type_lines > 0 then
				code = code..table.concat(type_lines, "\n")
				if #struct_lines > 0 or #function_lines > 0 then
					code = code.."\n\n"
				end
			end

			if #struct_lines > 0 then
				code = code..table.concat(struct_lines, "\n")
				if #function_lines > 0 then
					code = code.."\n\n"
				end
			end

			if #function_lines > 0 then
				code = code..table.concat(function_lines, "\n")
			end
			code = code.."\n]]\n"
		end

		--code = code:gsub("\n\n\n", "\n\n")
		file = io.output(target_ffi_file)
		io.write(code)
		io.output():close()
	end
	addNewDefinitionsToTargetCdefFile()

end


if #not_found_calls - #sourcefiles > 0 then
		-- print not found calls
		code = code.."\n\n--[[\n"..util.table_show(not_found_calls, "not found calls").."]]"
		code = code.."\n\n--[[\n"..util.table_show(not_found_basic_types, "not found basic types").."]]"
		util.writeFile(target_ffi_file, code)
		print("\n\n"..util.table_show(not_found_calls, "not found calls"))
end

print()
print(util.table_show(not_found_basic_types, "not found basic types"))

timeUsed = util.seconds(timeUsed)
print()
print("created: '"..target_ffi_file.."' from "..#sourcefiles.." files in "..util.format_num(timeUsed, 3).." seconds")
print()

if openResult then
	util.openFile(target_ffi_file)
end
if openPrf then
	util.openFile(prfFileName)
end

print()
if jit then
	print(jit.version)
else
	print(_VERSION)
end
print(" -- ffi_def_create.lua end -- ")
print()

