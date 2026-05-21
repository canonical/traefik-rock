#!/bin/bash
set -euo pipefail

# Usage: open-oci-factory-pr.sh <branch>
# Fork-syncs the OCI Factory and opens a PR from the fork to upstream.
#
# Required env vars:
#   GH_TOKEN - GitHub token for the bot account
#   OCI_FACTORY_DIR - path to the local OCI Factory clone
#   SOURCE_REPO - source repository for the PR body (e.g., canonical/traefik-rock)

BRANCH="$1"

# Sync the fork
gh repo sync --force is-devops-bot/oci-factory || \
  gh repo fork canonical/oci-factory --clone=false
gh repo sync --force is-devops-bot/oci-factory

# Check if PR already exists
cd "$OCI_FACTORY_DIR"
EXISTING_PR="$(gh pr list --repo canonical/oci-factory --head "is-devops-bot:${BRANCH}" --json url -q '.[0].url')"
if [[ -n "${EXISTING_PR}" ]]; then
  echo "PR already exists: ${EXISTING_PR}"
else
  gh pr create --repo canonical/oci-factory \
    --head "is-devops-bot:${BRANCH}" \
    --title "chore: Add new traefik releases" \
    --body "Automated PR to add new traefik rock releases from ${SOURCE_REPO}."
fi
