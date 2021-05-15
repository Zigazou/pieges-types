#include <stdio.h>
#include <stdlib.h>

char *long_to_binary(char *dest, unsigned long x) {
	unsigned long mask = 0x8000000000000000L;

	for (int i = 0; i < 64; i++) {
		dest[i] = x & mask ? '1' : '0';
		mask >>= 1;
	}

	dest[64] = '\0';
}

void main() {
	char bin_string[65];

	union {
		double real;
		unsigned long integer;
	} a;

	a.real = 0.1;

	long_to_binary(bin_string, a.integer);
	printf("%s\n", bin_string);

	a.real = 0.2;

	long_to_binary(bin_string, a.integer);
	printf("%s\n", bin_string);

	a.real = 0.3;

	long_to_binary(bin_string, a.integer);
	printf("%s\n", bin_string);

	a.real = 0.1 + 0.2;

	long_to_binary(bin_string, a.integer);
	printf("%s\n", bin_string);

}
