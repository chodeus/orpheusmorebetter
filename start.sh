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
    log "ℹ️  Config file not found. Creating default config..."
    cat > /config/.orpheusmorebetter/config << 'CONFIGEOF'
[orpheus]
username =
password =
data_dir = /data/torrents
output_dir = /data/torrents
torrent_dir = /data/torrents
formats = flac, v0, 320
media = sacd, soundboard, web, dvd, cd, dat, vinyl, blu-ray
24bit_behaviour = 0
tracker = https://home.opsfet.ch/
api = https://orpheus.network/
mode = both
source = OPS
CONFIGEOF
    log "📝 Default config created at /config/.orpheusmorebetter/config"
    log "⚠️  Please edit with your credentials and restart the container!"
    exit 0
else
    if grep -qE "^username\s*=\s*$" /config/.orpheusmorebetter/config 2>/dev/null; then
        log "⚠️  Username is empty in config - please add your credentials!"
    fi
fi

log "Setting permissions..."
chown -R "${PUID}:${PGID}" /config 2>/dev/null || true

umask "${UMASK}"

log "───────────────────────────────────────────────────────"

# Change to /config so logs directory is created there (not in /app)
cd /config

# Clean up old logs, keep only the last 5
if [ -d /config/logs ]; then
    find /config/logs -name "*.txt" -type f | sort -r | tail -n +6 | xargs rm -f 2>/dev/null || true
fi

# Create a convenience wrapper so console users can just type:
#   orpheusmorebetter -m both -t 123456
# instead of the full su-exec/python3 path
cat > /usr/local/bin/orpheusmorebetter << WRAPEOF
#!/bin/sh
cd /config
exec su-exec ${PUID}:${PGID} env \
    HOME=/config \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    python3 -u /app/orpheusmorebetter "\$@"
WRAPEOF
chmod +x /usr/local/bin/orpheusmorebetter

# Strip the command name if passed (e.g. Post Arguments: "orpheusmorebetter -t 123456")
# since start.sh already calls the python script directly
if [ "$1" = "orpheusmorebetter" ]; then
    shift
fi

if [ $# -gt 0 ]; then
    # Post Arguments provided — run the command and exit
    log "✅ Running as ${USER_NAME} (UID=${PUID}, GID=${PGID})"
    log "───────────────────────────────────────────────────────"
    exec su-exec "${PUID}:${PGID}" env \
        HOME=/config \
        PYTHONUNBUFFERED=1 \
        PYTHONDONTWRITEBYTECODE=1 \
        python3 -u /app/orpheusmorebetter "$@"
else
    # No arguments — idle and wait for console commands
    log "✅ Container ready — idle mode (UID=${PUID}, GID=${PGID})"
    log "───────────────────────────────────────────────────────"
    log ""
    log "To run commands, open the Unraid console and type:"
    log "  orpheusmorebetter              (full scan using config mode)"
    log "  orpheusmorebetter -m snatched  (scan snatched only)"
    log "  orpheusmorebetter -t 123456    (with TOTP code)"
    log "  orpheusmorebetter --help       (see all options)"
    log ""
    log "═══════════════════════════════════════════════════════"
    # Keep container alive
    exec tail -f /dev/null
fi
