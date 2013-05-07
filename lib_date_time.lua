--
--  mgDateTime.lua
--
--  Author: Pasi Mankinen
--
module(..., package.seeall)

-- http://stackoverflow.com/questions/4460902/unix-time-to-humanreadable-date-and-time

local ma = require "lib_util"
local ma = require "ffi_def_osx"
local ffi = require 'ffi'
local C = ffi.C
-- local date = require "date"

local floor = math.floor
local modf = math.modf
local ceil = math.ceil
local abs = math.abs
local round = ma.round

print("C.time(nil) = "..tonumber(C.time(nil)))


local function dateToNum(year, month, day) -- ymdToJulian(year, month, day)
  local a = floor((14 - month)/12)
  local y = year + 4800 - a
  local m = month + 12*a - 3
  return day + floor((153*m + 2)/5) + 365*y + floor(y/4) - floor(y/100) + floor(y/400) - 32045
end

local function numToDate(num) -- julianToYmd(julian)
	local int,_ = modf(num) -- days are int part of number
  local a = int + 32044
  local b = floor((4*a + 3)/146097)
  local c = a - floor((146097*b)/4)
  local d = floor((4*c + 3)/1461)
  local e = c - floor((1461*d)/4)
  local m = floor((5*e + 2)/153)
  local day = e - floor((153*m + 2)/5) + 1
  local month = m + 3 - 12*floor(m/10)
  local year = 100*b + d - 4800 + floor(m/10)
  return year, month, day
end

function numToWeek(num)
  local d4 = (num + 31741 - (num % 7)) % 146097 % 36524 % 1461
  local L = floor(d4 / 1460)
  local d1 = ((d4 - L) % 365) + L
  local numberOfWeek = floor(d1 / 7) + 1
  return numberOfWeek
end

function dayDifference(time_start, time_end)
	time_start = modf(time_start)
	time_end = modf(time_end)
	return time_end - time_start
end

function daysBetween(time_start, time_end)
	time_start = modf(time_start)
	time_end = modf(time_end)
	return abs(time_end - time_start)
end

function secondsBetween(time_start, time_end)
    return C.difftime(time_start, time_end)
end

function secondsAdd(time, seconds)
    return time + seconds/86400
end

function currentDate()
	--return date(false)
	local d = os.date("*t")
	return dateToNum(d.year, d.month, d.day)
end

function currentTime()
	local d = os.date("*t")
	return timeToNum(d.hour, d.min, d.sec)
end

function currentDateTime()
	local d = os.date("*t")
	return dateToNum(d.year, d.month, d.day) + timeToNum(d.hour, d.min, d.sec)
end

function ymdAdd(num, y, m ,d) -- add format and default format
	local int,decim = modf(num)
	local year,month,day = numToDate(int)
	year = year + y
	month = month + m
	day = day + d
	return dateToNum(year, month, day) + decim
end

function daysAdd(num, d) -- add format and default format
	local int,decim = modf(num)
	local year,month,day = numToDate(int)
	day = day + d
	return dateToNum(year, month, day) + decim
end

function numToMgReal(num)
	return num - 2451545 -- num - dateToNum(2000, 1, 1) == num - 2451545
end

function removeTimePart(num)
	local int = modf(num)
	return int -- days are int part of number
end

function removeTimePart(num)
	local int = modf(num)
	return int -- days are int part of number
end

function removeDatePart(num)
	local _,decim = modf(num)
	return decim -- time is in decimal part of number
end

function isMidnight(num)
	local _,decim = modf(num)
	if decim == 0 then
		return true
	end
	return false
end

function toSecondsFromDayStart(num, seconds)
	local time = removeTimePart(num)
	time = secondsAdd(time, seconds)
	return time
end

function toSecondsFromDayEnd(num, seconds)
	local time = removeTimePart(num)
	time = daysAdd(time, 1)
	time = secondsAdd(time, seconds)
	return time
end

function timeToNum(hours, minutes, seconds)
	return hours/24 + minutes/1440 + seconds/86400 -- turn time to decimal part of number
	-- 1440 = 24*60
	-- 86400 = 24*60*60
