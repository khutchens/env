#!/usr/bin/env python3

import sys, serial, yaml, termios, select

def error(message):
    print("Error:", message)
    sys.exit(1)

def colored(color, message):
    colors = {
        'reset':    '\033[0m',
        'white':    '\033[39m',
        'red':      '\033[31m',
        'green':    '\033[32m',
        'yellow':   '\033[33m',
        'blue':     '\033[34m',
        'pink':     '\033[35m',
        'cyan':     '\033[36m',
    }

    return colors[color] + message + colors['reset']

class SDTException(Exception):
    pass

class SDT(serial.Serial):
    def __init__(self, path, number, config):
        translate_parity = {
            'none': serial.PARITY_NONE,
            'even': serial.PARITY_EVEN,
            'odd':  serial.PARITY_ODD,
        }

        try:
            parity = translate_parity[config['parity']]
        except KeyError:
            raise SDTException("invalid parity '{}'".format(config['parity']))

        super().__init__(path, config['baud'], timeout=config['timeout'], parity=parity)
        self.path = path
        self.number = number
        self.color = config['color']
        self.endl = bytes(config['endl'], 'utf-8')

        try:
            self.alias = config['alias']
        except KeyError:
            self.alias = self.path

    def format_line(self, message):
        return "{}: {}".format(self.number, colored(self.color, (message)))

    def read_line(self):
        line = self.read_until(self.endl).decode('utf-8', errors='replace')
        if len(line) == 0:
            return None
        else:
            return line.rstrip()

if __name__ == '__main__':
    try:
        conf_fname = sys.argv[1]
    except IndexError:
        conf_fname = 'sdt.yaml'

    try:
        config = yaml.safe_load(open(conf_fname))
    except IOError as e:
        error("failed opening config:" + str(e))

    n = 0
    sdts = []
    for d_path in config['devices']:
        d_config = config['defaults'].copy()
        try:
            d_config.update(config['devices'][d_path])
        except TypeError:
            # empty config
            pass

        try:
            sdt = SDT(d_path, n, d_config)
            sdts.append(sdt)
            print(sdt.format_line(sdt.alias))
        except termios.error as e:
            print("{}: error: {}".format(d_path, e))
        except SDTException as e:
            print("{}: error: {}".format(d_path, e))

        n += 1

    print("")
    try:
        exit = False
        while not exit:
            reads, writes, exes = select.select(sdts, [], [])
            for sdt in reads:
                line = sdt.read_line()
                if line == None:
                    print("Error reading '{}', disconnecting".format(sdt.format_line(sdt.alias)))
                    sdts.remove(sdt)
                    if len(sdts) == 0:
                        exit = True
                else:
                    print(sdt.format_line(line))
    except KeyboardInterrupt:
        print("")

