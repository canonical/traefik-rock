#!/bin/bash
set -euo pipefail

# Usage: extract-versions.sh <file1> [file2] ...
# Extracts deduplicated version directories from a list of changed file paths.
# Outputs: versions=<space-separated list> to GITHUB_OUTPUT

versions=""
for file in "$@"; do
  version="$(echo "$file" | cut -d'/' -f1)"
  if [[ ! " $versions " =~ " $version " ]]; then
    versions="${versions:+$versions }$version"
  fi
done

echo "versions=$versions"
echo "versions=$versions" >> "$GITHUB_OUTPUT"
