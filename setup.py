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
    arrow = colors.PINK + '->' + colors.END
    print link, arrow, target,
    try:
        os.symlink(target, link)
        print colors.GREEN, 'new link created',
    except OSError as e:
        if e.errno == errno.EEXIST:
            if args.force:
                os.remove(link)
                os.symlink(target, link)
                print colors.GREEN, 'new link created',
            elif target == os.readlink(link):
                print colors.YELLOW, 'link exists',
            else:
                print colors.RED, 'link exists and differs',
        else:
            raise e
    print colors.END

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--force', help='Force link creation, replacing existing links', action='store_true')
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
