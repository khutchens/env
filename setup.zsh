#! /usr/bin/env zsh
set -u

platform=$(uname)
if [[ $platform = Darwin ]]; then
    ln_opts=-shv
elif [[ $platform = Linux ]]; then
    ln_opts=-snv
fi

function link {
    target_path=$1
    link_path=$HOME/.$target_path

    if [[ -L $link_path ]]; then
        echo "Link exists: $link_path -> $target_path"
    elif [[ -d $link_path ]]; then
        echo "Directory exists at link path: $link_path"
    elif [[ -e $link_path ]]; then
        echo "File exists at link path: $link_path"
    else
        mkdir -p $link_path:h
        ln $ln_opts $target_path:a $link_path
    fi
}

cd $0:a:h/dotfiles

link config/fish/config.fish
link config/fish/functions
link config/helix/config.toml
link config/helix/languages.toml
link config/helix/themes
link gdbinit
link tigrc
