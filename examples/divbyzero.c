#include <stdio.h>
#include <stdlib.h>

void main() {
	int x = 1;
	int y = 0;
	int z;
	float a = 1.0;
	float b = -0.0;
	float c = 0.0;

	printf("%f\n", a/b);
	printf("%s\n", b == c ? "TRUE" : "FALSE");

	z = x / y;
	printf("%d / %d = %d\n", x, y, z);
}
