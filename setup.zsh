#! /usr/bin/env zsh

dot_path=${0:a:h}/dotfiles

declare -A dot_files
dot_files=(
    [$HOME/.config]=$dot_path/config
    [$HOME/.zshrc]=$dot_path/zshrc
)

platform=$(uname)
if [[ $platform = Darwin ]]; then
    ln_opts=-shv
elif [[ $platform = Linux ]]; then
    ln_opts=-snv
fi

for link target in ${(kv)dot_files}; do
    ln $ln_opts $target $link
done

echo "Links created. Consider running additional setup if needed:\n - homebrew_init.zsh\n - vimplug_init.zsh"
