#!/usr/bin/env python3

from decimal import *

getcontext().prec = 1024

def decompose():
    one = Decimal('1')
    goal = Decimal('0.1')
    start = Decimal('2')

    total = Decimal('0')

    for i in range (1, 100):
        if total + one / start < goal:
            total = total + one / start
            print(format(total, '0.256f').rstrip("0"))

        start = start * 2

def real_double_0_1():
    num_0_1 = Decimal('7205759403792794') / (Decimal('2') ** Decimal('56'))
    print(format(num_0_1, '0.256f').rstrip("0"))

    num_0_2 = Decimal('7205759403792794') / (Decimal('2') ** Decimal('55'))
    print(format(num_0_2, '0.256f').rstrip("0"))

    num_0_3 = num_0_1 + num_0_2
    print(format(num_0_3, '0.256f').rstrip("0"))

def test_double_0_1():
    print(format(Decimal(0.1), '0.256f').rstrip("0"))
    print(format(Decimal(0.2), '0.256f').rstrip("0"))
    print(format(Decimal(0.1+0.2), '0.256f').rstrip("0"))
    print(format(Decimal(0.1) + Decimal(0.2), '0.256f').rstrip("0"))
    print(format(Decimal(0.3), '0.256f').rstrip("0"))
    print()
    print(format(Decimal(float(0.1)), '0.256f').rstrip("0"))
    print(format(Decimal(0.2), '0.256f').rstrip("0"))
    print(format(Decimal(0.3), '0.256f').rstrip("0"))
    print(format(Decimal(0.4), '0.256f').rstrip("0"))
    print(format(Decimal(0.5), '0.256f').rstrip("0"))
    print(format(Decimal(0.6), '0.256f').rstrip("0"))
    print(format(Decimal(0.7), '0.256f').rstrip("0"))
    print(format(Decimal(0.8), '0.256f').rstrip("0"))
    print(format(Decimal(0.9), '0.256f').rstrip("0"))

def magic_double_0_1():
    print(format(Decimal(0.1), '0.256f').rstrip("0"))
    print(format(Decimal(0.2), '0.256f').rstrip("0"))
    print(format(Decimal(0.3), '0.256f').rstrip("0"))
    print(format(Decimal(0.4), '0.256f').rstrip("0"))
    print(format(Decimal(0.5), '0.256f').rstrip("0"))
    print(format(Decimal(0.6), '0.256f').rstrip("0"))
    print(format(Decimal(0.7), '0.256f').rstrip("0"))
    print(format(Decimal(0.8), '0.256f').rstrip("0"))
    print(format(Decimal(0.9), '0.256f').rstrip("0"))

    print(format(Decimal(1.1), '0.256f').rstrip("0"))
    print(format(Decimal(1.2), '0.256f').rstrip("0"))
    print(format(Decimal(1.3), '0.256f').rstrip("0"))
    print(format(Decimal(1.4), '0.256f').rstrip("0"))
    print(format(Decimal(1.5), '0.256f').rstrip("0"))
    print(format(Decimal(1.6), '0.256f').rstrip("0"))
    print(format(Decimal(1.7), '0.256f').rstrip("0"))
    print(format(Decimal(1.8), '0.256f').rstrip("0"))
    print(format(Decimal(1.9), '0.256f').rstrip("0"))

    print(format(Decimal(2.1), '0.256f').rstrip("0"))
    print(format(Decimal(2.2), '0.256f').rstrip("0"))
    print(format(Decimal(2.3), '0.256f').rstrip("0"))
    print(format(Decimal(2.4), '0.256f').rstrip("0"))
    print(format(Decimal(2.5), '0.256f').rstrip("0"))
    print(format(Decimal(2.6), '0.256f').rstrip("0"))
    print(format(Decimal(2.7), '0.256f').rstrip("0"))
    print(format(Decimal(2.8), '0.256f').rstrip("0"))
    print(format(Decimal(2.9), '0.256f').rstrip("0"))

    print(format(Decimal(3.1), '0.256f').rstrip("0"))
    print(format(Decimal(3.2), '0.256f').rstrip("0"))
    print(format(Decimal(3.3), '0.256f').rstrip("0"))
    print(format(Decimal(3.4), '0.256f').rstrip("0"))
    print(format(Decimal(3.5), '0.256f').rstrip("0"))
    print(format(Decimal(3.6), '0.256f').rstrip("0"))
    print(format(Decimal(3.7), '0.256f').rstrip("0"))
    print(format(Decimal(3.8), '0.256f').rstrip("0"))
    print(format(Decimal(3.9), '0.256f').rstrip("0"))

    print(format(Decimal(4.1), '0.256f').rstrip("0"))
    print(format(Decimal(4.2), '0.256f').rstrip("0"))
    print(format(Decimal(4.3), '0.256f').rstrip("0"))
    print(format(Decimal(4.4), '0.256f').rstrip("0"))
    print(format(Decimal(4.5), '0.256f').rstrip("0"))
    print(format(Decimal(4.6), '0.256f').rstrip("0"))
    print(format(Decimal(4.7), '0.256f').rstrip("0"))
    print(format(Decimal(4.8), '0.256f').rstrip("0"))
    print(format(Decimal(4.9), '0.256f').rstrip("0"))

# 0.1
# 0 01111111011 1001100110011001100110011001100110011001100110011010
# 11001100110011001100110011001100110011001100110011010 / 2**56
# 7205759403792794 / 2**56

# 0.2
# 0 01111111100 1001100110011001100110011001100110011001100110011010
# 11001100110011001100110011001100110011001100110011010 / 2**55
# 7205759403792794 / 2**55

magic_double_0_1()
