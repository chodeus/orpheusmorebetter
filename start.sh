#!/bin/sh
set -e

PUID=${PUID:-99}
PGID=${PGID:-100}
UMASK=${UMASK:-002}
TZ=${TZ:-UTC}

# Set timezone if specified
if [ -n "$TZ" ] && [ -f "/usr/share/zoneinfo/$TZ" ]; then
    export TZ
fi

log() {
    printf '%s - %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >&2
}

log "═══════════════════════════════════════════════════════"
log "🔄 Starting OrpheusMoreBetter..."

if [ -f /app/version.txt ]; then
    VERSION=$(cat /app/version.txt)
    BRANCH=$(cat /app/branch.txt 2>/dev/null || echo "unknown")
    log "📦 Version: ${VERSION} (${BRANCH})"
fi

log "📋 User Configuration: PUID=${PUID} PGID=${PGID} UMASK=${UMASK}"

if [ "${PUID}" -eq 0 ] 2>/dev/null; then
    log "⚠️  WARNING: Running as root (PUID=0) is not recommended!"
    sleep 2
fi

if ! getent group "${PGID}" > /dev/null 2>&1; then
    log "Creating group with GID ${PGID}"
    addgroup -g "${PGID}" appgroup || {
        log "❌ Failed to create group with GID ${PGID}"
        exit 1
    }
fi
GROUP_NAME=$(getent group "${PGID}" | cut -d: -f1)

if ! getent passwd "${PUID}" > /dev/null 2>&1; then
    log "Creating user with UID ${PUID}"
    adduser -D -u "${PUID}" -G "${GROUP_NAME}" -h /config -s /sbin/nologin appuser || {
        log "❌ Failed to create user with UID ${PUID}"
        exit 1
    }
fi

USER_NAME=$(getent passwd "${PUID}" | cut -d: -f1)

mkdir -p /config/.orpheusmorebetter

for cmd in flac lame sox mktorrent; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log "❌ Missing required tool: $cmd"
        exit 1
    fi
done

if [ ! -f /config/.orpheusmorebetter/config ]; then
    log "ℹ️  Config file not found. It will be created on first run."
    log "   Please edit /config/.orpheusmorebetter/config with your credentials."
else
    if grep -qE "^username\s*=\s*$" /config/.orpheusmorebetter/config 2>/dev/null; then
        log "⚠️  Username is empty in config - please add your credentials!"
    fi
fi

log "Setting permissions..."
chown -R "${PUID}:${PGID}" /config 2>/dev/null || true

umask "${UMASK}"

log "───────────────────────────────────────────────────────"
log "✅ Starting application as ${USER_NAME} (UID=${PUID}, GID=${PGID})"
log "───────────────────────────────────────────────────────"

exec su-exec "${PUID}:${PGID}" env \
    HOME=/config \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    python3 -u /app/orpheusmorebetter "$@"
