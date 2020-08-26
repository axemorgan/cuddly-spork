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

# Shorthand for fastlane using bundler
fast() { bundle exec fastlane "$@"; }
