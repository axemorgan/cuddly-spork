#!bin/bash
# Lists all merged branches older than the given date
# Print in human readable format: printf "%s\t%s\n", $1, $2

if [[ $1 =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]] 
	then
		git for-each-ref --sort=committerdate refs/remotes/ --no-merged=origin/dev --format='%(committerdate:short) %(refname:short)' | awk '{ if ($1 < date) { gsub(/origin\//, ""); print $2 } }' date=$1
	else
		echo "Error: Date should be entered in the format YYYY-MM-DD"
		exit 1
fi
