#!/bin/bash
# This script downloads the dotfiles repo to a project directory

# Create projects directory under home if it doesn't already exist
function create_projects_directory() {
    # TODO this will need to be changed to "projects" after development is done
    DEFAULT_PROJECTS_DIR="projects2"

    read -p "Name your projects directory, or leave it blank for the default ($DEFAULT_PROJECTS_DIR): " PROJECTS_DIR
    if [ -z "$PROJECTS_DIR"]; then
        PROJECTS_DIR=$DEFAULT_PROJECTS_DIR
    fi

    if [ ! -d "~/$PROJECTS_DIR" ]; then
        mkdir "$HOME/$PROJECTS_DIR"
    fi
}

echo "Installing dotfiles..."

create_projects_directory

git clone --progress https://github.com/axemorgan/cuddly-spork.git "$HOME/$PROJECTS_DIR/cuddly-spork"
