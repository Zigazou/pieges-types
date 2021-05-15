#include <stdio.h>
#include <stdlib.h>

void main() {
    short i;
    for (i = 0; i < 32700; i += 256) {
    	printf("%d\n", i);
    }
}
