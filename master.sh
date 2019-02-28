#!/bin/bash

# Update system
sudo apt-get update
sudo apt-get install python3-venv

# Install and configure VIM
./vim.sh

# Configure git
./git.sh

# Install postgres database
./postgres.sh
psql --version

# Overwrite bash config
cp -f .bash_profile ~/.bash_profile
source ~/.bash_profile