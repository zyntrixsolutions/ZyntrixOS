#!/bin/bash
# Configure a running Debian/antiX system to trust and consume ZyntrixOS updates.

set -euo pipefail

REPO_URL="${ZYNTRIX_REPO_URL:-https://zyntrixsolutions.github.io/ZyntrixOS}"
CHANNEL="stable"
KEY_FILE=""
OFFLINE_DIR=""
NO_UPDATE=0
KEYRING="/usr/share/keyrings/zyntrix-archive-keyring.gpg"
SOURCE_FILE="/etc/apt/sources.list.d/zyntrix.list"

die() { echo "ERROR: $*" >&2; exit 1; }
log() { echo "==> $*"; }

usage() {
    cat <<EOF
Usage:
  curl -fsSL https://zyntrixsolutions.github.io/ZyntrixOS/setup-repo.sh | sudo bash -s -- [options]
  sudo ./setup-repo.sh [options]

Options:
  --repo-url URL       Static APT repository URL
  --channel CHANNEL    stable, beta, or canary (default: stable)
  --key-file FILE      Public signing key (.gpg or ASCII-armored .asc)
  --offline DIR        Use an offline bundle or mounted repo directory
  --no-update          Do not run apt-get update
  -h, --help           Show this help
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --repo-url)
            shift
            REPO_URL="${1:-$REPO_URL}"
            ;;
        --channel)
            shift
            CHANNEL="${1:-$CHANNEL}"
            ;;
        --key-file)
            shift
            KEY_FILE="${1:-}"
            ;;
        --offline)
            shift
            OFFLINE_DIR="${1:-}"
            ;;
        --no-update)
            NO_UPDATE=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
    esac
    shift
done

[ "$(id -u)" -eq 0 ] || die "Run as root."
case "$CHANNEL" in stable|beta|canary) ;; *) die "Invalid channel '${CHANNEL}'" ;; esac

if [ -n "$OFFLINE_DIR" ]; then
    OFFLINE_DIR="$(readlink -f "$OFFLINE_DIR")"
    if [ -d "${OFFLINE_DIR}/zyntrix-repo" ]; then
        REPO_URL="file:${OFFLINE_DIR}/zyntrix-repo"
        [ -z "$KEY_FILE" ] && [ -f "${OFFLINE_DIR}/zyntrix-repo/zyntrix-archive-keyring.gpg" ] && KEY_FILE="${OFFLINE_DIR}/zyntrix-repo/zyntrix-archive-keyring.gpg"
    else
        REPO_URL="file:${OFFLINE_DIR}"
        [ -z "$KEY_FILE" ] && [ -f "${OFFLINE_DIR}/zyntrix-archive-keyring.gpg" ] && KEY_FILE="${OFFLINE_DIR}/zyntrix-archive-keyring.gpg"
    fi
fi

install_key() {
    mkdir -p "$(dirname "$KEYRING")"
    if [ -n "$KEY_FILE" ]; then
        [ -f "$KEY_FILE" ] || die "Key file not found: ${KEY_FILE}"
        case "$KEY_FILE" in
            *.asc|*.armor)
                command -v gpg >/dev/null 2>&1 || die "gpg not found; install gnupg or provide a binary .gpg key"
                gpg --dearmor < "$KEY_FILE" > "$KEYRING"
                ;;
            *)
                cp "$KEY_FILE" "$KEYRING"
                ;;
        esac
        chmod 0644 "$KEYRING"
        return
    fi

    if [ -f /usr/share/zyntrix/keyrings/zyntrix-archive-keyring.gpg ]; then
        cp /usr/share/zyntrix/keyrings/zyntrix-archive-keyring.gpg "$KEYRING"
        chmod 0644 "$KEYRING"
        return
    fi

    tmp="$(mktemp)"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "${REPO_URL%/}/zyntrix-archive-keyring.gpg" -o "$tmp" || true
    elif command -v wget >/dev/null 2>&1; then
        wget -q "${REPO_URL%/}/zyntrix-archive-keyring.gpg" -O "$tmp" || true
    fi
    if [ ! -s "$tmp" ]; then
        rm -f "$tmp"
        die "No signing key available. Pass --key-file or host zyntrix-archive-keyring.gpg at the repo root."
    fi
    cp "$tmp" "$KEYRING"
    chmod 0644 "$KEYRING"
    rm -f "$tmp"
}

log "Installing ZyntrixOS APT signing key"
install_key

mkdir -p /etc/apt/sources.list.d /etc/zyntrix
printf 'deb [arch=amd64 signed-by=%s] %s %s main\n' "$KEYRING" "${REPO_URL%/}" "$CHANNEL" > "$SOURCE_FILE"
printf '%s\n' "$CHANNEL" > /etc/zyntrix/channel

if [ ! -f /etc/zyntrix/update-policy.json ]; then
    cat > /etc/zyntrix/update-policy.json <<'EOF'
{
  "auto_check": "weekly",
  "auto_install": false,
  "staging": false,
  "staging_dir": "/var/cache/zyntrix/staged-updates",
  "rollback_healthcheck_seconds": 8,
  "allow_canary": false
}
EOF
fi

if [ "$NO_UPDATE" != "1" ]; then
    log "Refreshing APT metadata"
    apt-get update
fi

log "ZyntrixOS ${CHANNEL} repository configured at ${REPO_URL%/}"
