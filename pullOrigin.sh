#!/bin/bash
currentBranchName=`git symbolic-ref --short -q HEAD`
echo ${currentBranchName}
git pull origin ${currentBranchName}
