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

    if [[ -e $link_path ]]; then
        echo "Link exists: $link_path -> $target_path"
        return
    fi

    mkdir -p $link_path:h
    ln $ln_opts $target_path:a $link_path
}

cd $0:a:h/dotfiles

link config/fish/config.fish
link config/fish/functions/
link config/helix/config.toml
link gdbinit
link tigrc
