--  AddrinfoTest.lua
print()
print(" -- AddrinfoTest.lua start -- ")
print()

local arg = {...}
local ffi = require("ffi")
local C = ffi.C
local bit = require("bit")

local sock
if ffi.os == "Windows" then
	function MAKEWORD(low,high)
		return bit.bor(low , bit.lshift(high , 8))
	end
	ffi.cdef[[
		typedef unsigned short      WORD;
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

		int WSACleanup(void);
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
	local err = sock.WSAStartup(wVersionRequested, wsadata)
else
	sock = C
end

ffi.cdef[[
	// Address families. (socket.h)
	static const int AF_UNSPEC	= 0;		/* unspecified */
	static const int AF_UNIX		= 1;		/* local to host (pipes) */
	static const int AF_INET		= 2;		/* internetwork: UDP, TCP, etc. */

	// Types
	static const int	 SOCK_STREAM = 1	;	/* stream socket */

	typedef uint32_t socklen_t;
	typedef uint16_t in_port_t;
	typedef uint32_t in_addr_t;
	typedef unsigned short int sa_family_t;

	// Basic system type definitions, taken from the BSD file sys/types.h.
	typedef unsigned char   u_char;
	typedef unsigned short  u_short;
	typedef unsigned int    u_int;
	typedef unsigned long   u_long;

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
		uint8_t	sa_len;		/* total length */
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

	typedef struct addrinfo {
		int ai_flags;           /* input flags */
		int ai_family;          /* protocol family for socket */
		int ai_socktype;        /* socket type */
		int ai_protocol;        /* protocol for socket */
		socklen_t ai_addrlen;   /* length of socket-address */
		struct sockaddr *ai_addr; /* socket-address for socket */
		char *ai_canonname;     /* canonical name for service location */
		struct addrinfo *ai_next; /* pointer to next in list */
	 } *PADDRINFOA;

	//int getaddrinfo(const char *hostname, const char *servname, const struct addrinfo *hints, struct addrinfo **res);
	//void freeaddrinfo(struct addrinfo *ai);
	int getaddrinfo(const char* nodename,const char* servname,const struct addrinfo* hints,PADDRINFOA *res);
	void freeaddrinfo(PADDRINFOA pAddrInfo);

	int getnameinfo(const struct sockaddr *sa, socklen_t salen, char *host, socklen_t hostlen, char *serv, socklen_t servlen, int flags);

	const char* gai_strerror(int ecode);
	uint16_t htons(uint16_t hostshort);
	// Socket address conversions END

]]


-- ===================
function cstr(str)
	local len = str:len()+1
  local typeStr = "uint8_t[" .. len .. "]"
  return ffi.new( typeStr, str )
end

function createBuffer(datalen)
	if datalen < 1 then
		error("datalen < 1 (createBuffer)")
	end
	local var = ffi.new("int8_t[?]", datalen)
	local ptr = ffi.cast("int8_t *", var)
	--print(var, var[0], ptr, "'"..ffi.string(ptr).."'")
	return ptr
end
-- ===================

AI_PASSIVE                  =0x00000001  -- Socket address will be used in bind() call
AI_CANONNAME                =0x00000002  -- Return canonical name in first ai_canonname
AI_NUMERICHOST              =0x00000004  -- Nodename must be a numeric address string
AI_NUMERICSERV              =0x00000008  -- Servicename must be a numeric port number

function addrinfo_error(err)
	if ffi.os == "Windows" then
		return err --ffi.string(ffi.C.gai_strerror(err))
	else
		return ffi.string(ffi.C.gai_strerror(err))
	end
end

function dns_lookup ( hostname , port , hints )
	local service
	if port then
		service = tostring(port)
	end
	local res = ffi.new ("struct addrinfo*[1]")
	local err = sock.getaddrinfo ( hostname , service , hints , res )
	if err ~= 0 then
		error(addrinfo_error(err))
	end
	return res[0] --ffi.gc (res[0], sock.freeaddrinfo)
end
local addrinfo = dns_lookup( "8.8.8.8" , 5001 ) --"*"
print("addrinfo: ", addrinfo.ai_addr) --tostring(addrinfo))


local ai = ffi.new ( "struct addrinfo*[1]" )

--local hints = ffi.new("struct addrinfo")
--hints.ai_flags = AI_CANONNAME;	-- return canonical name
--hints.ai_flags = AI_NUMERICHOST
--hints.ai_family = C.AF_UNSPEC
--hints.ai_socktype = C.SOCK_STREAM

local host = "127.0.0.1" --cstr("127.0.0.1")
local serv = "http" --cstr("http")
local err = sock.getaddrinfo(host, serv, hints, ai)
print("getaddrinfo             : getaddrinfo('127.0.0.1', 'http', hints, ai_array)")
print("ai_array getaddrinfo err: "..err)
print()
print("ai getaddrinfo          : ", ai, ai[0], ai[0].ai_addrlen, ai[0].ai_addr, ai[0].ai_canonname)
--print("ai_array ai_canonname   : '", ffi.string(ai[0].ai_canonname).."'")
print()

local sa = ai[0].ai_addr
print("sa: ", sa)

local hostname = createBuffer(C.NI_MAXHOST)
local servinfo = createBuffer(C.NI_MAXSERV)

local flags = bit.bor(C.NI_NUMERICHOST, C.NI_NUMERICSERV)
local ret = 0
ret = sock.getnameinfo(sa, ffi.sizeof(sa), hostname, C.NI_MAXHOST, servinfo, C.NI_MAXSERV, flags)

print()
print("getnameinfo err         : "..ret)
print("getnameinfo hostname var: ", hostname)
print("getnameinfo hostname txt: ", ffi.string(hostname))
print("getnameinfo servinfo var: ", servinfo)
print("getnameinfo servinfo txt: ", ffi.string(servinfo))
print()

flags = bit.bor(C.NI_NAMEREQD)
ret = sock.getnameinfo(sa, ffi.sizeof(sa), hostname, C.NI_MAXHOST, servinfo, C.NI_MAXSERV, flags)
print("getnameinfo err         : "..ret)
print("getnameinfo hostname var: ", hostname)
print("getnameinfo hostname txt: ", ffi.string(hostname))
print("getnameinfo servinfo var: ", servinfo)
print("getnameinfo servinfo txt: ", ffi.string(servinfo))

if ffi.os == "Windows" then
	sock.WSACleanup()
end

print()
print(" -- AddrinfoTest.lua end -- ")
print()
