#!/bin/bash

# $1 is the directory to flatten (e.g., "docs" or "docs/docs")
base_dir="$1"

# If the path has multiple components (e.g., docs/docs), we need special handling
# to avoid "Directory not empty" errors when a subdirectory has the same name as its parent
if [[ "$base_dir" == */* ]]; then
    # Get the top-level parent directory (e.g., "docs" from "docs/docs")
    top_dir="${base_dir%%/*}"

    # First, move any config files from the top-level directory
    # (mkdocs.yml, pyproject.toml, etc.) - these should be moved before we delete the dir
    for file in "$top_dir"/*.yml "$top_dir"/*.yaml "$top_dir"/*.toml; do
        if [[ -f "$file" ]]; then
            mv "$file" . 2>/dev/null || true
        fi
    done

    # Create a temp directory for the move
    tmp_dir=$(mktemp -d)
    mv "$base_dir"/* "$tmp_dir/"

    # Remove the entire nested structure (e.g., remove "docs" which contains "docs/docs")
    rm -rf "$top_dir"

    # Move from temp to current directory
    mv "$tmp_dir"/* .
    rm -rf "$tmp_dir"
else
    # Simple case: single directory level
    mv "$base_dir"/* .
    rm -rf "$base_dir"
fi
