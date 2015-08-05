#!/bin/bash

set -x #ONLY FOR DEV
set -e

repo_url=$1
clone_from=${2:-$repo_url} #take 2nd arg if present otherwise repo_url

#TODO remove sslverify
git -c http.sslverify=false clone -l --no-hardlinks --bare $clone_from .
git remote set-url origin $repo_url
git config core.sparsecheckout true
git config --global gc.auto 0
