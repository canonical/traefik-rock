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

  release_key="${version}-${base}"

  # Check if an entry for this version already exists
  existing=$(yq ".upload[] | select(.directory == \"$version\")" "$MANIFEST_FILE")

  if [[ -n "$existing" ]]; then
    # Update existing entry in place
    yq -i "(.upload[] | select(.directory == \"$version\")).source = \"${REPO}\"" "$MANIFEST_FILE"
    yq -i "(.upload[] | select(.directory == \"$version\")).commit = \"${SHA}\"" "$MANIFEST_FILE"
    yq -i "(.upload[] | select(.directory == \"$version\")).release.\"${release_key}\".end-of-life = \"$eol\"" "$MANIFEST_FILE"
    yq -i "(.upload[] | select(.directory == \"$version\")).release.\"${release_key}\".risks = [\"stable\"]" "$MANIFEST_FILE"
  else
    # Build a new entry and append
    tmp_entry="$(pwd)/.tmp_entry_$$.yaml"
    echo '{}' > "$tmp_entry"
    yq -i ".source = \"${REPO}\"" "$tmp_entry"
    yq -i ".commit = \"${SHA}\"" "$tmp_entry"
    yq -i ".directory = \"$version\"" "$tmp_entry"
    yq -i ".release.\"${release_key}\".end-of-life = \"$eol\"" "$tmp_entry"
    yq -i ".release.\"${release_key}\".risks = [\"stable\"]" "$tmp_entry"

    # Append to the manifest
    yq eval-all 'select(fileIndex == 0).upload += [select(fileIndex == 1)] | select(fileIndex == 0)' "$MANIFEST_FILE" "$tmp_entry" > "${MANIFEST_FILE}.tmp"
    mv "${MANIFEST_FILE}.tmp" "$MANIFEST_FILE"
    rm "$tmp_entry"
  fi
done
