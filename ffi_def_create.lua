--  ffi_def_create.lua

print()
print(" -- ffi_def_create.lua start -- ")
print()

local arg = {...}
local util = require "lib_util"
local JSON = require "JSON"
local osname
if true then -- keep ffi valid only inside if to make ZeroBrane debugger work
	local ffi = require("ffi")
	osname = string.lower(ffi.os)
end

local timeUsed = util.seconds()

local openResult, openPrf
if arg[1] then
  openResult = string.lower(arg[1]) == "o"
  openPrf = string.lower(arg[1]) == "p"
end
local prfFileName = "ffi_def_create_prf.json"
local basic_types = {
	"void", "short", "int", "long", "double", "char",
	"__int8", "__int16", "__int32", "__int64",
	"int8_t", "int16_t", "int32_t", "int64_t", 
	"uint8_t", "uint16_t", "uint32_t", "uint64_t", "intptr_t", "uintptr_t",
	"ptrdiff_t", "size_t", "wchar_t",
	"va_list", "__builtin_va_list", "__gnuc_va_list",
}
local new_basic_types = {}

local replace_pattern = {
	[" __asm(.*);"] = ";",
	[" __attribute__%(%(noreturn%)%)"] = "",
  ["__routine"] = "",
}
local replace_pattern_param = {
  ["const"] = "",
	[" __asm(.*);"] = ";",
	[" __attribute__(.*);"] = ";",
  ["__routine"] = "",
}
local name_separator = "[^_%w]" -- name_separatorarating chars before and after function or definition name
local c_call_pattern = "C%.([_%w]*)" -- arg[3] or "C%.([%w_]+)"
-- http://lua-users.org/wiki/StringRecipes


local generated_start = "-- generated code start --"
local sourcefiles = {
	"lib_date_time.lua", "lib_http.lua", "lib_kqueue.lua", "lib_poll.lua",
	"lib_shared_memory.lua", "lib_signal.lua", 	"lib_socket.lua", 
	"lib_tcp.lua", "lib_thread.lua", "lib_util.lua",
}
local headerfile = "c_include/_system_/ffi_types.h"
local target_ffi_file = "ffi_def__system_.lua"
local pref = {
	["basic_types"] = basic_types,
	["name_separator"] = name_separator,
	["c_call_pattern"] = c_call_pattern,
	["replace_pattern"] = replace_pattern,
	["replace_pattern_param"] = replace_pattern_param,
	["generated_start"] = generated_start,
	["sourcefiles"] = sourcefiles,
	["headerfile"] = headerfile,
	["target_ffi_file"] = target_ffi_file,
}

if not util.file_exists(prfFileName) then
	local jsonTxt = JSON:encode_pretty(pref)
	io.output(prfFileName)
	io.write(jsonTxt)
	io.output():close()
else
	io.input(prfFileName)
	local jsonTxt = io.read("*all")
	io.input():close()
	local pref = JSON:decode(jsonTxt)
	basic_types = pref.basic_types
	name_separator = pref.name_separator
	c_call_pattern = pref.c_call_pattern
	replace_pattern = pref.replace_pattern
	replace_pattern_param = pref.replace_pattern_param
	generated_start = pref.generated_start
	sourcefiles = pref.sourcefiles
	headerfile = pref.headerfile
	target_ffi_file = pref.target_ffi_file
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

local file,err = io.input(headerfile)
if err then
	print(headerfile.." does not exist, error: "..err)
	os.exit()
