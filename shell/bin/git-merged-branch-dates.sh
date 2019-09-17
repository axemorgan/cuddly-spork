#1bin/bash
# Lists all branches that have been merged into dev with their last committed date.

git for-each-ref --sort=committerdate refs/remotes/ --merged=origin/dev --format='%(committerdate:short) %(refname:short)'