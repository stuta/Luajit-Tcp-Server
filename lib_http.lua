-- lib_http.lua
module(..., package.seeall)

-- require "lib_util"
-- local ffi = require("ffi")
-- local C = ffi.C

-- from Lua mailing list:

-- parse headers
local name,value=string.match(line,"(.-):%s*(.-)$")

-- I've been using the following code to parse the headers out of an Rackspace API response for 18 months now. self._response is a string containing the whole http response.

local headerString = self._response:match("[%g ]+\r\n([%g \r\n]+)\r\n\r\n") .. "\r\n"
if headerString == nil then error("Couldn't find header") end
for k, v in headerString:gmatch("([%a%d%-]+): ([%g ]+)\r\n") do
	if k == nil then error("Unparseable Header") end
	headers[k] = v
end
return headers

local name,value=string.match(line,"(.-):%s*(.-)$")

--[[
 Actually, that may fail.  According to RFC-2616, section 4.2:

	Header fields can be extended over multiple lines by preceding each
	extra line with at least one SP or HT. 

 So this is a valid header:

User-Agent: The Wizbang Frobulator 1.2p333
	(this is Microsoft Windows compatible.  No, really!)
	(It also conforms to the Gecko layout engine)
	(and WebKit)

Here's the code I use to parse headers [1]:
]]
local lpeg = require "lpeg"

local P  = lpeg.P
local S  = lpeg.S
local C  = lpeg.C
local Cf = lpeg.Cf
local Ct = lpeg.Ct
local Cg = lpeg.Cg

-- -------------------------------------------------------
-- This function will collapse repeated headers into a table,
-- but otherwise, the value will be a string
-- --------------------------------------------------------

local function doset(t,i,v)
 if t[i] == nil then
   t[i] = v
 elseif type(t[i]) == 'table' then
   t[i][#t[i]+1] = v
 else
   t[i] = { t[i] , v }
 end
 return t
end

local crlf    = P"\r"^-1 * P"\n"
local lwsp    = S" \t"
local eoh     = (crlf * #crlf) + (crlf - (crlf^-1 * lwsp))
local lws     = (crlf^-1 * lwsp)^0
local value   = C((P(1) - eoh)^0) / function(v)
                                     return v:gsub("[%s%c]+"," ")
                                   end
local name    = C((P(1) - (P":" + crlf + lwsp))^1)
local header  = Cg(name * ":" * lws * value * eoh)
headers       = Cf(Ct("") * header^1,doset) * crlf

--[[Given the following headers:

Host: www.example.net
User-Agent: The Wizbang Frobulator 1.2p333
	(this is Microsoft Windows compatible.  No, really!)
	(It also conforms to the Gecko layout engine)
	(and WebKit)
Accept: text/html;q=.9, 
	text/plain;q=.5,
	text/*;q=0
Accept-Charset: iso-8859-5, unicode-1-1;q=0.8

"headers:match(text)" will return a table:

{
 ['User-Agent']     = "The Wizbang Frobulator 1.2p333 (this is Microsoft Windows compatible.  No, really!)  (It also conforms to the Gecko layout engine) (and WebKit)",
 ['Accept']         = "text/html;q=.9, text/plain;q=.5, text/*;q=0",
 ['Accept-Charset'] = "iso-8859-5, unicode-1-1;q=0.8
}

 -spc (man, that real world---it's sooooo messy)

[1]	If I'm parsing email, I'll use:
	https://github.com/spc476/LPeg-Parsers/blob/master/email.lua

]]


--[[
I think you are saying that this:

local _, _, name, value = string.find(line, "^([^:]+)%s*:%s*(.+)")

is too hard for your typical REXX programmer to figure out - maybe 
that's true. The pattern will be generally useful, and they don't need 
to figure it out every place they need to parse an HTTP Header string, 
so I would suggest wrapping if like this (make foo some helpful library 
name)

foo.regex = { ["httpHeader'] = "^([^:]+)%s*:%s*(.+)"
            , ....
            , ....
            }

local httpHeader = foo.regex.httpHeader

local _, _, name, value = string.find(line, httpHeader )

or if you want to skip the local:

local _, _, name, value = string.find(line, foo.regex.httpHeader )

It's a bit of work to gather up the common regexen you need, but it will 
help your feeble minded REXXers do their job without taxing their 
remaining brain cells.
]]

-- https://github.com/JohnAbrahamsen/nonsence-ng/blob/experimental/tests/nonsence_tcpserver_test.lua

local parse_headers = function(raw_headers)
	local HTTPHeader = raw_headers
	if HTTPHeader then
		-- Fetch HTTP Method.
		local method, uri = HTTPHeader:match("([%a*%-*]+)%s+(.-)%s")
		-- Fetch all header values by key and value
		local request_header_table = {}
		for key, value  in HTTPHeader:gmatch("([%a*%-*]+):%s?(.-)[\r?\n]+") do
			request_header_table[key] = value
		end
	return { method = method, uri = uri, extras = request_header_table }
	end
end

function server:handle_stream(stream, address)
	function close()
		if #io_loop:list_callbacks() > 20 then
			print(#io_loop:list_callbacks())
		end
		stream:close()
	end
	function headers(data)
		local requestheaders = parse_headers(data)
		stream:write("HTTP/1.1 200 OK\r" .. "Content-Type: text/html; charset=UTF-8\r" .. "Content-Length: 16\r\n\r\n" .. "TCPServer works!", close)
	end
	stream:read_until("\r\n\r\n", headers)
end
