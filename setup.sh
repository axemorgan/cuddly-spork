#!/bin/bash

#Exit Codes
EXIT_DOTFILES_DIR_DOESNT_EXIST=10


# Warn user about overwriting current dotfiles
while true; do
	read -p "Warning: this script will overwrite any current dotfiles. Continue? [y/n] " response
	case $response in
		[Yy]* ) break;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no";;
	esac
done


# Create the dotfiles directory if necessary
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles_old"

cd $DOTFILES_DIR > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
	# Backup the current dotfiles to dotfiles_old in the home directory
	echo "Found existing dotfiles. Backing up to $BACKUP_DIR"
	mkdir -p "$BACKUP_DIR"
	cp -R "$DOTFILES_DIR"/ "$BACKUP_DIR"
	rm -r "$DOTFILES_DIR"
	mkdir -p "$DOTFILES_DIR"
	echo "Dotfiles backed up."
else
	mkdir -p $DOTFILES_DIR
	echo "Created dotfiles directory."
fi



echo Beginning dotfiles setup

# TODO do setup

echo Setup complete!
