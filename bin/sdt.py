#!/usr/bin/env python3

import sys, serial, yaml, termios, select, glob, argparse, os

def error(message):
    print("Error:", message)
    sys.exit(1)

class SDTException(Exception):
    pass

class SDT(serial.Serial):
    def __init__(self, path, number, config):
        try:
            translate_parity = {
                'none': serial.PARITY_NONE,
                'even': serial.PARITY_EVEN,
                'odd':  serial.PARITY_ODD,
            }
            parity = translate_parity[config['parity']]
        except KeyError:
            raise SDTException("invalid parity '{}'".format(config['parity']))

        super().__init__(path, config['baud'], timeout=config['timeout'], parity=parity)

        try:
            translate_color = {
                'white':    '\033[39m',
                'red':      '\033[31m',
                'green':    '\033[32m',
                'yellow':   '\033[33m',
                'blue':     '\033[34m',
                'pink':     '\033[35m',
                'cyan':     '\033[36m',
            }
            self.color = translate_color[config['color']]
        except KeyError:
            raise SDTException("invalid color '{}'".format(config['color']))

        self.path = path
        self.number = number
        self.endl = config['endl'].encode('utf-8').decode('unicode_escape').encode('utf-8')

        try:
            self.name = config['name']
        except KeyError:
            self.name = self.path

    def format_line(self, message):
        return "{}: {}".format(self.number, self.color + message + '\033[0m')

    def read_line(self):
        line = self.read_until(self.endl).decode('utf-8', errors='replace')
        if len(line) == 0:
            return None
        else:
            return line.rstrip()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--config', metavar='CONF_FILE', default='sdt_conf.yaml')
    parser.add_argument('-g', '--gen-config', default=False, action='store_true')
    args = parser.parse_args()

    if args.gen_config:
        config = {
                'defaults': {
                'baud':     230400,
                'parity':   'none',
                'color':    'white',
                'endl':     '\\r\\n',
                'timeout':  0.1,
            },
            'devices':  {},
        }

        paths = glob.glob('/dev/tty??*')
        for path in paths:
            try:
                tty = serial.Serial(path, 230400)
                tty.close()
            except serial.SerialException:
                continue
            config['devices'][path] = {'name': os.path.basename(path)}

        with open(args.config, 'w') as conf_file:
            conf_file.write(yaml.dump(config, default_flow_style=False, indent=4))
        sys.exit(0)

    try:
        with open(args.config, 'r') as conf_file:
            config = yaml.safe_load(conf_file)
    except IOError as e:
        error("failed opening '{}': {}".format(args.config, str(e)))

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
            print(sdt.format_line(sdt.name))
        except termios.error as e:
            print("{}: error: {}".format(d_path, e))
        except SDTException as e:
            print("{}: error: {}".format(d_path, e))

        n += 1

    print("-----")
    try:
        exit = False
        while not exit:
            reads, writes, exes = select.select(sdts, [], [])
            for sdt in reads:
                line = sdt.read_line()
                if line == None:
                    print("Error reading '{}', disconnecting".format(sdt.format_line(sdt.name)))
                    sdts.remove(sdt)
                    if len(sdts) == 0:
                        exit = True
                else:
                    print(sdt.format_line(line))
    except KeyboardInterrupt:
        print("")

