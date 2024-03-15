#! /usr/bin/env zsh

dot_path=${0:a:h}/dotfiles

declare -A dot_files
dot_files=(
    [$HOME/.config]=$dot_path/config
    [$HOME/.zshrc]=$dot_path/zshrc
    [$HOME/.gdbinit]=$dot_path/gdbinit
    [$HOME/.tigrc]=$dot_path/tigrc
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

echo "\e[32mLinks created. Consider running additional setup if needed:\n\e[36m - homebrew_init.zsh\n - nvim_paq_init.zsh\e[0m"
