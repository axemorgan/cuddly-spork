#!/bin/bash

#Exit Codes
EXIT_DOTFILES_DIR_DOESNT_EXIST=10


# Warn user about overwriting current dotfiles
while true; do
	read -p "Warning: this script will overwrite your current dotfiles. Continue? [y/n] " response
	case $response in
		[Yy]* ) break;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no";;
	esac
done

echo Beginning dotfiles setup

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
