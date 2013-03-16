--  AllTest.lua

print()
print(" -- TestAll.lua start -- ")
print(" -- You MUST have linked osx/linux luajit to 'lj', see jl.sh -- ")

dofile "lib_util.lua"
local arg = {...}
local ffi = require("ffi")
local C = ffi.C

local dir = directory_files("")
for _,file in ipairs(dir) do
	if file ~= "TestAll.lua" and  string.find(file, "Test%a*.lua") then
		io.write(" **********  file: "..file, ", press 's' tos skip and 'q' to quit: ")
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

