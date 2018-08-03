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
    try:
        os.symlink(target, link)
        return colors.GREEN + 'new link created' + colors.END
    except OSError as e:
        if e.errno == errno.EEXIST:
            if args.force:
                os.remove(link)
                os.symlink(target, link)
                return colors.GREEN + 'new link created' + colors.END
            else:
                return colors.YELLOW + 'link already exists' + colors.END
        else:
            raise e

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
    dotfiles = glob.glob('dotfiles/all/*')

    if uname == 'Darwin':
        dotfiles += glob.glob('dotfiles/darwin/*')
    elif uname == 'Linux':
        dotfiles += glob.glob('dotfiles/linux/*')
    elif uname == 'CYGWIN_NT':
        dotfiles += glob.glob('dotfiles/cygwin_nt/*')

    for file in dotfiles:
        file_path = env_path + '/' + file
        link_path = home_path + '/.' + os.path.basename(file)
        action = ''

        action = symlink(file_path, link_path)
        print "%s %s->%s %s: %s" % (link_path, colors.PINK, colors.END, file_path, action)

    # link bins
    print "\nLinking bin files:"
    binfiles = glob.glob('bin/*')

    try:
        os.mkdir(home_path + '/bin')
    except OSError as e:
        if e.errno == errno.EEXIST:
            pass
        else:
            raise e

    for file in binfiles:
        file_path = env_path + '/' + file
        link_path = home_path + '/bin/' + os.path.basename(file).split('.')[0]
        action = ''

        action = symlink(file_path, link_path)
        print "%s %s->%s %s: %s" % (link_path, colors.PINK, colors.END, file_path, action)
