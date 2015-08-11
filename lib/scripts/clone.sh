#!/bin/bash
set -ex #TODO x #ONLY FOR DEV

dest_dir=$1
treeish=$2
use_submodules=$3

#GIT_INDEX_FILE="$dest_dir/.index" git --work-tree="$dest_dir" checkout $treeish
GIT_INDEX_FILE="$dest_dir/.index" git --work-tree="$dest_dir" read-tree -m -u $treeish
rm "$dest_dir/.index"

if [ "$use_submodules" = '--use-submodules' ]; then
  git submodule update --init
fi