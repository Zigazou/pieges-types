#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <limits.h>

void test_a_plus_b_square() {
    unsigned short a;
    unsigned short b;
    unsigned short a_plus_b_square;
    unsigned short a_square_plus_a_b_plus_2_a_b;

    bool verified;

    for (a = 0; a < USHRT_MAX; a++) {
        for (b = 0; b < USHRT_MAX; b++) {
            a_plus_b_square = (a + b) * (a + b);
            a_square_plus_a_b_plus_2_a_b = a * a + b * b + 2 * a * b;

            if (a_plus_b_square != a_square_plus_a_b_plus_2_a_b) {
                printf("FOUND: a=%d, b=%d, (a+b)²=%d, a²+b²+2ab=%d\n", a, b);
            }
        }
    }
}

void main() {
    test_a_plus_b_square();
}