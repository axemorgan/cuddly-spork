#!/bin/bash
# This script downloads the dotfiles repo to a project directory and then executes the setup script

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

    # Restart zsh to apply the changes to the current session
    exec zsh
}

# Configures some default git settings globally
function configure_git() {
    git config --global user.name "Alex Morgan"
    git config --global user.email "axemorgan@gmail.com"
    git config --global core.pager "more"
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

function setup_mac_terminal_shortcuts() {
    echo -e "\n# Line/word navigation shortcuts for macOS terminal \nbindkey "[D" backward-word \nbindkey "[C" forward-word \nbindkey "^[a" beginning-of-line \nbindkey "^[e" end-of-line \n" >>"$ZSH/custom/configuration.zsh"
}

echo "Installing dotfiles..."
setup_shell_proxy
create_projects_directory
clone_or_update_repo
install_zsh
configure_git
setup_github_ssh

if [ is_macOS ]; then
    echo "Performing macOS specific setup..."
    setup_mac_terminal_shortcuts
fi

echo "Done!"
