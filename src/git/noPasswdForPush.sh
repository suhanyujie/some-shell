#!/bin/bash
#
# git push的免密码操作
vim .git-credentials
# https://{username}:{password}@github.com
git config --global credential.helper store

