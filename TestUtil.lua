print()
print("-- TestUtil.lua start -- ")
print()

dofile "lib_util.lua"
local arg = {...}
local ffi = require("ffi")

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
function nanosleep(sec, nanosec)
function processorCoreCount()
function directory_files(dirpath)

function comma_value(amount, comma)
function round(val, decimal)
function format_num(amount, decimal, comma, prefix, neg_prefix)
function table.show(t, name, indent)
]]

local str_c = cstr("Processor core count (configured, online): ")
local count,online = processorCoreCount()
print( ffi.string(str_c)..count..", "..online )

local timer = seconds()
io.write("press any key to start: ")
local key = waitKeyPressed()
print()
io.write("start: "..timer)
nanosleep(0, 200)
timer = seconds(timer)
print(", time used: "..timer)
print()
print("key pressed: '"..key.."'")
print("sleep(2*1000)")
sleep(2*1000)
print("nanosleep(1, 999999999)")
nanosleep(1, 999999991) --2*1000*1000)

print("Calling cerr(), will break here, is OK.")
print()
cerr() -- will break here

print("-- TestUtil.lua end -- ")
print()
print("Calling cerr(), will break here, is OK.")
print()
cerr() -- will break here

print("-- TestUtil.lua end -- ")
print()
