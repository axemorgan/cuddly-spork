#!/bin/bash

echo ""

# ################################################################################
# # Installs a cask using homebrew
# # Arguments:
# #   $1 : the cask name to install
# # Returns:
# #   Nothing
# ################################################################################
# install_cask() {
#   FILES=$(brew cask list $1)
#   if [[ $FILES ]]; then
#     printf "☑️  $1 already installed\n"
#   else
#     printf "Installing $1...\n"
#     brew cask install $1
#   fi
# }

# ##
# # Configure macOS defaults
# ##
# configure_defaults() {
#   printf "Configuring macOS defaults...\n"

#   DEFAULTS_FILE="$SCRIPT_DIR/macos_defaults"
#   if [[ -e $DEFAULTS_FILE ]]; then
#     source $DEFAULTS_FILE
#     printf "Finished configuring macOS\n"
#   else
#     printf "Failed to find defaults file at $DEFAULTS_FILE\nSkipping macOS configuration\n"
#   fi

#   printf "\n"
# }

# ################################################################################
# # Main
# ################################################################################
# main() {
#   show_overwrite_warning

#   backup_and_create_dir

#   prompt_for_work_or_home

#   configure_shell

#   install_homebrew

#   configure_git

#   brew tap caskroom/cask

#   CASKS=(
#     google-chrome  # Chrome browser
#     spectacle      # Mac window manager
#     postman        # REST service testing
#     gimp           # Photoshop, but free
#     sublime-text   # Text editing
#     java           # Java is required for Android SDK
#     android-studio # Android!
#     android-sdk    # Android SDK
#     gitkraken      # Git GUI Tool
#     slack
#   )

#   printf "Casks to be installed:\n"

#   for cask in ${CASKS[@]}; do
#     printf "$cask\n"
#   done
#   unset cask
#   printf "\n"

#   for cask in ${CASKS[@]}; do
#     install_cask "$cask"
#   done

#   # Work only cask installation
#   if [ "$IS_WORK_INSTALLATION" -eq 1 ]; then
#     brew tap burnsra/tap

#     CASKS=(
#       spike # Spike Proxy
#     )

#     printf "Work casks to be installed:\n"

#     for cask in ${CASKS[@]}; do
#       printf "$cask\n"
#     done
#     unset cask
#     printf "\n"

#     for cask in ${CASKS[@]}; do
#       install_cask "$cask"
#     done

#     printf "Done installing work casks\n\n"
#   fi

#   configure_defaults

#   printf "Applying new configuration to current terminal session...\n"
#   source ~/.bash_profile

#   printf "\nSetup complete!\n"
# }
