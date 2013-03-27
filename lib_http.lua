-- lib_http.lua

-- dofile "lib_util.lua"
-- local ffi = require("ffi")
-- local C = ffi.C

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
