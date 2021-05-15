#!/usr/bin/env python3

import sys
from railroad import Diagram, Choice

d = Diagram("foo", Choice(0, "bar", "baz"))
d.writeSvg(sys.stdout.write)