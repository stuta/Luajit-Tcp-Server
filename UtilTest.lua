print()
print("-- UtilTest.lua start -- ")
print()

local arg = {...}
dofile "ffi_def_util.lua"

--[[
function cstr(str)
function cerr()
function getPointer(cdata)
function createAddressVariable(cdata)
function createBufferVariable(datalen)
function getOffsetPointer(cdata, offset)
function toHexString(num)
function waitKeyPressed() 
function yield())
function nanosleep(nanosec)

function comma_value(amount, comma)
function round(val, decimal)
function format_num(amount, decimal, comma, prefix, neg_prefix)
function table.show(t, name, indent)
]]
local str = cstr("test c str")

print("Calling cerr(), will break here, is OK.")
cerr() -- will break here

print("-- UtilTest.lua end -- ")
print()
