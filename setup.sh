#!/bin/bash

##
# Runs the given command and suppresses its output
##
silently() {
source "$1" > /dev/null 2>&1
}

##
# Warn user about overwriting current dotfiles
##
overwrite_warning() {
while true; do
	read -p "Warning: this script will overwrite any current dotfiles. Continue? [y/n] " response
	case $response in
		[Yy]* ) break;;
		[Nn]* ) exit;;
		* ) printf "Please answer yes or no\n";;
	esac
done

printf "\n"
}


##
# Create the dotfiles directory if necessary and backup existing files
##
create_and_backup() {
SCRIPT_DIR=$(pwd)
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles_old"

# Check for an existing dotfiles directory
if [[ -d $DOTFILES_DIR ]]; then	
	printf "Found existing dotfiles. Backing up to $BACKUP_DIR\n"
	mkdir -p "$BACKUP_DIR"
	cp -R "$DOTFILES_DIR"/ "$BACKUP_DIR"
	rm -r "$DOTFILES_DIR"
	mkdir -p "$DOTFILES_DIR"
	printf "Backup finished\n"
else
	mkdir -p $DOTFILES_DIR
	printf "Created dotfiles directory\n"
fi

printf "\n"
}


##
# Shell Configuration
##
configure_shell() {
printf "Copying shell scripts...\n"
cp -R "$SCRIPT_DIR/shell" "$DOTFILES_DIR"

printf "Setting up bash_profile...\n"
ln -fs $DOTFILES_DIR/shell/bash_profile "$HOME/.bash_profile"

printf "Shell configuration complete\n"
printf "\n"
}


##
# Install Sublime Text
##
install_sublime() {
printf "Downloading Sublime text package...\n"

SUBLIME_PACKAGE="https://download.sublimetext.com/Sublime%20Text%20Build%203126.dmg"
SUBLIME_DOWNLOAD="$HOME/Downloads/Sublime Text.dmg"

curl "$SUBLIME_PACKAGE" --output "$SUBLIME_DOWNLOAD"

hdiutil attach "$SUBLIME_DOWNLOAD"

cp -R "/Volumes/Sublime Text" "/Applications/Sublime Text"
printf "Sublime Text successfully installed\n"
printf "\n"
}


#Install homebrew if not present yet
#BREW_DIR="$HOME/Library/Homebrew/brew"
#source $BREW_DIR/bin/brew -v

#if [ $? -eq 0 ]
#then
#    echo "brew already installed"
#else
#    echo "Downloading and installing brew"
#fi



##
# Main
##
overwrite_warning

create_and_backup

configure_shell


echo Setup complete!
