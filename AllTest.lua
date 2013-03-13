--  AllTest.lua

print()
print(" -- AllTest.lua start -- ")
print(" needs LuaFileSystem ")

local arg = {...}
local lfs = require "lfs"

for file in lfs.dir[[./]] do
    if lfs.attributes(file, "mode") == "file" then
    	if file ~= "AllTest.lua" and  string.find(file, "Test.lua", 1, true) then
    		io.write(" **********  file: "..file, ", press 's' tos skip and 'q' to quit: ")
    		local ans = string.lower(io.read("*line"))
				if ans == "q" then os.exit() end
				if ans ~= "s" then
    			print(" ********** running file: "..file)
    			os.execute("luajit "..file)
    			print(" ********** end running file: "..file)
    		end
    		print()
    	end
    end
end

print()
print(" -- AllTest.lua end -- ")
print()

