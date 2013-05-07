-- ffi_def_osx.lua
module(..., package.seeall)

local ffi = require "ffi"
-- generated code start --

--[[ lib_date_time.lua ]]
ffi.cdef[[
	typedef long __darwin_time_t;
	typedef __darwin_time_t time_t;
	double difftime(time_t, time_t);
	time_t time(time_t *);
]]
