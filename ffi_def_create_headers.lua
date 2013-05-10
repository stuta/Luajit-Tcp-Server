--  ffi_def_create_headers.lua

print()
print(" -- ffi_def_create_headers.lua start -- ")
print()

local arg = {...}

local util = require "lib_util"
local osname
if true then -- keep ffi valid only inside if to make ZeroBrane debugger work
	local ffi = require("ffi")
	osname = string.lower(ffi.os)
end

local timeUsed = util.seconds()

-- http://gcc.gnu.org/onlinedocs/gfortran/Preprocessing-Options.html
local preprocessor_commad = "gcc -E -P -dD "  --  -C = leave comments
local copy_commad = "cp "
local target_path = "c_include/"..osname.."/"
local sourcepaths = {
	["windows"] = "/usr/include/",
	["osx"] = "/usr/include/",
	["linux"] = "/usr/include/",
}

sourcefiles = {
	["windows"] = [[
#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
]],

	["osx"] = [[
#include <sys/types.h>
// /Users/pasi/asennetut_paketit/Lua/lua-5.1.5/src/install_bin/include/lua.h
]],

	["linux"] = [[
#include <sys/types.h>
]],
}

local prfFileName = "ffi_def_create_headers_prf.txt"
if util.file_exists(prfFileName) then
	dofile "ffi_def_create_headers_prf.txt"
end

local sourcepath = sourcepaths[osname]
local sourcefile = sourcefiles[osname]
sourcefile = sourcefile:gsub("#include <", "")
sourcefile = sourcefile:gsub(">", "")

local define_pos = #("#define ") + 1
local filecount = 0
local line_all = 0
local code_define = {}
local codeall = ""
for file in sourcefile:gmatch("[^\r\n]+") do
	if file ~= "" and not util.string_starts(file, "//") then -- not empty and not commented lines
		local destfile = util.last_part(file, "/")
		if destfile == "" then destfile = file end
		
		local copypath = target_path.."original/"..destfile
		if not util.file_exists(copypath) then
			local cmd
			if util.string_starts(file, "/") then
				cmd = copy_commad..file.." "..copypath
			else
				cmd = copy_commad..sourcepath..file.." "..copypath
			end
			os.execute(cmd)
		end
		
		local destpath = target_path..destfile
		local cmd = preprocessor_commad..copypath.." > "..destpath
		print(cmd)
		os.execute(cmd)
		
		if not util.file_exists(destpath) then
			print("*** file creation failed: "..destpath)
		else
			filecount = filecount + 1
			local filecomment = "\n\n// *** "..filecount..". "..file.." ***\n"
			codeall = codeall..filecomment
			
			io.input(destpath)
			local code = io.read("*all")
			io.input():close()
			--code = code:gsub("(\n/%*).-(%*/)", "\n\n") -- leave inline comments, delete blocks
			--code = code:gsub("\n\n", "")
			local codeout = ""
			for line in code:gmatch("[^\r\n]+") do
				local is_define = false
				if util.string_starts(line, "#define ") then
					is_define = true
					line = line:sub(define_pos)
					local s,e = line:find(" ")
					local value = line:sub(e + 1)
					if value == "" then
						line = ""
					else
						local name = line:sub(1, s - 1)
						if value:match('".*%"$') then
							line = "static const char "..name.." = "..value..";"
						elseif value:match(".*%dL$") then
							line = "static const long "..name.." = "..value..";"
						elseif value:match(".*%dLL$") then
							line = "static const long long "..name.." = "..value..";"
						elseif value:match(".*%dF$") then
							line = "static const double "..name.." = "..value..";" -- float
						elseif value:match(".*%dDF$") then
							line = "static const double "..name.." = "..value..";"
						elseif value:match(".*%dDD$") then
							line = "static const double "..name.." = "..value..";"
						elseif value:match(".*%dDL$") then
							line = "static const long double "..name.." = "..value..";"
						elseif value:match("%d%.%d") then
							line = "static const double "..name.." = "..value..";"
						else
							line = "static const int "..name.." = "..value..";"
						end
					end
				end
				
				if line ~= "" then
					codeout = codeout..line.."\n"
					if is_define then
						if not code_define[line] then
							line_all = line_all + 1
							code_define[line] = line_all
							codeall = codeall..line.."\n"
						end
					else
						codeall = codeall..line.."\n"
					end
				end
			end
			file = io.output(destpath)
			io.write(codeout)
			io.output():close()
		end
	end
end

--code_define = util.table_invert(code_define)
--codeall = table.concat(code_define, "\n")
io.output(target_path.."ffi_types.h")
io.write(codeall)
io.output():close()

timeUsed = util.seconds(timeUsed)
print()
print("created: "..(filecount + 1).." files in "..util.format_num(timeUsed, 3).." seconds")

print()
print(" -- ffi_def_create_headers.lua end -- ")
print()


--[[
32-bit: Single (binary32), decimal32
64-bit: Double (binary64), decimal64
128-bit: Quadruple (binary128), decimal128

_Decimal32 DF
_Decimal64 DD
_Decimal128 DL
long L
long long LL
char "
]]
