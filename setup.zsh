#! /usr/bin/env zsh

dot_path=${0:a:h}/dotfiles

ln -sv $dot_path/config ~/.config
ln -sv $dot_path/gdb ~/.gdb
ln -sv $dot_path/gdbinit ~/.gdbinit
ln -sv $dot_path/gitconfig ~/.gitconfig
ln -sv $dot_path/zshrc ~/.zshrc
