--  ffi_def_create_headers.lua

print()
print(" -- ffi_def_create_headers.lua start -- ")
if jit then
	print(jit.version)
else
	print(_VERSION)
end
print()

local arg = {...}
local noParse = false
if arg[1] then
	noParse = arg[1] == "n"
end

local util = require "lib_util"
local osname
if true then -- keep ffi valid only inside if to make ZeroBrane debugger work
	local ffi = require("ffi")
	osname = string.lower(ffi.os)
end
osname = "windows" -- for running in osx

local timeUsed = util.seconds()

-- http://gcc.gnu.org/onlinedocs/gfortran/Preprocessing-Options.html
local addToWindowsInclude = '#define _WIN32_WINNT 0x0602 // inserted header for Lua, Windows 8 == 0x0602\n#define WINVER _WIN32_WINNT\n'
addToWindowsInclude = addToWindowsInclude..'#define WIN32_LEAN_AND_MEAN\n#pragma comment (lib, "Ws2_32.lib")\n'
-- use ONLY '\n', not '\r' in addToWindowsInclude


local target_path = "c_include/"..osname.."/"
local useCccIncludeDir = true -- comment sourcepaths to match this
local sourcepaths = {
	--["windows"] = "C:/mingw64/mingw/include/",
	["windows"] = "C:/Program Files (x86)/Microsoft SDKs/Windows/v7.0A/Include/", 
	["windows2"] = "C:/Program Files (x86)/Microsoft Visual Studio 10.0/VC/include/",
	["osx"] = "/usr/include/",
	--["osx2"] = "",
	["linux"] = "/usr/include/",
	["linux2"] = "/usr/include/i386-linux-gnu/"
}

sourcefiles = {
	["windows"] = [[
#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
]],

	["osx"] = [[
#include <sys/types.h>
]],

	["linux"] = [[
#include <sys/types.h>
]],
}

local prfFileName = "ffi_def_create_headers_prf.lua"
if util.file_exists(prfFileName) then
	dofile(prfFileName)
end

local sourcepath = sourcepaths[osname]
local sourcepath2 = sourcepaths[osname.."2"]
local sourcefile = sourcefiles[osname]
sourcefile = sourcefile:gsub("#include <", "")
sourcefile = sourcefile:gsub(">", "")

local copy_commad = "cp "
local preprocessor_commad = "gcc -E -P -D".." "  -- -dD  -C = leave comments
if util.isWin then
	copy_commad = "copy "
	--preprocessor_commad = "CL /EP" --   /showIncludes /FI /D_WIN32_WINNT=0x0601
	preprocessor_commad = "gcc.exe -E -dD -C"
	if useCccIncludeDir then
		preprocessor_commad = preprocessor_commad.." -I "..'"'..sourcepath..'"'
		if sourcepath2 then
			preprocessor_commad = preprocessor_commad.." -I "..'"'..sourcepath2..'"'
		end
	end
	preprocessor_commad = preprocessor_commad.." " 
	--  -dD -dN -dI -D _WIN32_WINNT=0x0602
end



local define_length = #("#define ")
local define_pos = define_length + 1

local function defineLine(line)
	
	local comment
	local s,e =  line:find("%/%/")
	if not s then
		s,e =  line:find("%/%*")
	end
	if s then
		comment = line:sub(s)
		comment = "  "..comment:match("^%s*(.-)%s*$") -- remove whitespaces
		line = line:sub(1, s - 1)
	end
	
	local value = line:sub(define_pos)
	local s,e = value:find(" ")
	if not e then
		value = ""
	else	
		value = value:sub(e + 1)
	end
	if value == "" then
		line = ""
	else
		local name = line:sub(define_pos, define_pos + s - 2)
		name = name:match("^%s*(.-)%s*$") -- remove leading and trailing whitespace
		value = value:match("^%s*(.-)%s*$") -- remove leading and trailing whitespace
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
    if comment then
      line = line..comment
    end
	end
	return line
end
				
