#!/bin/bash
set -euo pipefail

# Installs goss and dgoss to GOSS_DST (default: /usr/local/bin).
#
# This is a modified version of the official https://goss.rocks/install script.
# The main change is the arch detection logic: the official script only handles
# amd64 and arm64, so it falls back to the raw `uname -m` output for other arches
# (e.g. s390x). This is intentional — goss release assets use the kernel's own
# naming for non-x86/arm platforms.
# See: https://github.com/goss-org/goss/issues/1065

LATEST_URL="https://github.com/goss-org/goss/releases/latest"
LATEST_EFFECTIVE=$(curl -s -L -o /dev/null "${LATEST_URL}" -w '%{url_effective}')
LATEST="${LATEST_EFFECTIVE##*/}"

DGOSS_VER="${GOSS_VER:-}"

if [ -z "${GOSS_VER:-}" ]; then
    GOSS_VER="${LATEST}"
    DGOSS_VER="master"
fi
if [ -z "${GOSS_VER}" ]; then
    echo "ERROR: Could not automatically detect latest version, set GOSS_VER env var and re-run"
    exit 1
fi

GOSS_DST="${GOSS_DST:-/usr/local/bin}"
INSTALL_LOC="${GOSS_DST%/}/goss"
DGOSS_INSTALL_LOC="${GOSS_DST%/}/dgoss"

touch "${INSTALL_LOC}" || { echo "ERROR: Cannot write to ${GOSS_DST}; set GOSS_DST elsewhere or use sudo"; exit 1; }

arch=""
case "$(uname -m)" in
    x86_64)          arch="amd64" ;;
    aarch32)         arch="arm" ;;
    aarch64 | arm64) arch="arm64" ;;
    *)               arch="$(uname -m)" ;;
esac

url="https://github.com/goss-org/goss/releases/download/${GOSS_VER}/goss-linux-${arch}"
echo "Downloading ${url}"
curl -fsSL "${url}" -o "${INSTALL_LOC}"
chmod +rx "${INSTALL_LOC}"
echo "goss ${GOSS_VER} installed to ${INSTALL_LOC}"
"${INSTALL_LOC}" --version

dgoss_url="https://raw.githubusercontent.com/goss-org/goss/${DGOSS_VER}/extras/dgoss/dgoss"
echo "Downloading ${dgoss_url}"
curl -fsSL "${dgoss_url}" -o "${DGOSS_INSTALL_LOC}"
chmod +rx "${DGOSS_INSTALL_LOC}"
echo "dgoss ${DGOSS_VER} installed to ${DGOSS_INSTALL_LOC}"
