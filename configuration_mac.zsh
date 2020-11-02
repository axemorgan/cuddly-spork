# Line/word navigation shortcuts for macOS terminal
bindkey "[D" backward-word
bindkey "[C" forward-word
bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line

# Android command line variables
export ANDROID_SDK_ROOT=~/Library/Android/sdk
export PATH=$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/tools/bin:$PATH

# Initialize Ruby environment
eval "$(rbenv init -)"
