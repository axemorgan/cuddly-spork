#!/bin/bash

EXIT_CODE_HOMEBREW_INSTALL_FAILED=99

SCRIPT_DIR=$(pwd)

IS_WORK_INSTALLATION=0


################################################################################
# Runs the given command and suppresses its output
# Arguments: 
#   $1 : the command to run
# Returns:
#   Nothing
################################################################################
silently() {
  eval $1 > /dev/null 2>&1
}

################################################################################
# Warns the user about overwriting existing dotfiles and prompts them to 
# continue. An afirmative response continues, a negative response exits the 
# script.
# Arguments:
#   None
# Returns:
#   Nothing
################################################################################
show_overwrite_warning() {
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


################################################################################
# Creates the dotfiles directory, if necessary, and backs up any existing files
# Arguments:
#   None
# Returns:
#   Nothing
################################################################################
backup_and_create_dir() {
  DOTFILES_DIR="$HOME/dotfiles"
  local backup_dir="$HOME/dotfiles_old"

  # Checks for an existing dotfiles directory
  if [[ -d $DOTFILES_DIR ]]; then
    printf "Found existing dotfiles. Backing up to $backup_dir\n"
    mkdir -p "$backup_dir"
    cp -R "$DOTFILES_DIR"/ "$backup_dir"
    rm -r "$DOTFILES_DIR"
    mkdir -p "$DOTFILES_DIR"
    printf "Backup finished\n"
  else
    mkdir -p $DOTFILES_DIR
    printf "Created dotfiles directory\n"
  fi

  printf "\n"
}

################################################################################
# Prompts the user to choose work or home installation which is used to 
# configure the script.
# Arguments:
#   None
# Returns:
#   IS_WORK_INSTALLATION will be set true or false
################################################################################
prompt_for_work_or_home() {
  while true; do
    read -p "Is this a work or home installation? [work/home] " response
    case "$response" in
      work* ) IS_WORK_INSTALLATION=1; break;;
      home* ) IS_WORK_INSTALLATION=0; break;;
      * ) printf "Please answer work or home\n";;
    esac
  done

  printf "\n"
}


################################################################################
# Configures bashrc and bash_profile
# Arguments:
#   IS_WORK_ENVIRONMENT: Whether the script is being run in work or home mode.
# Returns:
#   Nothing
################################################################################
configure_shell() {
  printf "Copying shell scripts...\n"
  cp -R "$SCRIPT_DIR/shell" "$DOTFILES_DIR"

  if [ "$IS_WORK_INSTALLATION" -eq 1 ]; then
    echo "source $DOTFILES_DIR/shell/bashrc_work" >> $DOTFILES_DIR/shell/bashrc
  else
  	echo "source $DOTFILES_DIR/shell/bashrc_home" >> $DOTFILES_DIR/shell/bashrc
  fi
  echo "" >> $DOTFILES_DIR/shell/bashrc

  printf "Settup up bashrc...\n"
  ln -fs $DOTFILES_DIR/shell/bashrc "$HOME/.bashrc"

  printf "Setting up bash_profile...\n"
  ln -fs $DOTFILES_DIR/shell/bash_profile "$HOME/.bash_profile"

  printf "Shell configuration complete\n"
  printf "\n"
}


################################################################################
# Checks for homebrew and installs it if needed
# Arguments:
#   None
# Returns:
#   Nothing
################################################################################
install_homebrew() {
  silently "brew -v"
  if [[ $? -eq 0 ]]; then
    printf "Homebrew is already installed 😎\n"
  else
    printf "Installing homebrew...\n"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [[ $? -eq 0 ]]; then
      printf "Homebrew successfully installed\n"
    else
      printf "Failed to install homebrew, exiting setup\n"
      exit $EXIT_CODE_HOMEBREW_INSTALL_FAILED
	fi
  fi
  printf "\n"	
}


################################################################################
# Installs a package using homebrew
# Arguments:
#   $1 : the package name to install
# Returns:
#   Nothing
################################################################################
install_package() {
  FILES=$(brew list $1)
  if [[ $FILES ]]; then
    printf "$1 already installed\n"
  else
    printf "Installing $1...\n"
    brew install $1
  fi
}


################################################################################
# Installs a cask using homebrew
# Arguments:
#   $1 : the cask name to install
# Returns:
#   Nothing
################################################################################
install_cask() {
  FILES=$(brew cask list $1)
  if [[ $FILES ]]; then
    printf "$1 already installed\n"
  else
    printf "Installing $1...\n"
    brew cask install $1
  fi
}


################################################################################
# Installs and configures git, and some extra git tools
# Arguments:
#   None
# Returns:
#   Nothing
################################################################################
configure_git() {
  install_package git

  printf "Configuring git...\n"
  git config --global user.name "Alex Morgan"
  git config --global user.email "axemorgan@gmail.com"

  install_package bash-git-prompt

  install_package bash-completion

  printf "Git configuration complete\n"

  printf "\n"
}


##
# Configure macOS defaults
##
configure_defaults() {
	printf "Configuring macOS defaults...\n"
	
	DEFAULTS_FILE="$SCRIPT_DIR/macos_defaults"
	if [[ -e $DEFAULTS_FILE ]]; then
		source $DEFAULTS_FILE
		printf "Finished configuring macOS\n"
	else
		printf "Failed to find defaults file at $DEFAULTS_FILE\nSkipping macOS configuration\n"
	fi

  printf "\n"
}


################################################################################
# Main
################################################################################
main() {
  show_overwrite_warning

  backup_and_create_dir

  prompt_for_work_or_home

  configure_shell

  install_homebrew

  configure_git

  brew tap caskroom/cask

  CASKS=(
	  google-chrome 	# Chrome browser
	  spectacle		# Mac window manager
	  postman			# REST service testing
	  gimp			# Photoshop, but free
	  sublime-text	# Text editing
	  java 			# Java is required for Android SDK
	  android-studio  # Android!
	  android-sdk		# Android SDK
    gitkraken       # Git GUI Tool
    slack
  )

  printf "Casks to be installed:\n"

  for cask in ${CASKS[@]}; do
	  printf "$cask\n"
  done
  unset cask
  printf "\n"

  for cask in ${CASKS[@]}; do
	  install_cask "$cask"
  done 


  # Work only cask installation
  if [ "$IS_WORK_INSTALLATION" -eq 1 ]; then
    brew tap burnsra/tap

    CASKS=(
      spike           # Spike Proxy
    )

    printf "Work casks to be installed:\n"

    for cask in ${CASKS[@]}; do
      printf "$cask\n"
    done
    unset cask
    printf "\n"

    for cask in ${CASKS[@]}; do
      install_cask "$cask"
    done 

    printf "Done installing work casks\n\n"
  fi

  configure_defaults

  printf "Applying new configuration to current terminal session...\n"
  source ~/.bash_profile

  printf "\nSetup complete!\n"
}

main
