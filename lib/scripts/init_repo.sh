#!/bin/bash
set -e #-x #ONLY FOR DEV

repo_url=$1
clone_from=${2:-$repo_url} #take 2nd arg if present otherwise repo_url

#TODO remove sslverify
git -c http.sslverify=false clone -l --no-hardlinks --no-checkout $clone_from . # ${pwd}
git remote set-url origin $repo_url
git config core.sparsecheckout true
git config gc.auto 0