end

function toHours(r, decimals) -- 6 decimals seems to be ok?
	if decimals then
		return round(r * 24, decimals)
	end
	return r * 24
end

function toMinutes(r, decimals)
	if decimals then
		return round(r * 1440, decimals)
	end
	return r * 1440
end

function toSeconds(r, decimals)
	if decimals then
		return round(r * 86400, decimals)
	end
	return r * 86400
end

function toTime(num)
	local _,decim = modf(num)
	local hours = floor(decim * 24) -- now hours is integer, we need always int
	local minutes = floor(decim * 1440) - (hours * 60)
	local seconds = floor(decim * 86400) - (hours * 3600) - (minutes * 60)
	return hours,minutes,seconds
end

function hoursToNum(hours)
	return hours/24
end

function minutesToNum(minutes)
	return minutes/1440 --/60/24
end

function secondsToNum(seconds)
	return seconds/86400  --86400 = seconds/60/24/60
end

function hoursToMillisec(hour)
	return hour * 3600000 -- 1000 ms * 60*60 secs in hour
end

function toDateString(num, isEndDate) -- add format and default format
	local year,month,day = numToDate(num)
	if isEndDate then
		local _,decim = modf(num)
		if decim == 0 then day = day - 1 end
	end
	if month < 10 then month = "0"..month end
	if day < 10 then day = "0"..day end
	return year.."-"..month.."-"..day
end

function toTimeString(num, isEndDate)
	local _,decim = modf(num)
	if isEndDate and decim == 0 then
		return "24:00:00"
	end
	local hours, minutes, seconds = toTime(num)
	if hours < 10 then hours = "0"..hours end
	if minutes < 10 then minutes = "0"..minutes end
	if seconds < 10 then seconds = "0"..seconds end
	return hours..":"..minutes..":"..seconds
end

function toString(num, isEndDate)
	return toDateString(num, isEndDate).." "..toTimeString(num, isEndDate)
end

function dateParse(txtDate)
	if not txtDate then
		ma.err("txtDate is nil")
		return 0
	end
  local year = tonumber(txtDate:sub(1, 4))
  local month = tonumber(txtDate:sub(6, 7))
  local day = tonumber(txtDate:sub(9, 10))
	if year == 0 and month == 0 and day == 0 then
		--year = 1970
		--month = 1
		--day = 1
		return 0
	end
  return dateToNum(year, month, day)
end

function timeParse(secs)
  local parts = input.match("(d+)")
  if parts[0] then
    local hours = parseInt(parts[0].substr(0, 2), 10)
  else
    local hours = parseInt(input.substr(0, 2), 10)
  end
  if parts[1] then
    local mins = parseInt(parts[1], 10)
  else
    if input.length <= 2 then
      local mins = 0
    else
      local mins = parseInt(input.substr(2, 2), 10)
    end
  end
  if parts[2] then
    local secs = parseInt(parts[2], 10)
  else
    if input.length <= 4 then
      local secs = 0
    else
      local secs = parseInt(input.substr(4, 2), 10)
    end
  end
  local timeSecs = secs + (mins * 60) + (hours * 60 * 60)
  local time = new(Date(timeSecs * 1000))
  return time
end


function test()
	print()
	print("-- mgDateTime TEST start --")
	print()

	print(dateToNum(2000, 1, 1))
	print(dateToNum(2000, 1, 2))
	print(dateToNum(2010, 1, 1))
	print(dateToNum(2010, 1, 1) - dateToNum(2000, 1, 1))

	local hours, minutes, seconds
	local hours2, minutes2, seconds2

	hours = 12
	minutes = 2
	seconds = 1
	local n = timeToNum(hours, minutes, seconds)
	print("n = timeToNum(hours, minutes, seconds)", n.."=", hours, minutes, seconds)
	hours2, minutes2, seconds2 = toTime(n)
	print("toTime(n)=", hours2, minutes2, seconds2)

	print()
	print("-- mgDateTime TEST end --")
	print()
end
--test()
