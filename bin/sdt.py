#!/usr/bin/python

import glob, threading, time, Queue, sys, re, io, termios, os, traceback, errno

try:
    import serial
except ImportError as e:
    print "ERROR:", e, "... Try `pip install pyserial`."
    sys.exit()

try:
    import yaml
except ImportError as e:
    print "WARNING:", e, "... Proceeding without config file support. Try `pip install PyYAML`."

class Tty_Thread(threading.Thread):
    def __init__(self, q, path, num):
        try:
            self.BAUDS = config['bauds']
        except (NameError, KeyError):
            self.BAUDS = [ 230400, 115200, 57600, 38400, 9600 ]

        try:
            self.COLORS = config['colors']
        except (NameError, KeyError):
            self.COLORS= [ 32, 33, 34, 35, 31, 36, 37 ]

        super(Tty_Thread, self).__init__()
        self._stop = threading.Event()
        self.q = q
        self.path = path
        self.num = num
        self.color = self.COLORS[self.num % len(self.COLORS)]
        try:
            baud = config['defaults']['baud'][path]
        except (TypeError, KeyError, NameError):
            baud = self.BAUDS[0]

        try:
            self.baud_i = self.BAUDS.index(baud)
        except (ValueError):
            print "ERROR: Baud '%d' not in baud list! Defaulting to '%d'" % (baud, self.BAUDS[0])
            self.baud_i = 0

    def send_line(self, line, log=True):
        if log == True:
            color = self.color
        else:
            color = 0

        self.q.put((self.num, color, line))

    def run(self):
        try:
            self.device = serial.Serial(self.path, self.BAUDS[self.baud_i], timeout=0.05)

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
        finally:
            self.device.close()

    def stop(self):
        self._stop.set()

    def baud(self):
        try:
            self.baud_i = (self.baud_i + 1) % len(self.BAUDS)
            self.send_line("baud: %d" % self.BAUDS[self.baud_i], log=False)
            self.device.baudrate = self.BAUDS[self.baud_i]
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
    try:
        conf_fname = os.environ['HOME'] + time.strftime("/.sdt/config.yaml")
        config = yaml.safe_load(open(conf_fname))
    except IOError:
        pass
    except NameError:
        pass
    except yaml.parser.ParserError as e:
        print "ERROR parsing config file:"
        print e

    try:
        # use a set instead of a list to easily avoid duplicate paths
        paths = set()
        for path in config['paths']:
            paths |= set(glob.glob(path))
    except (IOError, NameError, KeyError):
        paths = glob.glob('/dev/tty.*')

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
            for path in paths:
                tty_threads.append(Tty_Thread(q, path, len(tty_threads)))
                tty_threads[-1].start()

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
                        tty_threads[current_thread].baud()
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
                            print "%s%d\t%d\t\033[%dm%s\033[0m" % (indent, thread.num, thread.BAUDS[thread.baud_i], thread.color, thread.path)
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
