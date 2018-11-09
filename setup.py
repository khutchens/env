#!/usr/bin/env python2.7

import os, errno, glob, re
import argparse

class colors:
    RED     = '\033[31m'
    GREEN   = '\033[32m'
    YELLOW  = '\033[33m'
    BLUE    = '\033[34m'
    PINK    = '\033[35m'
    CYAN    = '\033[36m'
    END     = '\033[0m'

def symlink(target, link):
    if args.force:
        try:
            os.remove(link)
        except OSError as e:
            if e.errno == errno.ENOENT:
                pass
            else:
                raise e

    try:
        existing = os.readlink(link)
    except OSError as e:
        if e.errno == errno.ENOENT:
            existing = None
        elif e.errno == errno.EINVAL:
            existing = link
        else:
            raise e

    def print_action(color, action):
        print color + action.ljust(14) + colors.END + link + colors.PINK + ' -> ' + colors.END + target

    if existing == target:
        print_action(colors.BLUE, 'exists')
    elif existing == link:
        print_action(colors.RED, 'conflict')
    elif existing == None:
        if args.check:
            print_action(colors.YELLOW, 'missing')
        else:
            os.symlink(target, link)
            print_action(colors.GREEN, 'created')
    else:
        print_action(colors.RED, 'incorrect')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--force', help='Force link creation, replacing existing links', action='store_true')
    parser.add_argument('-c', '--check', help='Check what needs to be done, but don\'t actually do anything', action='store_true')
    args = parser.parse_args()

    home_path = os.path.expanduser('~')
    script_path = os.path.abspath(__file__)
    env_path = os.path.dirname(script_path)
    uname = os.uname()[0]

    # link dotfiles
    print "Linking dot files:"
    dotfiles = glob.glob(env_path + '/dotfiles/all/*')

    platform_dotfiles = {
        'Darwin': '/dotfiles/darwin/*',
        'Linux': '/dotfiles/linux/*',
        'CYGWIN_NT': '/dotfiles/cygwin_nt/*',
    }

    try:
        dotfiles += glob.glob(env_path + platform_dotfiles[uname])
    except KeyError:
        print 'No platform-specific dotfiles for:', colors.BLUE + uname + colors.END

    for file in dotfiles:
        symlink(file, home_path + '/.' + os.path.basename(file))

    # link bins
    print "\nLinking bin files:"
    binfiles = glob.glob(env_path + '/bin/*')

    try:
        os.mkdir(home_path + '/bin')
    except OSError as e:
        if e.errno == errno.EEXIST:
            pass
        else:
            raise e

    for file in binfiles:
        symlink(file, home_path + '/bin/' + os.path.basename(file).split('.')[0])
