#!/bin/bash

# Set env vars for colors
YELLOW='\033[1;33m'
NC='\033[0m'

printf "${YELLOW}Enter your git username:\n${NC}"
read name
printf "${YELLOW}Enter your git email:\n${NC}"
read email

git config --global user.name $name
git config --global user.email $email