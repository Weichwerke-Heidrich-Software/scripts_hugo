#!/bin/bash

set -e

cd $(git rev-parse --show-toplevel)

changed_files=$(git status --porcelain | awk '{print $2}')

if [[ -n "$changed_files" ]]; then
  echo "There are unstaged changes:"
  git status
  suggested_message="Updated ${changed_files}."
  read -p "Enter commit message (default: ${suggested_message}): " commit_message
  commit_message=${commit_message:-$suggested_message}
  git add $changed_files
  git commit -m "$commit_message"
  git push
fi
