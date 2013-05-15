--  ffi_def_create.lua

print()
print(" -- ffi_def_create.lua start -- ")
print()

local arg = {...}
local osname
if jit then
	local ffi = require("ffi")
  --local C = ffi.C
	osname = string.lower(ffi.os)
else
	osname = "osx" -- for debug
end
local util = require "lib_util"
local JSON = require "JSON"

local timeUsed = util.seconds()

local openResult, openPrf
if arg[1] then
  openResult = string.lower(arg[1]) == "o"
  openPrf = string.lower(arg[1]) == "p"
end
local prfFileName = "ffi_def_create_prf.json"
local basic_types = {
	"typedef", "struct", 
	"void", "int", "long", "double", "char"
}
local replace_pattern = {
	[" __asm(.*);"] = ";",
	[" __attribute__(.*);"] = ";",
}
local name_separator = "[^_%w]" -- name_separatorarating chars before and after function or definition name
local c_call_pattern = "C%.([_%w]*)" -- arg[3] or "C%.([%w_]+)"
-- http://lua-users.org/wiki/StringRecipes


local generated_start = "-- generated code start --"
local sourcefiles = {
	"lib_date_time.lua", "lib_http.lua", "lib_kqueue.lua", "lib_poll.lua",
	"lib_shared_memory.lua", "lib_signal.lua", 	"lib_socket.lua", 
	"lib_tcp.lua", "lib_thread.lua", "lib_util.lua"
}
local headerfile = "c_include/_system_/all.h"
local target_ffi_file = "ffi_def__system_.lua"
local pref = {
	["basic_types"] = basic_types,
	["name_separator"] = name_separator,
	["c_call_pattern"] = c_call_pattern,
	["replace_pattern"] = replace_pattern,
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
	generated_start = pref.generated_start
	sourcefiles = pref.sourcefiles
	headerfile = pref.headerfile
	target_ffi_file = pref.target_ffi_file
end
headerfile = headerfile:gsub("_system_", osname)
target_ffi_file = target_ffi_file:gsub("_system_", osname)
local basic_types_count = #basic_types
basic_types = util.table_invert(basic_types)
local type_done = {}

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
	while startpos > 0 do
		local ch = str:sub(startpos, startpos)
		if ch == startchar then
			break
		else
			startpos = startpos - 1
		end
	end
	local s,e = str:find(endchar, endpos)
	if e then 
		endpos = e
	end
	return startpos, endpos
end

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

	local words = {}
	local count = 0
	for word in source:gmatch(c_call_pattern) do
		if not words[word] then
			count = count + 1
			words[word] = count
		end
	end

	words = util.table_invert(words)
	table.sort(words, function(a,b) -- case-insensitive sort
			return a:lower() < b:lower() 
		end
	)

	print(util.table_show(words, "calls"))


	-- create not-found new definitions table "new_calls"
	local new_calls = {}
	for i=1,#words do
		local pattern = name_separator..words[i]..name_separator
		local posStart,posEnd = code:find(pattern)
		if not posStart then
			table.insert(new_calls, words[i]) --code:sub(posStart, posEnd))
		end
	end

	if #new_calls == 0 then
		print("no new calls found")
	else
		print("new calls found: "..#new_calls)
		-- create missing definitions from header file
		local function_lines = {}
		local type_defines = {}
		local findpos = 1
		for i=1,#new_calls do
			local pattern = name_separator..new_calls[i]..name_separator --"%f[%a]"..new_calls[i].."%f[%A]"
			local startpos,endpos = header:find(pattern, findpos)
			while startpos do
				local line_start,line_end = stringBetweenPosition(header, startpos, endpos, ";", ";")
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
							def = def:sub(startpos)
						end
					until posStart == nil or posStart == 1
					print("  "..line)
					if def ~= "" and not basic_types[def] then			
						print("    definition added: '"..def.."'")
						type_defines[def] = 0
					end
					table.insert(function_lines, line)
					local params = line
					break -- break out of inner loop
				end
				startpos,endpos = header:find(pattern, findpos)
			end
		end

		-- convert types to basic types
		local type_lines = {}
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
						table.remove(type_defines, i) -- was already in target ffi.cdef file
					else
						if type_not_found[type_str] then			
							print("    type_not_found: '"..type_str.."'")
							table.remove(type_defines, i)
							basic_types[type_str] = 0 --table.insert(basic_types, type_str) -- add to basic types
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
									if line:find("{") then
										local lend = header:find("};", line_end + 1)
										if lend then
											line_end = lend
										end
										line = header:sub(line_start + 1, line_end)
									end
								
									findpos = line_end + 1  -- set next find pos
									line = line:gsub("\n", "")
									while line:find("  ") do -- remove double spaces
										line = line:gsub("  ", " ")
									end
									local posStart,posEnd = line:find(pattern)
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
										if def ~= "" and not basic_types[def] and not type_done[def] then		
											print("    new type found: '"..def.."'", line)
											type_defines[def] = 0
											table.insert(type_lines, 1, line) -- add to start
										else
											if def == "struct" then
												table.insert(type_lines, 1, line) -- add to start
											end
											type_done[type_str] = 0
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
		if #function_lines > 0 or #type_lines > 0 then
			code = code.."\nffi.cdef[[\n\t"
			if #type_lines > 0 then
				code = code..table.concat(type_lines, "\n\t")
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
	
basic_types = util.table_invert(basic_types)
if basic_types_count ~= #basic_types then
	print("New basic types:")
	print(util.table_show(basic_types, "basic_types"))
end
	
timeUsed = util.seconds(timeUsed)
print()
print("created: '"..target_ffi_file.."' in "..util.format_num(timeUsed, 3).." seconds")
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

