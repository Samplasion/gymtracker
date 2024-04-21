#! /bin/bash

# This script downloads the latest translations from the Accent server.
# It is intended to be run from the root of the project.

accent export

# Commit the changes
git add assets/i18n

# Check if there are any changes to commit
if git diff-index --quiet HEAD --; then
  echo "No changes to commit"
else
  git commit -m "chore: update translations"
fi