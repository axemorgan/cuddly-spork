#!/bin/bash

EXIT_DOTFILES_DIR_DOESNT_EXIST=10


echo Beginning dotfiles setup

##
# Symlink the files in shell
##
DOTFILES_DIR="$HOME/dotfiles"

cd $DOTFILES_DIR

if [[ $? -eq 0 ]]; then
	#TODO Symlink them
	echo found the dotfiles
else
	#TODO this should instead do a git checkout and install the repo from GitHub
	echo Unable to find the dotfiles directory in the home directory
	exit $EXIT_DOTFILES_DIR_DOESNT_EXIST
fi

echo Setup complete!
