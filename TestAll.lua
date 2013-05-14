--  AllTest.lua

print()
print(" -- TestAll.lua start -- ")
-- print(" -- You MUST have linked osx/linux luajit to 'lj', see jl.sh -- ")

local arg = {...}
local util = require("lib_util")
local ffi = require("ffi")
local C = ffi.C

local dir = util.directory_files("")
for i=1,#dir do
	local file=dir[i]
	if file ~= "TestAll.lua" and  string.find(file, "Test%a*.lua") then
		io.write(" **********  file: "..file, ", press 's' to skip and 'q' to quit: ")
		local ans = string.lower(io.read("*line"))
		if ans == "q" then os.exit() end
		if ans ~= "s" then
			print(" ********** running file: "..file)
			os.execute("lj "..file)
			print(" ********** end running file: "..file)
		end
		print()
		print()
	end
end

print()
print(" -- TestAll.lua end -- ")
print()

