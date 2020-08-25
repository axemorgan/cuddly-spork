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
create_projects_directory
clone_or_update_repo

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Configure Git
git config --global user.name "Alex Morgan"
git config --global user.email "axemorgan@gmail.com"

sh -c "$HOME/$PROJECTS_DIR/cuddly-spork/setup.sh"
