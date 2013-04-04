print()
print("-- TestUtil.lua start -- ")
print()

local util = require "lib_util"
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
function table_show(t, name, indent)
]]

local str_c = util.cstr("Processor core count (configured, online): ")
local count,online = util.processorCoreCount()
print( ffi.string(str_c)..count..", "..online )

local timer = util.seconds()
io.write("press any key to start: ")
local key = util.waitKeyPressed()
print()
io.write("start: "..timer)
util.nanosleep(0, 200)
timer = util.seconds(timer)
print(", time used: "..timer)
print()
print("key pressed: '"..key.."'")
print("sleep(1*1000)")
util.sleep(1*1000)
print("nanosleep(1, 999999999)")
util.nanosleep(1, 999999991) --2*1000*1000)

print()
print("-- TestUtil.lua end --")
print()
print("Calling cerr(), will break here, is OK.")
print()
util.cerr() -- will break here
