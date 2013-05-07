--  ffi_def_create.lua

print()
print(" -- ffi_def_create.lua start -- ")
print()

local arg = {...}
local ffi = require("ffi")
local C = ffi.C
local util = require "lib_util"
local JSON = require "JSON"

local openResult, openPrf
if arg[1] then
  openResult = string.lower(arg[1]) == "o"
  openPrf = string.lower(arg[1]) == "p"
end
local prfFileName = "ffi_def_create_prf.json"
local basic_type = {
	"typedef", "struct", 
	"int", "long", "double",
}
local name_separator = "[^_%w]" -- name_separatorarating chars before and after function or definition name
local c_call_pattern = "C%.([_%a][_%w]*)" -- arg[3] or "C%.([%w_]+)"
-- http://lua-users.org/wiki/StringRecipes

local generated_start = "-- generated code start --"
local sourcefile = "lib_date_time.lua"
local headerfile = "c_include/osx/sys/time.h"
local target_ffi_file = "ffi_def_"..string.lower(ffi.os)..".lua"
local pref = {
	["basic_type"] = basic_type,
	["name_separator"] = name_separator,
	["c_call_pattern"] = c_call_pattern,
	["generated_start"] = generated_start,
	["sourcefile"] = sourcefile,
	["headerfile"] = headerfile,
	["target_ffi_file"] = target_ffi_file,
}

if not util.file_exists(prfFileName) then
	local jsonTxt = JSON:encode_pretty(pref)
	io.output(prfFileName)
	io.write(jsonTxt)
	io.close()
else
	io.input(prfFileName)
	local jsonTxt = io.read("*all")
	io.close()
	local pref = JSON:decode(jsonTxt)
	generated_start = pref.generated_start
	sourcefile = pref.sourcefile
	headerfile = pref.headerfile
	target_ffi_file = pref.target_ffi_file
	basic_type = pref.basic_type
	name_separator = pref.name_separator
	c_call_pattern = pref.c_call_pattern
end
local basic_type_count = #basic_type

if not sourcefile then
	print("error: no input file given")
	os.exit()
end
basic_type = util.table_invert(basic_type)

local file,err = io.input(sourcefile)
if err then
	print(sourcefile.." does not exist, error: "..err)
	os.exit()
end
local code = io.read("*all")
io.close()

local file,err = io.input(headerfile)
if err then
	print(headerfile.." does not exist, error: "..err)
	os.exit()
end
local header = io.read("*all")
io.close()

print(sourcefile.." size: "..#code.." bytes")
print(headerfile.." size: "..#header.." bytes")

local words = {}
local count = 0
for word in code:gmatch(c_call_pattern) do
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

-- read target ffi.cdef file
if util.file_exists(target_ffi_file) then
	file = io.input(target_ffi_file)
	code = io.read("*all")
	if generated_start then
		local posStart,posEnd = code:find(generated_start)
		code = code:sub(1, posEnd+1).."\n"
	end
else
	code = ""
end
io.close()

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
	local type_words = {}
	for i=1,#new_calls do
		local pattern = name_separator..new_calls[i]..name_separator --"%f[%a]"..new_calls[i].."%f[%A]"
		for line in header:gmatch("[^\r\n]+") do
			--print(line)
			local posStart,posEnd = line:find(pattern)
			if posStart then
				local def = line:sub(1, posStart - 1)
				repeat
					local posStart,posEnd = def:find(name_separator)
					if posStart then
						def = def:sub(posStart)
					end
				until posStart == nil
				print("  "..line)
				if not basic_type[def] then		
					print("    definition added: '"..def.."'")
					table.insert(type_words, def)
				end
				table.insert(function_lines, line)
				break -- break out of inner loop
			end
		end
	end

	-- convert types to basic types
	local type_lines = {}
	local not_found_type = {}
	local loopCount = 0
	while #type_words > 0 do
		print()
		loopCount = loopCount + 1 
		print(loopCount..". resolving types:")
		for i=1,#type_words do
			local type_str = type_words[i]
			print("  type: '"..type_str.."'")
			-- find type from target ffi.cdef file
			local pattern = name_separator..type_str..name_separator
			local posStart, posEnd = code:find(pattern)
			if posStart then
				print("  previous type found: "..pattern, code:sub(posStart-20, posEnd+20))
				table.remove(type_words, i) -- was already in target ffi.cdef file
			else
				if not_found_type[type_str] then			
					print("    not_found_type: '"..type_str.."'")
					table.remove(type_words, i)
					table.insert(basic_type, type_str) -- add to basic types
					break
				else
					not_found_type[type_str] = 0
					for line in header:gmatch("[^\r\n]+") do
						local posStart,posEnd = line:find(pattern)
						if posStart then
							local def = line:sub(1, posStart - 1)
							repeat
								local posStart,posEnd = def:find(name_separator)
								if posStart then
									def = def:sub(posStart + 1)
								end
							until posStart == nil
							if not basic_type[def] then
								print("    type found: '"..line.."'")
								table.insert(type_words, def)
							end
							table.remove(type_words, i)
							table.insert(type_lines, 1, line) -- add to start
							not_found_type[type_str] = nil
							break -- break out of inner loop
						end
					end
				end
			end
		end
	end
	
	-- add new definitions to target ffi.cdef file 
	code = code.."\n--[[ "..sourcefile.." ]]"
	code = code.."\nffi.cdef[[\n\t"
	if #type_lines > 0 then
		code = code..table.concat(type_lines, "\n\t")
		code = code.."\n\t"
	end
	code = code..table.concat(function_lines, "\n\t")
	code = code.."\n]]\n"
	
	file = io.output(target_ffi_file)
	io.write(code)
	io.close()
	
	print()
	--print(code)
	print("created: "..target_ffi_file)
	
	basic_type = util.table_invert(basic_type)
	if basic_type_count ~= #basic_type then
		print("New basic types:")
		print(util.table_show(basic_type, "basic_type"))
	end
	
	if openResult then
	  os.execute("open "..target_ffi_file)
	end
	if openPrf then
	  os.execute("open "..prfFileName)
	end
end

print()
print(" -- ffi_def_create.lua end -- ")
print()

