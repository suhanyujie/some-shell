#!/bin/bash
git stash
currentBranchName=`git symbolic-ref --short -q HEAD`
echo ${currentBranchName}
git checkout master
git symbolic-ref --short -q HEAD
git pull origin master
git checkout ${currentBranchName}
git stash pop
git merge master
