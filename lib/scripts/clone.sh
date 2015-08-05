#!/bin/bash
set -e #x #ONLY FOR DEV

dest_dir=$1
treeish=$2

#GIT_INDEX_FILE="$dest_dir/.index" git --work-tree="$dest_dir" checkout $treeish
GIT_INDEX_FILE="$dest_dir/.index" git --work-tree="$dest_dir" read-tree -m -u $treeish
rm "$dest_dir/.index"