local filecount = 0
local parsecount = 0
local define_found = false
for file in sourcefile:gmatch("[^\r\n]+") do
	if file ~= "" and not util.string_starts(file, "//") then -- not empty and not commented lines
	
		local destfile = file:gsub("/", "_")
		if util.isWin then
			file= file:gsub("/", "\\")
			sourcepath = sourcepath:gsub("/", "\\")
			if sourcepath2 then
				sourcepath2 = sourcepath2:gsub("/", "\\")
			end
		end
			
		local copypath = target_path.."original/"..destfile
		if not util.file_exists(copypath) then
			local cmd
			if util.string_starts(file, "/") then
				cmd = copy_commad..'"'..file..'" "'..util.currentPath()..copypath..'"'
			else
				cmd = copy_commad..'"'..sourcepath..file..'" "'..copypath..'"'
				if not util.file_exists(sourcepath..file) then
					if sourcepath2 then
						cmd = copy_commad..'"'..sourcepath2..file..'" "'..copypath..'"'
					end
				end
			end
			if util.isWin then
				cmd = cmd:gsub("/", "\\")
			end
			print(cmd)
			os.execute(cmd)
			if addToWindowsInclude then
				print("  ... add prefix to file: "..copypath)
				local code = util.readFile(copypath)
				code = addToWindowsInclude..code
				util.writeFile(copypath, code)
			end
		end
		
		local destpath = target_path..destfile
		if not util.file_exists(destpath) then
			local cmd = preprocessor_commad..copypath.." > "..destpath
			print(cmd)
			os.execute(cmd)
			filecount = filecount + 1
		end
		
		if not util.file_exists(destpath) then
			print("*** file creation failed: "..destpath)
		elseif not noParse then
			parsecount = parsecount + 1
			local filecomment = "\n\n// *** "..parsecount..". "..file.." ***"
			
			local code = util.readFile(destpath)
			print(destpath)
			local crlfLen = #code
			code = code:gsub("\r\n", "\n") 
			code = code:gsub("\n\n", "\n")
			local _,linecount = code:gsub("\n", ".")
			print("  ... empty lines removed: "..util.format_num(crlfLen - #code, 0)..", size: "..util.fileSize(#code, 2))
			_ = nil -- release memory
			collectgarbage()
			print("  ... linecount: "..util.format_num(linecount, 0))
				
			local codeout = {}
			local i = 0
			for line in code:gmatch("[^\r\n]+") do
				i = i + 1
				if i%5000 == 0 then
					print("  ... line: "..util.format_num(i, 0).." / "..util.format_num(linecount, 0))
				end
				local is_define = false
				--line:sub(1, define_length)
				if line:find("^#define ") then
					is_define = true
					define_found = true
					line = defineLine(line)
				end
				if line ~= "" and not line:find("^%s+$") and line ~= "\n" and line:find("#undef") ~= 1 then
					codeout[#codeout+1] = line.."\n"
				end
			end
			
			local definecount = 0
			if not define_found then
				-- read #define's from original header
				print("  ... creating defines from original header...")
				local definecode = util.readFile(destpath)
				if not definecode:find(" --- defines\n\n") then
					definecode = util.readFile(copypath)
					local defineout = {}
					local i = 0
					for line in definecode:gmatch("[^\r\n]+") do
						i = i + 1
						if i%5000 == 0 then
							print("  ... line: "..util.format_num(i, 0).." / "..util.format_num(linecount, 0))
						end
						if line:find("^#define ") then
							line = defineLine(line)
							if line ~= "" then
								definecount = definecount +1
								defineout[#defineout+1] = line.."\n"
							end
						end
					end
					codeout[#codeout+1] = filecomment.." --- defines\n\n"..table.concat(defineout)
				end
			end
			define_found = false
			
			codeout = table.concat(codeout)
			util.appendFile(target_path.."ffi_types.h", filecomment.."\n"..codeout)
			print("  ... final size: "..util.fileSize(#codeout, 2)..", defines: "..definecount)
			print()
			util.writeFile(destpath, codeout)
		end
		
	end
end

if codeout ~= "" then
	-- add "ffi_types.h" to written filecount
	filecount = filecount + 1
end

timeUsed = util.seconds(timeUsed)
print()
print("created: "..(filecount).." files in "..util.format_num(timeUsed, 3).." seconds")

print()
if jit then
	print(jit.version)
else
	print(_VERSION)
end
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
