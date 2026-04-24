#!/bin/bash
# Regenerate and sign ZyntrixOS APT repository metadata.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DIST_DIR="${REPO_ROOT}/dists/stable"
PACKAGES_FILE="${DIST_DIR}/main/binary-amd64/Packages"
SIGNING_KEY="${ZYNTRIX_SIGNING_KEY:-122650C8E874AECA}"
SIGN_METADATA=1

usage() {
    cat <<EOF
Usage: scripts/refresh-metadata.sh [--no-sign]

Environment:
  ZYNTRIX_SIGNING_KEY   GPG key id or fingerprint used to sign metadata.
                        Default: ${SIGNING_KEY}
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --no-sign)
            SIGN_METADATA=0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

command -v dpkg-scanpackages >/dev/null 2>&1 || {
    echo "dpkg-scanpackages is required." >&2
    exit 1
}
command -v apt-ftparchive >/dev/null 2>&1 || {
    echo "apt-ftparchive is required. Install apt-utils." >&2
    exit 1
}

cd "$REPO_ROOT"

mkdir -p "$(dirname "$PACKAGES_FILE")"
dpkg-scanpackages pool /dev/null > "$PACKAGES_FILE"
gzip -n -9 -c "$PACKAGES_FILE" > "${PACKAGES_FILE}.gz"

apt-ftparchive \
    -o APT::FTPArchive::Release::Origin=ZyntrixOS \
    -o APT::FTPArchive::Release::Label=ZyntrixOS \
    -o APT::FTPArchive::Release::Suite=stable \
    -o APT::FTPArchive::Release::Codename=stable \
    -o APT::FTPArchive::Release::Architectures=amd64 \
    -o APT::FTPArchive::Release::Components=main \
    -o APT::FTPArchive::Release::Description="ZyntrixOS stable package channel" \
    release "$DIST_DIR" > "${DIST_DIR}/Release"

if [ "$SIGN_METADATA" = "1" ]; then
    command -v gpg >/dev/null 2>&1 || {
        echo "gpg is required to sign metadata." >&2
        exit 1
    }
    gpg --batch --yes --default-key "$SIGNING_KEY" --clearsign \
        -o "${DIST_DIR}/InRelease" "${DIST_DIR}/Release"
    gpg --batch --yes --default-key "$SIGNING_KEY" -abs \
        -o "${DIST_DIR}/Release.gpg" "${DIST_DIR}/Release"
fi

echo "Repository metadata refreshed."
