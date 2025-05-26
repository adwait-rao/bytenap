#!/bin/bash
set -euo pipefail

# Change to the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Base paths
sourceBase="/home/adwaitrao/Documents/adwait-notes/blog"
destinationBase="/home/adwaitrao/Documents/bytenap/content"

# Directories to sync
declare -a directories=("posts" "projects")

# SSH GitHub repo URL
remote_url="git@github.com:adwait-rao/bytenap.git"

# Check for required commands
for cmd in git rsync python3; do
    if ! command -v $cmd &> /dev/null; then
        echo "$cmd is not installed or not in PATH."
        exit 1
    fi
done

# Git setup if needed
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

# Sync Markdown content from Obsidian to Hugo
for dir in "${directories[@]}"; do
    src="$sourceBase/$dir"
    dest="$destinationBase/$dir"

    echo "Syncing $dir..."
    mkdir -p "$dest"
    rsync -av --delete "$src/" "$dest/"
done

# Process Markdown image links and copy images
echo "Running image processor..."
if ! python3 images.py; then
    echo "Image processing failed."
    exit 1
fi

# Stage, commit, and push changes
echo "Staging and committing changes..."
if git diff --quiet && git diff --cached --quiet; then
    echo "No changes to commit."
else
    git add .
    git commit -m "Content update on $(date +'%Y-%m-%d %H:%M:%S')"
    git push origin main
fi

echo "✅ All done! Synced, processed, committed, and pushed to GitHub via SSH."

