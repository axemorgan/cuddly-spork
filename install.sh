#!/bin/bash

echo "Installing dotfiles..."

# Create projects directory under home if it doesn't already exist
[ ! -d "~/projects/" ] && mkdir "~/projects/"

git clone --progress https://github.com/axemorgan/cuddly-spork.git ~/projects/
