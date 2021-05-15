#!/usr/bin/python

import sys

#for i in range(0x41, 0x5A + 1):
#for i in range(0x61, 0x7A + 1):
for i in range(0x3F, 0x7E + 1):
    sys.stdout.write ("%s" % chr(i))
    #sys.stdout.write ("Constant \"%s\", " % chr(i))
    #sys.stdout.write ("Constant [Char.chr(%i)], " % i)
