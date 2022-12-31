#! /usr/bin/env zsh
set -eu

git clone --depth=1 https://github.com/savq/paq-nvim.git $HOME/.local/share/nvim/site/pack/paqs/start/paq-nvim
echo "\e[32mPaq cloned. Launch neovim and run \e[36m:PaqInstall\e[0m"
