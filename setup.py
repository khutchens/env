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
    if args.check:
        try:
            if target == os.readlink(link):
                action = colors.GREEN + 'exists'
            else:
                action = colors.RED + 'incorrect'
        except OSError as e:
            if e.errno == errno.ENOENT:
                action = colors.YELLOW + 'missing'
            else:
                raise e
    else:
        try:
            os.symlink(target, link)
            action = colors.GREEN + 'created'
        except OSError as e:
            if e.errno == errno.EEXIST:
                if args.force:
                    os.remove(link)
                    os.symlink(target, link)
                    action = colors.GREEN + 'created'
                elif target == os.readlink(link):
                    action = colors.YELLOW + 'exists'
                else:
                    action = colors.RED + 'differs'
            else:
                raise e

    print action.ljust(14), colors.END, link, colors.PINK, '->', colors.END, target

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

    if uname == 'Darwin':
        dotfiles += glob.glob(env_path + '/dotfiles/darwin/*')
    elif uname == 'Linux':
        dotfiles += glob.glob(env_path + '/dotfiles/linux/*')
    elif uname == 'CYGWIN_NT':
        dotfiles += glob.glob(env_path + '/dotfiles/cygwin_nt/*')

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
