#!/usr/bin/env python3
from pyftdi import spi
from optparse import OptionParser
import sys
import struct


def write_ram_loc(slave, addr, data):
    addr = (addr & 0x1FFF) | 0x8000;
    val = (addr << 16 ) | (data & 0xFF)<<8 | 0;
    buf = val.to_bytes(4, byteorder='big')
    slave.write(buf)


def read_ram_loc(slave, addr):
    val = ((addr & 0x1FFF) << 8 ) | 0;
    buf = val.to_bytes(3, byteorder='big')
    slave.write(buf)
    buf = slave.read(1)
    return struct.unpack('<B', buf)[0]

if __name__ == '__main__':

    parser = OptionParser()
    parser.add_option("-p", "--prog", dest="filename", default=None,
                      help="prog the file to ram", metavar="FILE")
    parser.add_option("-t", "--test", dest="test", default=False, 
                      help="test a read", action="store_true")

    ctrl = spi.SpiController()
    ctrl.configure('ftdi://ftdi:2232h/2')
    slave = ctrl.get_port(cs=0, freq=3E6, mode=0)

    (options, args) = parser.parse_args()

    if (options.test):
        write_ram_loc(slave, 0x1001, 0xa6)
        val = read_ram_loc(slave, 0x1001)
        print(val)
        sys.exit(1)
        
    
    if (options.filename):
        with open(options.filename, "r") as f:
            strlist = f.read().split(',')
            strlist = [x for x in strlist if x]
            data = [ int(x, 16) for x in strlist]
            for i in range(0x2000):
                write_ram_loc(slave, i, data[i])
            print("write done--->")

            for i in range(0x2000):
                val = read_ram_loc(slave, i)
                assert val == data[i], "read/write mismatch {}:{}".format(data[i], val)
            print("verify done")

        sys.exit(0)
    
    with open("dump.bin", "w") as f:
        for i in range(0x2000):
            val = read_ram_loc(slave, i)
            f.write("{:02X},".format(val))

    
