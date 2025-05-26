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

# Sync content directories (posts, etc.)
for dir in "${directories[@]}"; do
    src="$sourceBase/$dir"
    dest="$destinationBase/$dir"

    echo "Syncing directory: $dir"
    mkdir -p "$dest"
    # Using rsync with --delete for directories ensures destination mirrors source
    rsync -av --delete "$src/" "$dest/"
done

# Sync specific root-level content files (_index.md, about.md, projects.md)
for file in "${root_files[@]}"; do
    src="$sourceBase/$file"
    dest="$destinationBase/$file"

    echo "Syncing file: $file"
    # Ensure the parent directory for the destination file exists (e.g., content/)
    mkdir -p "$(dirname "$dest")"
    # Using cp for individual files
    cp "$src" "$dest"
done

# Run image processor
echo "Running image link processor..."
if ! python3 images.py; then
    echo "Image processing failed."
    exit 1
fi

# Stage, commit, and push changes
echo "Staging and pushing changes..."
# Check if there are any changes (staged or unstaged) before committing
if git diff --quiet && git diff --cached --quiet; then
    echo "No changes to commit."
else
    git add .
    git commit -m "Sync content and update on $(date +'%Y-%m-%d %H:%M:%S')"
    # Assume 'main' branch, adjust if you use 'master' or another branch
    git push origin main 
fi

echo "✅ Deploy complete — content synced and pushed."
