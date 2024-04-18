#! /bin/bash

# This script increases the version number of the project.

set -e

# Set up environment
CUR=$(pwd)
VER=$(grep "version: " $CUR/pubspec.yaml | sed 's/version: //')
MAJOR=$(echo $VER | cut -d. -f1)
MINOR=$(echo $VER | cut -d. -f2)
PATCH=$(echo $VER | cut -d. -f3)
NEW_VER=""
MAJOR_FLAG=false
MINOR_FLAG=false
PATCH_FLAG=false

usage() {
    echo 
    echo "Increases the version number of the project"
    echo "Usage: $0 [-h] [-m] [-n] [-p]"
    echo
    echo "  -h       Print this help message"
    echo "  -m       Increase major version"
    echo "  -n       Increase minor version"
    echo "  -p       Increase patch version"
}

while getopts ":h:mnp" opt; do
  case $opt in
    h)
        usage
        exit 0
        ;;
    m)
        MAJOR_FLAG=true
        ;;
    n)
        MINOR_FLAG=true
        ;;
    p)
        PATCH_FLAG=true
        ;;
    esac
done

if [ "$MAJOR_FLAG" = true ]; then
    NEW_VER="$((MAJOR + 1)).0.0"
elif [ "$MINOR_FLAG" = true ]; then
    NEW_VER="$MAJOR.$((MINOR + 1)).0"
elif [ "$PATCH_FLAG" = true ]; then
    NEW_VER="$MAJOR.$MINOR.$((PATCH + 1))"
else
    usage
    exit 1
fi

echo "Current version: $VER"
echo "New version: $NEW_VER"

# Update the version number in the pubspec.yaml file
sed -i '' "s/version: $VER/version: $NEW_VER/" $CUR/pubspec.yaml

# Commit the changes
git add pubspec.yaml

# Check if there are any changes to commit
if git diff-index --quiet HEAD --; then
  echo "No changes to commit"
else
  git commit -m "chore: increase version number to $NEW_VER"
  git push
fi