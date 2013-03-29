struct pollfd
{
 int fd;
 short events;
 short revents;
};
typedef unsigned int nfds_t;

extern int poll (struct pollfd *, nfds_t, int) __asm("_" "poll" );

