#!/bin/bash
set -euo pipefail

# Installs goss and dgoss to GOSS_DST (default: /usr/local/bin).
#
# This is a modified version of the official https://goss.rocks/install script.
# Recent goss releases are published as per-arch tarballs, while older releases
# used raw binary assets. Keep the arch detection explicit and fall back to the
# legacy asset layout when needed so pinned older versions still install.

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

release_arch=""
legacy_arch=""
case "$(uname -m)" in
    x86_64)                  release_arch="x86_64"; legacy_arch="amd64" ;;
    i386 | i686)             release_arch="i386"; legacy_arch="i386" ;;
    aarch64 | arm64)         release_arch="arm64"; legacy_arch="arm64" ;;
    armv6l | armv7l | aarch32) release_arch="armv6"; legacy_arch="arm" ;;
    ppc64le)                 release_arch="ppc64le"; legacy_arch="ppc64le" ;;
    s390x)                   release_arch="s390x"; legacy_arch="s390x" ;;
    *)
        release_arch="$(uname -m)"
        legacy_arch="$(uname -m)"
        ;;
esac

version_no_v="${GOSS_VER#v}"
archive_url="https://github.com/goss-org/goss/releases/download/${GOSS_VER}/goss_${version_no_v}_linux_${release_arch}.tar.gz"
legacy_url="https://github.com/goss-org/goss/releases/download/${GOSS_VER}/goss-linux-${legacy_arch}"
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

echo "Downloading ${archive_url}"
if curl -fsSL "${archive_url}" -o "${tmpdir}/goss.tar.gz"; then
    tar -xzf "${tmpdir}/goss.tar.gz" -C "${tmpdir}" goss
    install -m 0755 "${tmpdir}/goss" "${INSTALL_LOC}"
else
    echo "Falling back to legacy asset ${legacy_url}"
    curl -fsSL "${legacy_url}" -o "${INSTALL_LOC}"
    chmod +rx "${INSTALL_LOC}"
fi
chmod +rx "${INSTALL_LOC}"
echo "goss ${GOSS_VER} installed to ${INSTALL_LOC}"
"${INSTALL_LOC}" --version

dgoss_url="https://raw.githubusercontent.com/goss-org/goss/${DGOSS_VER}/extras/dgoss/dgoss"
echo "Downloading ${dgoss_url}"
curl -fsSL "${dgoss_url}" -o "${DGOSS_INSTALL_LOC}"
chmod +rx "${DGOSS_INSTALL_LOC}"
echo "dgoss ${DGOSS_VER} installed to ${DGOSS_INSTALL_LOC}"
