#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>

int main (void) {

    int i;

    i = shm_open ("/tmp/shared", O_CREAT | O_EXCL, S_IRUSR | S_IWUSR);   printf ("shm_open rc = %d\n", i);

    shm_unlink ("/tmp/shared");

    return (0);
}