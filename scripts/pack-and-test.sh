#!/bin/bash
set -euo pipefail

# Usage: pack-and-test.sh <version1> [version2] ...
# Packs and tests rocks for the given versions using rockcraft and dgoss.
#
# Required env vars:
#   GOSS_FILES_PATH - path where goss.yaml is located

for version in "$@"; do
  echo "::group::Packing rock for version $version"
  cd "$version"
  rockcraft pack
  cd ..
  echo "::endgroup::"

  echo "::group::Testing rock for version $version"
  rock_file=$(ls "$version"/*.rock)
  sudo rockcraft.skopeo --insecure-policy copy \
    "oci-archive:$rock_file" \
    docker-daemon:traefik-test:latest
  GOSS_FILES_PATH="${GOSS_FILES_PATH}" \
  GOSS_OPTS="--retry-timeout=60s" \
    dgoss run traefik-test:latest
  echo "::endgroup::"

  docker rmi traefik-test:latest 2>/dev/null || true
done
