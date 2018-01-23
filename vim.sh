#!/bin/bash

# Install full version of vim, Ubuntu only has vim.tiny by default
sudo apt-get update
sudo apt-get install -y vim
sudo apt-get install -y build-essential cmake
sudo apt-get install -y python-dev python3-dev

# Install Vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# overwrite .vimrc
# Plugins my .vimrc contains:
# -NERDTree
# -NERDCommenter
# -CtrlP
# -SimplyFold
# -IndentPython
# -Syntastic
# -Vim-Flake8
# -YouCompleteMe
# -Vim ColorSchemes (with srcery installed by default)
cp -f .vimrc ~/.vimrc

# install .vim/colors files
mkdir ~/.vim/colors
cp -R ./vimcolors/. ~/.vim/colors/

# set gnome terminal to match vim colorscheme srcery
./gnome_terminal.sh

# Vundle Install all plugins
# If that fails, open vim and run :PluginInstall
vim +PluginInstall +qall

# Compile YCM without support for C-family languages
~/.vim/bundle/YouCompleteMe/install.py
