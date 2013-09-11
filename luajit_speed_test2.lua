--  luajit_speed_test2.lua

print()
print(" -- luajit_speed_test2.lua start -- ")
print()

local arg = {...}
--local util = require "lib_util"

local do_match = false
local do_concat = false
if arg[1] then
	do_match = arg[1]:find("[mM]") ~= nil -- contains "M" or "m"
	do_concat = arg[1]:find("[cC]") ~= nil
end
print("  do_match : "..tostring(do_match))
print("  do_concat: "..tostring(do_concat))

local codeout = ""
local linecount = 20000
local strlen = 100
local line = string.rep("a", strlen).."\n"
local code = 	string.rep(line, 20000)
local i = 0
local timeUsed = os.time()
for line in code:gmatch("[^\r\n]+") do
	i = i + 1
--for i=1,linecount do
	if i%1000 == 0 or i == 1 then
		print("  ... line: "..i.." / "..linecount)
	end
	if do_match then
		local s,e = line:match("a(.-)a\n")
		if s then
			s = e + 1
		end
	end
	if do_concat then
		codeout = codeout..line.."\n"
	end
end
timeUsed = os.time() - timeUsed
print("created: "..linecount.." lines in "..timeUsed.." seconds, length: "..#codeout.." bytes")


if jit then
	print(jit.version)
else
	print(_VERSION)
end
print("  do_match : "..tostring(do_match))
print("  do_concat: "..tostring(do_concat))
print(" -- luajit_speed_test2.lua end -- ")
print()

