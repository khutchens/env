#! /usr/bin/env zsh

dot_path=${0:a:h}/dotfiles

ln -hsv $dot_path/config ~/.config
ln -hsv $dot_path/gdb ~/.gdb
ln -hsv $dot_path/gdbinit ~/.gdbinit
ln -hsv $dot_path/gitconfig ~/.gitconfig
ln -hsv $dot_path/zshrc ~/.zshrc
