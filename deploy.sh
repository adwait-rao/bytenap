#!/bin/bash
set -euo pipefail

# Change to the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Base paths
sourceBase="/home/adwaitrao/Documents/adwait-notes/blog"
destinationBase="/home/adwaitrao/Documents/bytenap/content"

# Git SSH remote
remote_url="git@github.com:adwait-rao/bytenap.git"

# Directories and files to sync
declare -a directories=("posts")
declare -a root_files=("_index.md" "about.md" "projects.md") 

# Ensure Git is initialized and remote set
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    git remote add origin "$remote_url"
else
    if ! git remote | grep -q 'origin'; then
        echo "Adding remote origin..."
        git remote add origin "$remote_url"
    fi
fi

# Sync directories (e.g., posts/)
for dir in "${directories[@]}"; do
    src="$sourceBase/$dir"
    dest="$destinationBase/$dir"

    echo "Syncing directory: $dir"
    mkdir -p "$dest"
    rsync -av --delete "$src/" "$dest/"
done

# Sync root-level markdown files
for file in "${root_files[@]}"; do
    src="$sourceBase/$file"
    dest="$destinationBase/$file"

    echo "Syncing file: $file"
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
done

# Run image processor
echo "Running image link processor..."
command -v python3 >/dev/null 2>&1 || {
    echo >&2 "Python3 is not installed. Aborting."
    exit 1
}

if ! python3 images.py; then
    echo "Image processing failed."
    exit 1
fi

# Stage, commit, and push changes
echo "Staging and pushing changes..."
if git diff --quiet && git diff --cached --quiet; then
    echo "No changes to commit."
else
    git add .
    git commit -m "Sync content and update on $(date +'%Y-%m-%d %H:%M:%S')"
    git push origin main
fi

echo "✅ Deploy complete — content synced and pushed."

