--  TestAddrinfo.lua
print()
print(" -- TestAddrinfo.lua start -- ")
print()

local arg = {...}
local ffi = require("ffi")
local C = ffi.C
local bit = require("bit")

ffi.cdef[[
	// Address families. (socket.h)
	static const int AF_UNSPEC	= 0;		/* unspecified */
	static const int AF_UNIX		= 1;		/* local to host (pipes) */
	static const int AF_INET		= 2;		/* internetwork: UDP, TCP, etc. */

	// Protocols (RFC 1700)
	static const int	 IPPROTO_TCP = 6;		/* tcp */
	static const int	 IPPROTO_UDP = 17;		/* user datagram protocol */

	// Types
	static const int	 SOCK_STREAM = 1	;	/* stream socket */
	typedef unsigned char		__uint8_t;
	typedef	unsigned short	__uint16_t;
	typedef unsigned int		__uint32_t;

	typedef __uint32_t socklen_t;
	typedef __uint16_t in_port_t;
	typedef __uint32_t in_addr_t;
	typedef __uint8_t		sa_family_t;

	// Basic system type definitions, taken from the BSD file sys/types.h.
	typedef unsigned char   u_char;
	typedef unsigned short  u_short;
	typedef unsigned int    u_int;
	typedef unsigned long   u_long;

	// Constants for getaddrinfo()
	static const int AI_PASSIVE                  =0x00000001;
		// get address to use bind(), Socket address will be used in bind() call
	static const int AI_CANONNAME                =0x00000002;
		//fill ai_canonname, Return canonical name in first ai_canonname
	static const int AI_NUMERICHOST              =0x00000004;
		// prevent host name resolution, Nodename must be a numeric address string
	static const int AI_NUMERICSERV              =0x00000008;
		// prevent service name resolution, Servicename must be a numeric port number

	static const int AI_ALL		= 0x00000100; /* IPv6 and IPv4-mapped (with AI_V4MAPPED) */
	static const int AI_V4MAPPED_CFG	= 0x00000200; /* accept IPv4-mapped if kernel supports */
	static const int AI_ADDRCONFIG	= 0x00000400; /* only if any address is assigned */
	static const int AI_V4MAPPED	= 0x00000800; /* accept IPv4-mapped IPv6 address */
		// special recommended flags for getipnodebyname
	static const int AI_DEFAULT	= (AI_V4MAPPED_CFG | AI_ADDRCONFIG);
	static const int AI_MASK = (AI_PASSIVE | AI_CANONNAME | AI_NUMERICHOST | AI_NUMERICSERV | AI_ADDRCONFIG);

	// Constants for getnameinfo()
	static const int NI_MAXHOST = 1025;
	static const int NI_MAXSERV = 32;

	// Flag values for getnameinfo()
	static const int NI_NOFQDN			= 0x00000001;
	static const int NI_NUMERICHOST	= 0x00000002;
	static const int NI_NAMEREQD		= 0x00000004;
	static const int NI_NUMERICSERV	= 0x00000008;
	static const int NI_DGRAM				= 0x00000010;
	static const int NI_WITHSCOPEID	= 0x00000020;

	struct in_addr {
		in_addr_t s_addr;
	};

	struct sockaddr {
		__uint8_t	sa_len;		/* total length */
		sa_family_t	sa_family;	/* [XSI] address family */
		char		sa_data[14];	/* [XSI] addr value (actually larger) */
	};

	// Socket address, internet style.
	struct sockaddr_in {
		uint8_t	sin_len;
		sa_family_t	sin_family;
		in_port_t	sin_port;
		struct	in_addr sin_addr;
		char		sin_zero[8];
	};

	struct addrinfo {
		int ai_flags;           /* input flags */
		int ai_family;          /* protocol family for socket */
		int ai_socktype;        /* socket type */
		int ai_protocol;        /* protocol for socket */
		socklen_t ai_addrlen;   /* length of socket-address */
		struct sockaddr *ai_addr; /* socket-address for socket */
		char *ai_canonname;     /* canonical name for service location */
		struct addrinfo *ai_next; /* pointer to next in list */
	 };

	int getaddrinfo(const char *hostname, const char *servname, const struct addrinfo *hints, struct addrinfo **res);
	void freeaddrinfo(struct addrinfo *ai);
	//int getaddrinfo(const char* nodename,const char* servname,const struct addrinfo* hints, **res);
	//void freeaddrinfo(PADDRINFOA pAddrInfo);

	int getnameinfo(const struct sockaddr *sa, socklen_t salen, char *host, socklen_t hostlen, char *serv, socklen_t servlen, int flags);

	const char* gai_strerror(int ecode);
	uint16_t htons(uint16_t hostshort);
	// Socket address conversions END

	int	socket(int domain, int type, int protocol);
	int	connect(int socket, const struct sockaddr *address, socklen_t address_len);
]]


