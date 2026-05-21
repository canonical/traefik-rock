#!/bin/bash
set -euo pipefail

# Usage: generate-image-yaml.sh <version1> [version2] ...
# Generates/updates image.yaml entries for the given versions.
#
# Required env vars:
#   MANIFEST_FILE - path to the image.yaml file
#   REPO          - source repository (e.g., canonical/traefik-rock)
#   SHA           - commit SHA to reference

eol=$(date -d "+1 year" -u +"%Y-%m-%dT00:00:00Z")

# Ensure the manifest file exists
mkdir -p "$(dirname "$MANIFEST_FILE")"
if [ ! -f "$MANIFEST_FILE" ]; then
  printf "version: 1\nupload: []\n" > "$MANIFEST_FILE"
fi

for version in "$@"; do
  # Read base from rockcraft.yaml (handle bare base)
  base=$(yq '.base' "$version/rockcraft.yaml" | sed 's/ubuntu@//')
  if [[ "$base" == "bare" ]]; then
    base=$(yq '.["build-base"]' "$version/rockcraft.yaml" | sed 's/ubuntu@//')
  fi

  # Remove existing entry for this version if present
  yq -i "del(.upload[] | select(.directory == \"$version\"))" "$MANIFEST_FILE"

  # Build the new upload entry
  tmp_entry=$(mktemp --suffix=.yaml)
  echo '{}' > "$tmp_entry"
  yq -i ".source = \"${REPO}\"" "$tmp_entry"
  yq -i ".commit = \"${SHA}\"" "$tmp_entry"
  yq -i ".directory = \"$version\"" "$tmp_entry"
  yq -i ".release.\"${version}-${base}\".end-of-life = \"$eol\"" "$tmp_entry"
  yq -i ".release.\"${version}-${base}\".risks = [\"stable\"]" "$tmp_entry"

  # Append to the manifest
  yq -i ".upload += [load(\"$tmp_entry\")]" "$MANIFEST_FILE"
  rm "$tmp_entry"
done
