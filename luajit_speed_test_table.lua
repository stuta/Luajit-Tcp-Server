--  luajit_speed_test.lua
local codeout = {}
local linecount = 20000
local strlen = 100
local line = string.rep("a", strlen).."\n"
local code = string.rep(line, 20000)
local i = 0
local timeUsed = os.clock()
for line in code:gmatch("[^\r\n]+") do
  i = i + 1
--for i=1,linecount do
  if i%10000 == 0 or i == 1 then
    print("  ... line: "..i.." / "..linecount)
  end
  table.insert(codeout, line.."\n")
end
local out_txt = table.concat(codeout)
timeUsed = os.clock() - timeUsed
if jit then
  print(jit.version..": "..timeUsed.." seconds, length: "..#out_txt.." bytes")
else
  print(_VERSION..": "..timeUsed.." seconds, length: "..#out_txt.." bytes")
end
print(" -- luajit_speed_test.lua end -- ")
print()