local sock
if ffi.os == "Windows" then
	function MAKEWORD(low,high)
		return bit.bor(low , bit.lshift(high , 8))
	end
	ffi.cdef[[
		typedef unsigned short      WORD;
		typedef unsigned long       DWORD;
		typedef void*			          LPCVOID;
		typedef char*			          LPTSTR;
		typedef char*  							va_list;
		static const int 		FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000;
		static const int 		FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200;
		typedef uintptr_t		SOCKET;

		enum {
			WSADESCRIPTION_LEN =     256,
			WSASYS_STATUS_LEN  =     128,
		};
		typedef struct WSAData {
        WORD                wVersion;
        WORD                wHighVersion;
        char                szDescription[WSADESCRIPTION_LEN+1];
        char                szSystemStatus[WSASYS_STATUS_LEN+1];
        unsigned short      iMaxSockets;
        unsigned short      iMaxUdpDg;
        char *				lpVendorInfo;
		} WSADATA, * LPWSADATA;
		typedef struct WSAData64 {
			WORD                wVersion;
			WORD                wHighVersion;
			unsigned short      iMaxSockets;
			unsigned short      iMaxUdpDg;
			char *              lpVendorInfo;
			char                szDescription[WSADESCRIPTION_LEN+1];
			char                szSystemStatus[WSASYS_STATUS_LEN+1];
		} WSADATA64, *LPWSADATA64;
		DWORD FormatMessageA(
			DWORD dwFlags, // _In_
			LPCVOID lpSource, // _In_opt_
			DWORD dwMessageId, // _In_
			DWORD dwLanguageId, // _In_
			LPTSTR lpBuffer, // _Out_
			DWORD nSize, // _In_
			va_list *Arguments // _In_opt_
		);
		int WSACleanup(void);
		int WSAGetLastError(void);
		int closesocket(SOCKET s);
	]]

	local wsadata
	if ffi.abi("64bit") then
		ffi.cdef[[
			int WSAStartup(WORD wVersionRequested, LPWSADATA64 lpWSAData);
		]]
		wsadata = ffi.new( "WSADATA64[1]")
	else
		ffi.cdef[[
			int WSAStartup(WORD wVersionRequested, LPWSADATA lpWSAData);
		]]
		wsadata = ffi.new( "WSADATA[1]")
	end
	local wVersionRequested = MAKEWORD(2, 2)

	sock = ffi.load("ws2_32")
	kernel32 = ffi.load("kernel32") -- used in sock_errortext()

	local err = sock.WSAStartup(wVersionRequested, wsadata)
else
	ffi.cdef[[
		int	close(int fildes);
	]]
	sock = C
end

-- ===================
function cstr(str)
	local len = str:len()+1
  local typeStr = "uint8_t[" .. len .. "]"
  return ffi.new( typeStr, str )
end

function createBuffer(datalen)
	if datalen < 1 then
		error("datalen < 1 [createBuffer(datalen)]")
	end
	local var = ffi.new("int8_t[?]", datalen)
	local ptr = ffi.cast("int8_t *", var)
	return var,ptr
end
-- ===================
function sock_close(s)
	if ffi.os == "Windows" then
		sock.closesocket(s)
	else
		sock.close(s)
	end
end

function sock_errortext(err)
	if ffi.os == "Windows" then
		-- sock.WSAGetLastError() --err --ffi.string(ffi.C.gai_strerror(err))
		local buffer = ffi.new("char[512]")
		local flags = bit.bor(sock.FORMAT_MESSAGE_IGNORE_INSERTS, sock.FORMAT_MESSAGE_FROM_SYSTEM)
		kernel32.FormatMessageA(flags, nil, err, 0, buffer, ffi.sizeof(buffer), nil)
    return string.sub(ffi.string(buffer), 1, -3) -- remove last crlf
	else
		return ffi.string(sock.gai_strerror(err))
	end
end
-- ===================

--[[
	// Constants for getaddrinfo()
	static const int AI_PASSIVE                  =0x00000001;
		// get address to use bind(), Socket address will be used in bind() call
	static const int AI_CANONNAME                =0x00000002;
		//fill ai_canonname, Return canonical name in first ai_canonname
	static const int AI_NUMERICHOST              =0x00000004;
		// prevent host name resolution, Nodename must be a numeric address string
	static const int AI_NUMERICSERV              =0x00000008;
		// prevent service name resolution, Servicename must be a numeric port number

	static const int AI_ALL		= 0x00000100; /* IPv6 and IPv4-mapped (with AI_V4MAPPED) */
	static const int AI_V4MAPPED_CFG	= 0x00000200; /* accept IPv4-mapped if kernel supports */
	static const int AI_ADDRCONFIG	= 0x00000400; /* only if any address is assigned */
	static const int AI_V4MAPPED	= 0x00000800; /* accept IPv4-mapped IPv6 address */
		// special recommended flags for getipnodebyname
	static const int AI_DEFAULT	= (AI_V4MAPPED_CFG | AI_ADDRCONFIG);
	static const int AI_MASK = (AI_PASSIVE | AI_CANONNAME | AI_NUMERICHOST | AI_NUMERICSERV | AI_ADDRCONFIG);

	static const int AF_UNSPEC	= 0;		/* unspecified */
	static const int AF_UNIX		= 1;		/* local to host (pipes) */
	static const int AF_INET		= 2;		/* internetwork: UDP, TCP, etc. */
]]

