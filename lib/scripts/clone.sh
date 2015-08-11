#!/bin/bash
set -ex #TODO x #ONLY FOR DEV

repo_root=$1
dest_dir=$2
treeish=$3
use_submodules=$4

cd $repo_root

#GIT_INDEX_FILE="$dest_dir/.index" git --work-tree="$dest_dir" checkout $treeish
GIT_INDEX_FILE="$dest_dir/.index" git --work-tree="$dest_dir" read-tree -m -u $treeish


if [ "$use_submodules" = '--use-submodules' ]; then
  #GIT_INDEX_FILE="$dest_dir/.index" git --work-tree="$dest_dir" submodule update --init
  cd $dest_dir
  GIT_INDEX_FILE=.index git --git-dir="$repo_root/.git" submodule update --init --recursive
  # TODO for sparse submodules see http://kshmakov.org/notes/th/2/ , e.g.:
  # git config core.sparsecheckout true
  # echo <this_submodule>/paths > $repo_root/.git/modules/<this_submodule>/info/sparse-checkout
fi

rm "$dest_dir/.index"
