--  luajit_speed_test.lua
local codeout = ""
local linecount = 20000
local strlen = 100
local line = string.rep("a", strlen).."\n"
local code = string.rep(line, 20000)
local i = 0
local timeUsed = os.time()
for line in code:gmatch("[^\r\n]+") do
  i = i + 1
--for i=1,linecount do
  if i%1000 == 0 or i == 1 then
    print("  ... line: "..i.." / "..linecount)
  end
  codeout = codeout..line.."\n"
end
timeUsed = os.time() - timeUsed
if jit then
  print(jit.version..": "..timeUsed.." seconds")
else
  print(_VERSION..": "..timeUsed.." seconds")
end
print(" -- luajit_speed_test.lua end -- ")
print()