#!/bin/bash
# This script downloads the dotfiles repo to a project directory and then executes the setup script

# Runs a command and suppresses its output
silently() {
  eval $1 > /dev/null 2>&1
}

# Create projects directory under home if it doesn't already exist
function create_projects_directory() {
    DEFAULT_PROJECTS_DIR="projects"

    read -p "Name your projects directory, or leave it blank for the default ($DEFAULT_PROJECTS_DIR): " PROJECTS_DIR
    if [ -z "$PROJECTS_DIR"]; then
        PROJECTS_DIR=$DEFAULT_PROJECTS_DIR
    fi

    if [ ! -d "$HOME/$PROJECTS_DIR" ]; then
        mkdir "$HOME/$PROJECTS_DIR"
    fi
}

# Clones the cuddly-spork repo to the projects directory, or pulls changes if it exists
function clone_or_update_repo() {
    REPO_DIR="$HOME/$PROJECTS_DIR/cuddly-spork"
    if [ ! -d "$REPO_DIR" ]; then
        git clone --progress https://github.com/axemorgan/cuddly-spork.git "$REPO_DIR"
    else
        echo "The dotfiles repo is already present, pulling the latest changes..."
        git -C "$REPO_DIR" pull
        if [ $? -ne 0 ]; then
            echo "FATAL: Unable to pull changes! Exiting"
            exit 1
        fi
    fi
}

# Setup proxy variables for Spike if needed
function setup_shell_proxy() {
    read -p "Is this machine proxied by Spike? (y/n): " PROXIED
    if [ $PROXIED == 'y' ]; then
        # This needs to be copied here because we may not have any of the other files yet
        export http_proxy="http://127.0.0.1:3128"
        export https_proxy=$http_proxy
        export ftp_proxy=$http_proxy
        export rsync_proxy=$http_proxy
        export HTTP_PROXY=$http_proxy
        export HTTPS_PROXY=$http_proxy
        export FTP_PROXY=$http_proxy
        export RSYNC_PROXY=$http_proxy
    fi
}

# Downloads and installs oh my zsh and then configures it
function install_zsh() {
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Symlink to the zsh custom plugin
    ln -sFf "$REPO_DIR/configuration.zsh" "$ZSH/custom/configuration.zsh"

    # Create a config file to export the projects directory an env variable
    projects_config="$ZSH/custom/projects_dir.zsh"
    echo "export PROJECTS=$HOME/$PROJECTS_DIR" > "$projects_config"
    source "$projects_config"

    # Symlink proxy configuration if needed
    if [ $PROXIED == 'y' ]; then
        echo "Making the proxy settings permanent..."
        ln -sFf "$REPO_DIR/configuration_proxy.zsh" "$ZSH/custom/configuration_proxy.zsh"
    fi
}

# Configures some default git settings globally
function configure_git() {
    git config --global user.name "Alex Morgan"
    git config --global user.email "axemorgan@gmail.com"
    git config --global core.pager "more -R"
    git config --global core.editor "nano"
}

# Checks Github for an SSH key for this machine, creating and uploading one if needed
function setup_github_ssh() {
    echo "Connecting Github SSH..."
    read -p "Give a name to identify this machine: " MACHINE_NAME
    EXISTING_SSH_KEY=$(curl -sS -u axemorgan -H "Accept: application/vnd.github.v3+json" https://api.github.com/user/keys | jq ".[] | select(.title == \"$MACHINE_NAME\")")

    if [ ! -z "$EXISTING_SSH_KEY" ]; then
        echo "Found an existing SSH key on Github"
        jq . <<<"$EXISTING_SSH_KEY"
    else
        echo "Generating an SSH key and uploading to Github"
        ssh-keygen -q -t RSA -f "$HOME/.ssh/${MACHINE_NAME// /_}" -N ""
        PUBLIC_KEY=$(cat $HOME/.ssh/${MACHINE_NAME// /_}.pub)
        curl -sS -u axemorgan -X POST -H "Accept: application/vnd.github.v3+json" https://api.github.com/user/keys -d "{\"title\":\"$MACHINE_NAME\", \"key\":\"$PUBLIC_KEY\"}" >/dev/null
        echo "$HOME/.ssh/${MACHINE_NAME// /_}.pub was added to Github"
    fi
}

# Returns true if running on OSX or macOS
function is_macOS() {
    if ! type sw_vers >/dev/null; then
        return true
    else
        return false
    fi
}

# Links the zsh configuration file specific to macOS
function link_mac_zsh_configuraion() {
    ln -sFf "$REPO_DIR/configuration_mac.zsh" "$ZSH/custom/configuration_mac.zsh"
}

# Checks for brews's presence and installs it if not found
install_homebrew_if_needed() {
  silently "brew -v"
  if [[ $? -eq 0 ]]; then
    echo "Homebrew is already installed 😎"
  else
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    if [[ $? -eq 0 ]]; then
      echo "Homebrew successfully installed"
    else
      echo "Failed to install homebrew, exiting setup"
      exit $EXIT_CODE_HOMEBREW_INSTALL_FAILED
    fi
  fi
}

# Install a package using brew; the package name is the first argument
install_brew_package() {
  FILES=$(brew list $1)
  if [[ $FILES ]]; then
    echo "☑️  $1 already installed"
  else
    printf "Installing $1...\n"
    brew install $1
  fi
}

# Installs homebrew and brews some packages
function install_mac_apps() {
  install_homebrew_if_needed
  echo "Installing default apps..."
  install_brew_package jq # Command-line JSON parser
  install_brew_package rbenv # For managing multiple ruby versions
}

echo "Installing dotfiles..."
setup_shell_proxy
create_projects_directory
clone_or_update_repo
configure_git

if [ is_macOS ]; then
    echo "Performing macOS specific setup..."
    link_mac_zsh_configuraion
    install_mac_apps
fi

setup_github_ssh
install_zsh

echo "Done!"

# Restart zsh to apply changes to the current session
exec zsh
