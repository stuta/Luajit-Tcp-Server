/***************************************************************************
 * Copyright (C) 2011 by Robert G. Jakabosky <bobby@sharedrealm.com>       *
 *                                                                         *
 ***************************************************************************/
#ifndef __L_SOCKET_H__
#define __L_SOCKET_H__

#include "lcommon.h"
#include "lsockaddr.h"

#ifdef __WINDOWS__
#include <winsock2.h>
#include <ws2def.h>
typedef SOCKET LSocketFD;
#define SOCK_NONBLOCK 1
#ifndef SOL_IP
#define SOL_IP IPPROTO_IP
#endif
#ifndef SOL_IPV6
#define SOL_IPV6 IPPROTO_IPV6
#endif
#ifndef SOL_TCP
#define SOL_TCP IPPROTO_TCP
#endif
#ifndef SOL_UDP
#define SOL_UDP IPPROTO_UDP
#endif
#else
typedef int LSocketFD;
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#ifdef HAVE_IPV6
#include <netinet/ip6.h>
#endif
#include <netinet/tcp.h>
#include <netinet/udp.h>
#endif

L_LIB_API int l_socket_set_nonblock(LSocketFD sock, bool val);

L_LIB_API int l_socket_set_close_on_exec(LSocketFD sock, bool val);

L_LIB_API int l_socket_get_option(LSocketFD sock, int level, int opt, void *val, socklen_t *len);

L_LIB_API int l_socket_set_option(LSocketFD sock, int level, int opt, const void *val, socklen_t len);

L_LIB_API int l_socket_get_int_option(LSocketFD sock, int level, int opt, int *val);

L_LIB_API int l_socket_set_int_option(LSocketFD sock, int level, int opt, int val);

#define l_socket_is_closed(sock) ((sock) < 0)

L_LIB_API int l_socket_pair(int type, int flags, LSocketFD sv[2]);

L_LIB_API LSocketFD l_socket_open(int domain, int type, int protocol, int flags);

L_LIB_API LSocketFD l_socket_close_internal(LSocketFD sock);
#define l_socket_close(sock) (sock) = l_socket_close_internal(sock)

L_LIB_API int l_socket_shutdown(LSocketFD sock, int how);

L_LIB_API int l_socket_connect(LSocketFD sock, LSockAddr *addr);

L_LIB_API int l_socket_bind(LSocketFD sock, LSockAddr *addr);

L_LIB_API int l_socket_listen(LSocketFD sock, int backlog);

L_LIB_API int l_socket_get_sockname(LSocketFD sock, LSockAddr *addr);

L_LIB_API int l_socket_get_peername(LSocketFD sock, LSockAddr *addr);

L_LIB_API LSocketFD l_socket_accept(LSocketFD sock, LSockAddr *peer, int flags);

L_LIB_API int l_socket_send(LSocketFD sock, const void *buf, size_t len, int flags);

L_LIB_API int l_socket_recv(LSocketFD sock, void *buf, size_t len, int flags);

#endif /* __L_SOCKET_H__ */
