#!/bin/bash

EXIT_CODE_HOMEBREW_INSTALL_FAILED=99

##
# Runs the given command and suppresses its output
##
silently() {
	eval $1 > /dev/null 2>&1
}

##
# Warn user about overwriting current dotfiles
##
overwrite_warning() {
	while true; do
		read -p "Warning: this script will overwrite any current dotfiles. Continue? [y/n] " response
		case $response in
			[Yy]* ) break;;
			[Nn]* ) printf "Setup cancelled\n"; exit;;
			* ) printf "Please answer yes or no\n";;
		esac
	done

	printf "\n"
}


##
# Create the dotfiles directory if necessary and backup existing files
##
backup_and_create_dir() {
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
# Homebrew installation
##
install_homebrew() {
	printf "Installing homebrew...\n"
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}


##
# Main
##
overwrite_warning

backup_and_create_dir

configure_shell

# TODO use which
silently "brew -v"
if [[ $? -eq 0 ]]; then
	printf "Homebrew is already installed\n"
else
	install_homebrew
	if [[ $? -eq 0 ]]; then
		printf "Homebrew successfully installed\n"
	else
		printf "Failed to install homebrew\n"
		exit $EXIT_CODE_HOMEBREW_INSTALL_FAILED
	fi
fi
printf "\n"


brew tap caskroom/cask

CASKS=(
	google-chrome 	# Chrome browser
	spectacle		# Mac window manager
	postman			# REST service testing
	gimp			# Photoshop, but free
	sublime-text	# Text editing
	android-studio  # Android!
	)

printf "Packages to be installed:\n"

for cask in ${CASKS[@]}; do
	printf "$cask\n"
done
unset cask

for cask in ${CASKS[@]}; do
	printf "Installing $cask...\n"
	brew cask install $cask
done 


printf "\nSetup complete!\n"
