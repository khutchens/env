#!/usr/bin/env python3

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

def symlink(target, link, rel_path):
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
        action_color = color + action.ljust(10) + colors.END
        arrow_color = colors.PINK + ' -> ' + colors.END

        link_rel = os.path.relpath(link, rel_path)
        target_rel = os.path.relpath(target, rel_path)

        print(action_color + link_rel + arrow_color + target_rel)

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

    platform_paths = {
        'all': [
            {
                'to':       env_path + '/dotfiles/all/',
                'from':     home_path,
                'prefix':   '.',
            },
            {
                'to':       env_path + '/bin/',
                'from':     home_path + '/bin/',
                'remove_suffix': '.'
            },
            {
                'to':       env_path + '/dotfiles/config/',
                'from':     home_path + '/.config/',
            },
        ],

        'Darwin': [
            {
                'to':       env_path + '/dotfiles/darwin/',
                'from':     home_path,
                'prefix':   '.',
            },
        ],

        'Linux': [
            {
                'to':       env_path + '/dotfiles/linux/',
                'from':     home_path,
                'prefix':   '.',
            },
        ],
    }

    paths = platform_paths['all']
    try:
        paths += platform_paths[uname]
    except KeyError:
        print('No platform-specific dotfiles for:', colors.BLUE + uname + colors.END)

    for path in paths:
        os.makedirs(path['from'], exist_ok=True)
        files = glob.glob(path['to'] + '/*')
        for file in files:
            linkname = os.path.basename(file)

            try:
                linkname = linkname.split(path['remove_suffix'])[0]
            except KeyError:
                pass

            try:
                linkname = path['prefix'] + linkname
            except KeyError:
                pass
            symlink(file, path['from'] + '/' + linkname, home_path)

