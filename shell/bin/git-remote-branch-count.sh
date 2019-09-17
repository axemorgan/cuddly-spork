#!/bin/bash
# Returns the number of remote branches in the current repository

git branch -r | wc -l