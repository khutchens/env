#!/usr/bin/env python2.7

import argparse

control = {
    0x00: {'carat':'^@', 'escape':'\\0'},
    0x01: {'carat':'^A'},
    0x02: {'carat':'^B'},
    0x03: {'carat':'^C'},
    0x04: {'carat':'^D'},
    0x05: {'carat':'^E'},
    0x06: {'carat':'^F'},
    0x07: {'carat':'^G', 'escape':'\\a'},
    0x08: {'carat':'^H', 'escape':'\\b'},
    0x09: {'carat':'^I', 'escape':'\\t'},
    0x0A: {'carat':'^J', 'escape':'\\n'},
    0x0B: {'carat':'^K', 'escape':'\\v'},
    0x0C: {'carat':'^L', 'escape':'\\f'},
    0x0D: {'carat':'^M', 'escape':'\\r'},
    0x0E: {'carat':'^N'},
    0x0F: {'carat':'^O'},
    0x10: {'carat':'^P'},
    0x11: {'carat':'^Q'},
    0x12: {'carat':'^R'},
    0x13: {'carat':'^S'},
    0x14: {'carat':'^T'},
    0x15: {'carat':'^U'},
    0x16: {'carat':'^V'},
    0x17: {'carat':'^W'},
    0x18: {'carat':'^X'},
    0x19: {'carat':'^Y'},
    0x1A: {'carat':'^Z'},
    0x1B: {'carat':'^[', 'escape':'\\e'},
    0x1C: {'carat':'^\\'},
    0x1D: {'carat':'^]'},
    0x1E: {'carat':'^^'},
    0x1F: {'carat':'^_'},
    0x7F: {'carat':'^?'},
}

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--format', choices=['carat', 'escape'], default='carat', help='Control code format.')

    args = parser.parse_args()

    print "  ",
    for lsn in range (0x10):
        print "%2x" % lsn,
    print ''

    for msn in range(0x8):
        print "%x:" % msn,

        for lsn in range (0x10):
            byte = ((msn << 4) | lsn)
            try:
                print control[byte][args.format],
            except KeyError:
                print "%2c" % ((msn << 4) | lsn),

        print ''
