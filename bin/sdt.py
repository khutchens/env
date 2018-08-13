#!/usr/bin/python

import glob, threading, time, Queue, sys, re, termios, os, errno

try:
    import serial
except ImportError as e:
    print "ERROR:", e, "... Try `pip install pyserial`."
    sys.exit()

try:
    import yaml
except ImportError as e:
    print "ERROR:", e, "... Try `pip install PyYAML`."
    sys.exit()

CONFIG_DEFAULT = """
# Path patterns to search for devices
paths: [ /dev/tty.* ]

# Bauds available for manual setting during run-time
bauds: [ 230400, 115200, 57600, 38400, 9600 ]

# Colors to use for printing device output
colors: [ 32, 33, 34, 35, 31, 36, 37 ]

# Specify default configurations for specific devices when opened. All fields are optional.
#
# Fields:
#
#   baud:   <rate>
#   parity: <none|even|odd>
#
# Example:
#
#   devices:
#       /dev/tty.usbserial-FT90AXRO:
#           baud: 3000000
#           parity: even
devices:
"""

class SDTException(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return str(self.value)

class Tty_Thread(threading.Thread):
    def __init__(self, q, path, num, color, baud, parity):
        super(Tty_Thread, self).__init__()
        self._stop = threading.Event()
        self.q = q
        self.path = path
        self.num = num
        self.color = color
        self.baud = baud

        if parity == 'none':
            self.parity = serial.PARITY_NONE
        elif parity == 'even':
            self.parity = serial.PARITY_EVEN
        elif parity == 'odd':
            self.parity = serial.PARITY_ODD
        else:
            raise SDTException('invalid parity')

    def send_line(self, line, log=True):
        if log == True:
            color = self.color
        else:
            color = 0

        self.q.put((self.num, color, line))

    def run(self):
        with serial.Serial(self.path, self.baud, timeout=0.05, parity=self.parity) as self.device:
            buf = ""
            line_time = time.time()

            while not self._stop.isSet():
                try:
                    chunk = self.device.read(256)
                except serial.SerialException as e:
                    self.send_line(str(e), log=False)
                    return

                read_time = time.time()
                timeout = ((read_time - line_time) > 1)

                if len(chunk) > 0 or timeout:
                    buf += chunk
                    lines = re.split('\r\n|\r|\n', buf)

                    complete_lines = lines[:-1]
                    incomplete_line = lines[-1]

                    if len(complete_lines) > 0:
                        line_time = read_time
                        for line in complete_lines:
                            self.send_line(line)

                    if timeout:
                        line_time = read_time
                        if len(incomplete_line) > 0:
                            self.send_line(incomplete_line)
                        buf = ""
                    else:
                        buf = incomplete_line

    def stop(self):
        self._stop.set()

    def setbaud(self, baud):
        try:
            self.device.baudrate = baud
            self.baud = baud
            self.send_line("baud: %d" % baud, log=False)
        except AttributeError as e:
            self.send_line("Setting baud failed, try again: " + str(e), log=False)

class Input_Thread(threading.Thread):
    def __init__(self, q):
        super(Input_Thread, self).__init__()
        self._stop = threading.Event()
        self.q = q

    def run(self):
        # switch stdin to raw input mode to allow detecting key presses
        stdin = sys.stdin.fileno()

        oldterm = termios.tcgetattr(stdin)
        newattr = termios.tcgetattr(stdin)
        newattr[3] = newattr[3] & ~termios.ICANON & ~termios.ECHO & ~termios.ISIG
        termios.tcsetattr(stdin, termios.TCSANOW, newattr)

        while not self._stop.isSet():
            c = sys.stdin.read(1)
            self.q.put(c)
            if c == '\x03':
                break

        # switch back
        termios.tcsetattr(stdin, termios.TCSAFLUSH, oldterm)

    def stop(self):
        self._stop.set()

if __name__ == '__main__':
    while True:
        conf_fname = os.environ['HOME'] + "/.sdt/config.yaml"
        try:
            config = yaml.safe_load(open(conf_fname))
            break
        except IOError:
            os.makedirs(os.path.dirname(conf_fname))
            with open(conf_fname, 'w') as conf_file:
                conf_file.write(CONFIG_DEFAULT)
        except (yaml.parser.ParserError, yaml.scanner.ScannerError) as e:
            print "ERROR loading config file '%s':" % (conf_fname)
            print e
            sys.exit(0)


    # use a set instead of a list to easily avoid duplicate paths
    paths = set()
    for path in config['paths']:
        paths |= set(glob.glob(path))

    if len(paths) < 1:
        print "No devices found."
        sys.exit(0)

    q = Queue.Queue()
    tty_threads = []

    # message to prompt help banner on startup
    q.put('h')

    input_thread = Input_Thread(q)
    input_thread.start()

    log_fname = os.environ['HOME'] + time.strftime("/.sdt/log/sdt_%Y-%m-%d_%H%Mh.log")
    print "Logging to '%s'" % log_fname
    try:
        os.makedirs(os.path.dirname(log_fname))
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise
    with open(log_fname, 'a') as log_file:
        try:
            # launch threads to handle each tty
            print config
            for path in paths:
                n = len(tty_threads)
                color = config['colors'][n % len(config['colors'])]

                try:
                    baud = config['devices'][path]['baud']
                except (KeyError, TypeError):
                    baud = config['bauds'][0]

                try:
                    parity = config['devices'][path]['parity']
                except (KeyError, TypeError):
                    parity = 'none'

                thread = Tty_Thread(q, path, n, color, baud, parity)
                tty_threads.append(thread)
                thread.start()

            current_thread = 0

            # handle messages from other threads
            while True:
                msg = q.get()

                # handle key commands
                if isinstance(msg, str):
                    if msg == 't':
                        current_thread = (current_thread + 1) % len(tty_threads)
                        print "current tty: %d" % current_thread
                    elif msg == 'b':
                        tty = tty_threads[current_thread]
                        try:
                            i = config['bauds'].index(tty.baud)
                            i = (i + 1) % len(config['bauds'])
                        except ValueError:
                            i = 0
                        tty.setbaud(config['bauds'][i])
                    elif msg == 'd':
                        divider = time.strftime("------------------------------  %Y-%m-%d -- %H:%M:%S  ------------------------------")
                        print divider
                        log_file.write(divider + "\n")
                        log_file.flush()
                    elif msg == 'h':
                        print ""
                        print "    h\tShow help."
                        print "    t\tSwitch current TTY."
                        print "    b\tChange baud rate for current TTY."
                        print "    d\tPrint a horizontal divider."
                        print "\n    TTY\tBaud\tDevice"
                        for thread in tty_threads:
                            if thread.num == current_thread:
                                indent = "  ->"
                            else:
                                indent = "    "
                            print "%s%d\t%d\t\033[%dm%s\033[0m" % (indent, thread.num, thread.baud, thread.color, thread.path)
                        print ""
                    elif msg in ['q', chr(3), chr(4)]:
                        break

                # handle prints
                elif isinstance(msg, tuple):
                    num, color, text = msg
                    if color == 0:
                        print "-%d- %s" % (num, text)
                    else:
                        if text.startswith("ERROR"):
                            error_color = "30;41"
                        elif text.startswith("TODO"):
                            error_color = "30;43"
                        else:
                            error_color = "97;40"
                        print "\033[%sm[%d]\033[0m \033[%dm%s\033[0m" % (error_color, num, color, text)
                        log_file.write("[%d] %s\n" % (num, text))
                        log_file.flush()

        finally:
            print "Log written to '%s'" % log_fname
            threads = tty_threads + [input_thread]
            for thread in threads: thread.stop()
            for thread in threads: thread.join()
