#!/bin/bash
set -euo pipefail

# Create a temporary build directory
site_flr=$(mktemp -d -t mkdocs-site-XXXXXXXX)
cleanup() {
    rm -rf "$site_flr"
}
trap cleanup EXIT

# Build the site with MkDocs
mkdocs build -d "$site_flr"

# Prepare the deployment directory, preserving .git and .gitmodules if present
DEST_DIR="github.io"
shopt -s extglob dotglob
cd "$DEST_DIR"
if [ -e github.io/.git ]; then
    git_contents=$(cat .git)
else
    git_contents="gitdir: ../.git/modules/github.io" # Incase missing (something got rid of it (like command below))
fi
rm -rf -- !( .git)
echo $git_contents > .git
cd ..

# Copy new site files to the deploy directory
cp -r "$site_flr"/. "$DEST_DIR"/

# Deploy to Git
cd "$DEST_DIR"
current_branch=$(git symbolic-ref --short HEAD)
if [ "$current_branch" != "main" ]; then
    git checkout main
fi

git checkout main
git add .
git commit -m "Deployed site change"
git push
cd ..
