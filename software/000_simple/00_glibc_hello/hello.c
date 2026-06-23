// Prints a greeting and the GLIBC_HELLO_OK marker, dynamically linked against glibc.
#include <stdio.h>
#include <unistd.h>
int main(void) {
    printf("hello from glibc-dynamic, pid=%d\n", getpid());
    printf("GLIBC_HELLO_OK\n");
    return 0;
}
