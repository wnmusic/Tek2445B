#!/usr/bin/env python3
from optparse import OptionParser
import sys
import struct


if __name__ == '__main__':

    parser = OptionParser()
    parser.add_option("-x", "--hex", dest="tohex", default=False,
                      help="convert to hex file", action="store_true")
    
    (options, args) = parser.parse_args()
    ofile = args[0] + ".bin"
    with open(args[0], "r") as f:
        strlist = f.read().split(',')
        strlist = [x for x in strlist if x]
        data = [ int(x, 16) for x in strlist]

    with open(ofile, "wb") as f:
        for d in data:
            buf = struct.pack("B", d)
            f.write(buf)
    