--local res = ffi.new("struct addrinfo")
--local res0 = ffi.cast("struct addrinfo **", res)
local res0 = ffi.new("struct addrinfo*[1]")
local hints = ffi.new("struct addrinfo")

hints.ai_family = C.AF_INET
hints.ai_socktype = C.SOCK_STREAM
hints.ai_protocol = C.IPPROTO_TCP
hints.ai_flags = bit.bor(C.AI_CANONNAME)

local host = "www.apple.com" 	--cstr("www.apple.com") --"127.0.0.1" --"www.google.com"
local serv = "http" --cstr("http")
print("getaddrinfo flags = "..hints.ai_flags)
local err = sock.getaddrinfo(host, serv, hints, res0)
print("ai getaddrinfo err : "..err)
if err ~= 0 then
	print("  -- error text: '"..sock_errortext(err).."'")
	os.exit()
end

print("res0 :", res0, res0[0])

local cause = ""
local s = 0
local ai = res0[0]
local loop = 1
while loop > 0 do
	print()
	print(loop..".")
	print("ai ai_addrlen, 'ai_canonname'          : ", ai.ai_addrlen, "'"..ffi.string(ai.ai_canonname).."'")
	print("ai ai_addr, ai_next                    : ", ai.ai_addr, ai.ai_next)

	print("ai: flags, family, sa_len, sa_data     : ", ai.ai_flags, ai.ai_family, ai.ai_socktype, ai.ai_protocol, ai.ai_addrlen)
	print("ai: canonname, 'canonname'             : ", ai.ai_canonname, "'"..ffi.string(ai.ai_canonname).."'")
	local sa = ai.ai_addr
	print("sa: sa,      sa_len, sa_family, sa_data: ", sa, sa.sa_len ,sa.sa_family, sa.sa_data)

	if sa ~= nil then
		local bufflen, bufflen2 = C.NI_MAXHOST, C.NI_MAXSERV
		local _,hostname = createBuffer(bufflen)
		local _,servinfo = createBuffer(bufflen2)

		print()
		local flags = bit.bor(C.NI_NUMERICHOST, C.NI_NUMERICSERV)
		print("getnameinfo flags = "..flags)
		err = sock.getnameinfo(sa, ffi.sizeof(sa), hostname, bufflen, servinfo, bufflen2, flags)
		print("getnameinfo err         : "..err.." ("..sock_errortext(err)..")")
		if err == 0 then
			print("getnameinfo hostname var: ", hostname)
			print("getnameinfo hostname txt: ", ffi.string(hostname))
			print("getnameinfo servinfo var: ", servinfo)
			print("getnameinfo servinfo txt: ", ffi.string(servinfo))

			flags = bit.bor(C.NI_NAMEREQD)
			err = sock.getnameinfo(sa, ffi.sizeof(sa), hostname, C.NI_MAXHOST, servinfo, C.NI_MAXSERV, flags)
			print()
			print("getnameinfo err         : "..err.." ("..sock_errortext(err)..")")
			print("getnameinfo hostname var: ", hostname[0])
			print("getnameinfo hostname txt: ", ffi.string(hostname[0]))
			print("getnameinfo servinfo var: ", servinfo[0])
			print("getnameinfo servinfo txt: ", ffi.string(servinfo[0]))
		end
		print()

		-- connect to server
    s = sock.socket(ai.ai_family, ai.ai_socktype, ai.ai_protocol)
    if s < 0 then
      cause = "socket"
      break
    end

    if sock.connect(s, ai.ai_addr, ai.ai_addrlen) < 0 then
      cause = "connect";
      sock_close(s)
      s = -1;
      break
    else
      sock_close(s)
      print("*** connected succesfully to: host="..host..", serv="..serv);
    end
		print(" ------------------- ")
	end

	if ai.ai_next ~= nil then
		ai = ai.ai_next
		loop = loop + 1
	else
		loop = 0
	end
end

if (s < 0) then
	print("*** connect ERROR: "..s..". cause: "..cause)
end

sock.freeaddrinfo(res0[0])
if ffi.os == "Windows" then
	sock.WSACleanup()
end

print()
print(" -- TestAddrinfo.lua end -- ")
print()
