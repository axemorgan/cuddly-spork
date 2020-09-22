# Fixes a common typo while navigating
alias cd..="cd .."

# Shorthand for clear
alias cl="clear"

# ls with fancy options for all files and dirs; IN COLOR!
alias ls="ls -CFGA"

# Pretty prints all of the PATH components
path() {
    echo -e "${PATH//:/\\n}"
}

# Lists directories after changing directories
cd() {
    builtin cd "$@"
    ls
}

# Hides a file/directory by adding a leading '.' 
hide() {
	filename=$1
    if [ "${filename:0:1}" = "." ]; then
        mv "$filename" "${filename:1}"
    else
        mv "$filename" ".$filename"
    fi 
}

# Shorthand for fastlane using bundler
fast() { bundle exec fastlane "$@"; }

# Quick navigation to the projects dir
projects() { cd $PROJECTS }

# Path Configuration

export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
