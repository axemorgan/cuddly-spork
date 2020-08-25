#!/bin/bash
# This script downloads the dotfiles repo to a project directory and then executes the setup script

# Create projects directory under home if it doesn't already exist
function create_projects_directory() {
    # TODO this will need to be changed to "projects" after development is done
    DEFAULT_PROJECTS_DIR="projects2"

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

echo "Installing dotfiles..."

# Setup proxy variables for Spike
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

create_projects_directory
clone_or_update_repo

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Symlink to the zsh custom plugin then refresh to load the new config
ln -s "$REPO_DIR/configuration.zsh" "$ZSH/custom/configuration.zsh"
exec zsh

# Configure Git
git config --global user.name "Alex Morgan"
git config --global user.email "axemorgan@gmail.com"

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
