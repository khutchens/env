#!/usr/bin/env python2.7

import sys, os, re

if __name__ == '__main__':
    paths = sys.argv[1:]
    deps = {}

    # traverse all paths and build list of dependencies for each file
    for path in paths:
        for step in os.walk(path):
            rootdir, subdirs, files = step
            for f_name in files:
                f_rootname, f_ext =  os.path.splitext(f_name)
                if f_ext == '.d':
                    with open(rootdir + '/' + f_name, 'r') as file:
                        for line in file:
                            for word in line.split():
                                match = re.match('([^ ]+\.(h|c|cpp))', word)
                                if match:
                                    dep = match.group(1)

                                    # insert dependency into dep list. use a dict though because it's a fast/efficient way to keep a list of unique items.
                                    deps[dep] = True

    for dep in deps:
        print dep