end
local header = io.read("*all")
io.input():close()
print(headerfile.." size: "..#header.." bytes")
	
-- read target ffi.cdef file
local code
if util.file_exists(target_ffi_file) then
	file = io.input(target_ffi_file)
	code = io.read("*all")
	io.input():close()
	if generated_start then
		local posStart,posEnd = code:find(generated_start)
		code = code:sub(1, posEnd+1).."\n"
	end
else
	code = ""
end
	
local function stringBetweenPosition(str, startpos, endpos, startchar, endchar)
	-- loop startpos backwards to startchar
	while startpos > 0 do
		local ch = str:sub(startpos, startpos)
		if ch == startchar then
			break
		else
			startpos = startpos - 1
		end
	end
	-- find endchar in forward direction, set endpos
	local s,e = str:find(endchar, endpos)
	if e then 
		endpos = e
	end
	return startpos, endpos
end

local function paramsAdd(params, sep)
	local findpos = 1
	while #params > 0 do
		local def
		local s,e = params:find(sep, findpos)
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
				-- replase not-wanted parts. __asm, __attribute__, ...
				for pat,repl in pairs(replace_pattern_param) do
					def = def:gsub(pat, repl)
				end
				def = def:gsub("const", "")
				def = def:gsub(" %*", " ")
				def = def:gsub("%* ", " ")
				def = def:gsub("%*", "")
				def = def:gsub("%(%)", " ")
				repeat
					while def:sub(1, 1) == " " do -- remove before spaces
						def = def:sub(2)
					end
					while def:sub(-1) == " " do -- remove trailing spaces
						def = def:sub(1, def:len() - 1)
					end
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
				if def ~= "" and def:sub(1, 1) ~= "[" and not basic_types[def] and not type_defines[def] then
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
	local file,err = io.input(sourcefile)
	if err then
		print(sourcefile.." does not exist, error: "..err)
		os.exit()
	end
	local source = io.read("*all")
	io.input():close() 

	print()
	print("*** "..sourcefile.." size: "..#source.." bytes")

	local calls = {}
	local count = 0
	for word in source:gmatch(c_call_pattern) do
		if not calls[word] then
			count = count + 1
			calls[word] = count
		end
	end

	calls = util.table_invert(calls)
	table.sort(calls, function(a,b) -- case-insensitive sort
			return a:lower() < b:lower() 
		end
	)

	print(util.table_show(calls, "calls"))


	-- create not-found new definitions table "new_calls"
	local new_calls = {}
	for i=1,#calls do
		local pattern = name_separator..calls[i]..name_separator
		local posStart,posEnd = code:find(pattern)
		if not posStart then
			table.insert(new_calls, calls[i]) --code:sub(posStart, posEnd))
		end
	end

	if #new_calls == 0 then
		print("no new calls found")
	else
		print("new calls found: "..#new_calls)
		-- create missing definitions from header file
		local function_lines = {}
		local static_const_lines = {}
		for i=1,#new_calls do
			local findpos = 1
			local findcall = new_calls[i]
			if findcall == "pthread_self" then -- for trace
				findcall = "pthread_self"
			end
			local pattern = name_separator..findcall..name_separator --"%f[%a]"..findcall.."%f[%A]"
			local startpos,endpos = header:find(pattern, findpos)
			while startpos do
				local line_start,line_end = stringBetweenPosition(header, startpos, endpos, ";", ";")
				
				if line_start then
					-- skip wrong finds
					local line = header:sub(line_start + 1, line_end)
					local s,e = line:find("= "..findcall) -- pthread_self fix
					if s then
						line_start = nil -- wrong -> find next
						findpos = endpos + 1  -- set next find pos
					else
						-- skip comment lines
						repeat
							local s,e = line:find("\n// ***")
							if e then
								local s2,e2 = line:find("\n", e + 1)
								if s2 then
									line_start = line_start + s2 - 1
									line = header:sub(line_start + 1, line_end)
								end
							end
						until not e
					end
				end
									
				if line_start then
					line_start = line_start + 1 -- remove next "\n"
					local line = header:sub(line_start + 1, line_end)
					findpos = line_end + 1  -- set next find pos
					-- remove front linefeeds
					while line:sub(1, 1) == "\n" do 
						line = line:sub(2)
					end
					-- replase not-wanted parts. __asm, __attribute__, ...
					for pat,repl in pairs(replace_pattern) do
						line = line:gsub(pat, repl)
					end
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
						
					print("  "..line)
					new_calls[i] = "" -- mark as used
					local static_const = line:find("static const ")
					if static_const == 1 then
						table.insert(static_const_lines, line)
					else
						table.insert(function_lines, line)
					
						def = def:gsub("const ", "")
						def = def:gsub("^%s+", "")
						def = def:gsub("\n", "")
						if def ~= "" and not basic_types[def] then			
							print("    type added: '"..def.."'")
							type_defines[def] = 0
						end
						local param_start, param_end = line:find("%(.*%)")
						if param_start then
							local params = line:sub(param_start + 1, param_end - 1)
							paramsAdd(params, ",")
						end
					end
					break -- break out of inner loop
				end
				startpos,endpos = header:find(pattern, findpos)
			end
		end
		
		-- collect not found calls
		table.insert(not_found_calls, "--- "..sourcefile.." ---")
		for i=1,#new_calls do
			if new_calls[i] ~= "" then
				table.insert(not_found_calls, new_calls[i])
			end
		end
		
		-- convert types to basic types
		local type_lines = {}
		local type_lines_content = {}
		local type_not_found = {}
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
					-- find type from target ffi.cdef file
					local pattern = name_separator..type_str..name_separator
					local posStart, posEnd = code:find(pattern)
					if posStart then
						print("  previous type found: "..pattern, code:sub(posStart-20, posEnd+20))
						type_defines[type_str] = nil  -- was already in target ffi.cdef file
					else
						if type_not_found[type_str] then			
							print("    type_not_found: '"..type_str.."'")
							type_defines[type_str] = nil
							basic_types[type_str] = 0 -- add to basic types
							table.insert(new_basic_types, type_str)
							break
						else
							
							type_not_found[type_str] = 0
							local findpos = 1
							local startpos,endpos = header:find(pattern, findpos)
							while startpos do
								local line_start,line_end = stringBetweenPosition(header, startpos, endpos, ";", ";")
								if line_start then
									line_start = line_start + 1 -- remove next "\n"
									local line = header:sub(line_start + 1, line_end)
									local curly_start = line:find("{")
									if curly_start then
										curly_start = curly_start + line_start
										local curly_end= header:find("}", curly_start)
										if curly_end then
											line_end = curly_end + 1 -- "};" is 2 chars
										end
										line = header:sub(line_start + 1, line_end)
									end
								
									findpos = line_end + 1  -- set next find pos
									local line_orig = line
									line_orig = line_orig:gsub("\n", "\n\t")
									line = line:gsub("\n", "")
									while line:find("  ") do -- remove double spaces
										line = line:gsub("  ", " ")
									end
									
									local posStart,posEnd
									if line:find("static const(.*)"..type_str..";") then
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
											
										if not type_lines_content[line] then
											if def:find("pragma pack(.*)struct") then
												def = ""
												if not line_orig:find("pragma pack%(%)") then
													line_orig = line_orig.."\n\t#pragma pack()"
												end
											end
											if def ~= "" and not basic_types[def] and not type_done[def] then	
												--if def ~= "struct" then	
												print("    new type found: '"..def.."'", line)
												type_defines[def] = 0
												--end
											else
												--if def == "struct" or def == "typedef" then
												--end
												type_done[type_str] = 0
											end
											
											table.insert(type_lines, 1, line_orig) -- add to start
											type_lines_content[line] = 1
											
											local static_const = line:find("static const ")
											if static_const == 1 then
												static_const = 1
											else
												local param_start, param_end = line:find("%{.*%}")
												if param_start then
													local params = line:sub(param_start + 1, param_end - 1)
													paramsAdd(params, ";")
												end
											end
										end
																				
										type_defines[type_str] = nil --table.remove(type_defines, i)
										type_not_found[type_str] = nil
										startpos = nil -- break out of inner loop
									else
										startpos,endpos = header:find(pattern, findpos)
									end
								end
							end -- while
							
						end
					end
				end
				
			end -- for
		end -- while next(type_defines) do
		
		-- add new definitions to target ffi.cdef file 
		code = code.."\n--[[ "..sourcefile.." ]]"
		if #function_lines > 0 or #type_lines > 0 or #static_const_lines > 0 then
			code = code.."\nffi.cdef[[\n\t"
			
			if #static_const_lines > 0 then
				-- code = code.."\t// defines"
				code = code..table.concat(static_const_lines, "\n\t")
				if #function_lines > 0 or #type_lines > 0 then
					code = code.."\n\t" -- .."\t// types"
				end
				code = code.."\n\t"
			end
			
			if #type_lines > 0 then
				code = code..table.concat(type_lines, "\n\t")
				if #function_lines > 0 then
					code = code.."\n\t" -- .."\t// methods"
				end
				code = code.."\n\t"
			end
			
			code = code..table.concat(function_lines, "\n\t")
			code = code.."\n]]\n"
		end
		
		file = io.output(target_ffi_file)
		io.write(code)
		io.output():close()
		
	end
end
	
	
--local src = util.table_show(sourcefiles)
if #not_found_calls - #sourcefiles > 0 then
		-- print not found calls
		code = code.."\n\n--[[\n"..util.table_show(not_found_calls, "not found calls").."]]"
		io.output(target_ffi_file)
		io.write(code)
		io.output():close()
		print("\n\n"..util.table_show(not_found_calls, "not found calls"))
end
				
--if #new_basic_types > 0 then
	print()
	print(util.table_show(new_basic_types, "New basic types"))
--end
	
timeUsed = util.seconds(timeUsed)
print()
print("created: '"..target_ffi_file.."' from "..#sourcefiles.." files in "..util.format_num(timeUsed, 3).." seconds")
print()

if openResult then
	os.execute("open "..target_ffi_file)
end
if openPrf then
	os.execute("open "..prfFileName)
end

print()
print(" -- ffi_def_create.lua end -- ")
print()

