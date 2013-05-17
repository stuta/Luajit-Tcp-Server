
sourcefiles = {
	["windows"] = [[
#include <winbase.h>
#include <stdlib.h>
#include <stdio.h>
#include <wincon.h>
#include <sys/types.h>
#include <time.h>
#include <ws2tcpip.h>
#include <ws2def.h>
#include <Ws2ipdef.h>
]],
-- #include <Ws2ipdef.h>
-- #include <winsock2.h>


	["osx"] = [[
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/event.h>
// event.h is osx only kevent
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/time.h>
#include <poll.h>
#include <time.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <pthread.h>
#include <signal.h>
#include <string.h>
// /Users/pasi/asennetut_paketit/Lua/lua-5.1.5/src/install_bin/include/lua.h
]],

	["linux"] = [[
// #include <c++/4.7/iostream>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/types.h>
// event.h is osx only kevent
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/time.h>
#include <sys/poll.h>
#include <time.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <pthread.h>
#include <signal.h>
#include <string.h>
// #include <c++/4.7/string>
]],
}

--[[
// http://msdn.microsoft.com/en-us/library/windows/desktop/aa383751(v=vs.85).aspx
#include <IntSafe.h>
#include <windef.h>
#include <basetsd.h>
#include <Ddeml.h>
#include <ShellApi.h>
#include <winuser.h>
#include <winnt.h>
#include <winnls.h>
#include <winsvc.h>
#include <Winternl.h>

#include <windows.h>
#include <Mswsock.h>

// win
#include <specstrings.h>
#include <pshpack2.h>
#include <poppack.h>
#include <winerror.h>
#include <pshpack4.h>
#include <wincon.h>
#include <winbase.h>
#include <wingdi.h>
#include <winver.h>
#include <winnetwk.h>
#include <winreg.h>
#include <cderr.h>
#include <dde.h>
#include <dlgs.h>
]]
sourcefiles = {
	["windows"] = [[
#include <winbase.h>
#include <stdlib.h>
#include <stdio.h>
#include <wincon.h>
#include <sys/types.h>
#include <time.h>
#include <ws2tcpip.h>
#include <ws2def.h>
#include <Ws2ipdef.h>
]],

	["osx"] = [[
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/event.h>
// event.h is osx only kevent
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/time.h>
#include <poll.h>
#include <time.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <pthread.h>
#include <signal.h>
#include <string.h>
// /Users/pasi/asennetut_paketit/Lua/lua-5.1.5/src/install_bin/include/lua.h
]],

	["linux"] = [[
// #include <c++/4.7/iostream>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/types.h>
// event.h is osx only kevent
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/time.h>
#include <sys/poll.h>
#include <time.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <pthread.h>
#include <signal.h>
#include <string.h>
// #include <c++/4.7/string>
]],
}

--[[
// http://msdn.microsoft.com/en-us/library/windows/desktop/aa383751(v=vs.85).aspx
#include <IntSafe.h>
#include <windef.h>
#include <basetsd.h>
#include <Ddeml.h>
#include <ShellApi.h>
#include <winuser.h>
#include <winnt.h>
#include <winnls.h>
#include <winsvc.h>
#include <Winternl.h>

#include <windows.h>
#include <Mswsock.h>

// win
#include <specstrings.h>
#include <pshpack2.h>
#include <poppack.h>
#include <winerror.h>
#include <pshpack4.h>
#include <wincon.h>
#include <winbase.h>
#include <wingdi.h>
#include <winver.h>
#include <winnetwk.h>
#include <winreg.h>
#include <cderr.h>
#include <dde.h>
#include <dlgs.h>
]]