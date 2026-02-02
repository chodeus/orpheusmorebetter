# orpheusmorebetter Docker

[![Build Status](https://github.com/chodeus/orpheusmorebetter/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/chodeus/orpheusmorebetter/actions/workflows/docker-publish.yml)
[![Upstream Sync](https://github.com/chodeus/orpheusmorebetter/actions/workflows/sync-and-build.yml/badge.svg)](https://github.com/chodeus/orpheusmorebetter/actions/workflows/sync-and-build.yml)
[![GitHub Container Registry](https://img.shields.io/badge/GHCR-chodeus%2Forpheusmorebetter-blue?logo=github)](https://github.com/chodeus/orpheusmorebetter/pkgs/container/orpheusmorebetter)
[![License](https://img.shields.io/github/license/chodeus/orpheusmorebetter)](LICENSE)

This is a vibe coded Docker container for **orpheusmorebetter**, an automatic transcode and upload helper for **OPS**.

This repository provides a Dockerized wrapper around the upstream
[`orpheusmorebetter`](https://github.com/walkrflocka/orpheusmorebetter) script.

---

## Features

- Based on **Python 3.13 (Alpine)**
- Includes all required runtime dependencies:
  - **Audio transcoding tools**: `flac`, `lame`, `sox`
  - **Torrent creation**: `mktorrent`
  - **Python libraries**: `mutagen`, `requests`, `beautifulsoup4`, `lxml`, `pydantic`
- Runs as a **non-root user** after initial setup
- Supports configurable **PUID / PGID / UMASK**
- **All upstream command-line options** fully supported
- Designed to work cleanly with:
  - Unraid
  - Seedboxes
  - Headless Linux hosts
- Simple volume-based configuration:
  - `/config` – persistent config and cache
  - `/data/torrents` – source FLACs (match torrent client's container path)

---

## Quick Start

### 1. Pull the Image

```bash
docker pull ghcr.io/chodeus/orpheusmorebetter:latest
```

---

### 2. Configure orpheusmorebetter

The application stores its configuration in `/config/.orpheusmorebetter/`.

On first run, a default config will be created at:

```text
/config/.orpheusmorebetter/config
```

Edit this file with your credentials and preferences:
dir paths provided as an example:

```ini
[orpheus]
username = YOUR_USERNAME
password = YOUR_PASSWORD
data_dir = /data/torrents/music
output_dir = /data/torrents/uploads
torrent_dir = /data/torrents/rips
formats = flac, v0, 320
media = cd, vinyl, web
24bit_behaviour = 0
tracker = https://home.opsfet.ch/
api = https://orpheus.network/
mode = both
source = OPS
```

#### Configuration Options

- **`username`** / **`password`**: Your Orpheus Network credentials
- **`data_dir`**: Where to find source FLAC files
- **`output_dir`**: Where to write transcoded files
- **`torrent_dir`**: Where to save .torrent files
- **`formats`**: Comma-separated list of formats to create
  - Options: `flac`, `v0`, `320`
- **`media`**: Which media types to process
  - Options: `cd`, `vinyl`, `web`, `dvd`, `soundboard`, `sacd`, `dat`, `cassette`, `blu-ray`
- **`24bit_behaviour`**: How to handle 24-bit FLACs
  - `0` = skip, `1` = prompt, `2` = auto-edit
- **`mode`**: How to find candidates
  - Options: `snatched`, `uploaded`, `both`, `seeding`, `all`, `none`
- **`tracker`**: Announce URL (should be `https://home.opsfet.ch/`)
- **`api`**: API endpoint (should be `https://orpheus.network/`)
- **`source`**: Source flag for torrents (typically `OPS`)

Refer to the [upstream project](https://github.com/walkrflocka/orpheusmorebetter) for full configuration details.

---

### 3. Run the Container

#### Automatic Mode (Process Candidates)

```bash
docker run --rm \
  -e PUID=99 \
  -e PGID=100 \
  -e UMASK=002 \
  -v /path/to/config:/config \
  -v /path/to/flacs:/data/torrents:rw \
  ghcr.io/chodeus/orpheusmorebetter:latest
```

This will search for transcode candidates based on your configured `mode` setting.

#### Process Specific Release(s)

```bash
docker run --rm \
  -e PUID=99 \
  -e PGID=100 \
  -e UMASK=002 \
  -v /path/to/config:/config \
  -v /path/to/flacs:/data/torrents:rw \
  ghcr.io/chodeus/orpheusmorebetter:latest \
  "https://orpheus.network/torrents.php?id=1000&torrentid=1000000"
```

You can provide multiple URLs or a text file containing URLs (one per line).

---

## Command-Line Options

All upstream CLI options are fully supported. Pass them after the image name:

### Core Options

| Option | Description |
|--------|-------------|
| `release_urls` | One or more release URLs, or path to file containing URLs |
| `-s, --single` | Only add one format per release (useful for getting unique groups) |
| `-j, --threads N` | Number of threads to use (currently disabled in upstream, defaults to 1) |
| `--config PATH` | Location of config file (default: `~/.orpheusmorebetter/config`) |
| `--cache PATH` | Location of cache file (default: `~/.orpheusmorebetter/cache`) |

### Upload & Processing Options

| Option | Description |
|--------|-------------|
| `-U, --no-upload` | Don't upload new torrents (create files only) |
| `-E, --no-24bit-edit` | Don't try to edit 24-bit torrents mistakenly labeled as 16-bit |
| `-m, --mode MODE` | Mode to search for candidates: `snatched`, `uploaded`, `both`, `seeding`, or `all` |
| `-S, --skip` | Treats a torrent as already processed (adds to cache) |

### Authentication & Source

| Option | Description |
|--------|-------------|
| `-t, --totp CODE` | Time-based one-time password for 2FA |
| `-o, --source VALUE` | Value to put in the source flag in created torrents |

### Other Options

| Option | Description |
|--------|-------------|
| `--version` | Show version and exit |
| `--help` | Show help message and exit |

---

## Docker Compose Example

```yaml
services:
  orpheusmorebetter:
    image: ghcr.io/chodeus/orpheusmorebetter:latest
    container_name: orpheusmorebetter
    environment:
      - PUID=99
      - PGID=100
      - UMASK=002
    volumes:
      - ./config:/config
      - /path/to/flacs:/data/torrents:rw
    # Examples - uncomment and modify as needed:
    # command: -m snatched              # Process all snatched
    # command: -U                       # no upload
    # command: "https://orpheus.network/torrents.php?id=123&torrentid=456"
    restart: "no"
```

This is provided mainly for reference; the container is not intended to be
left running continuously.

---

## Unraid Setup

### Overview

This container is well-suited to Unraid because it:
- Respects `PUID` / `PGID` for proper file ownership
- Stores all state under `/config`
- Runs as a one-shot task (exits when complete)
- No background services or web UI

---

### Unraid Template

The full Unraid template is available at [`unraid-template.xml`](unraid-template.xml).

You can also add it manually in Unraid by using this template URL:
```
https://raw.githubusercontent.com/chodeus/orpheusmorebetter/main/unraid-template.xml
```

---

### Running on Unraid

1. Add the container using the template URL above (or copy the XML)
2. Configure volume paths:
   - **Config Path**: `/mnt/user/appdata/orpheusmorebetter`
   - **Data**: Your torrent data path (e.g., `/mnt/user/data/torrents`)
3. Set your timezone (TZ variable)
4. Start the container - it will create a default config
5. Edit `/config/.orpheusmorebetter/config` with your credentials
6. Restart the container
7. Monitor logs in real-time
8. Container will stop automatically when complete

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | `99` | User ID to run as (99 = `nobody` on Unraid) |
| `PGID` | `100` | Group ID to run as (100 = `users` on Unraid) |
| `UMASK` | `002` | File creation mask (002 = group writable) |

---

## Supported Formats

The container can transcode to the following formats:

- **FLAC** (16-bit lossless)
- **MP3 V0** (VBR ~245kbps)
- **MP3 320** (CBR 320kbps)

Configure which formats to create in your config file using the `formats` setting.

---

## Workflow

1. **Candidate Discovery**: Tool searches Orpheus for releases you've snatched/uploaded that need transcodes
2. **Source Location**: Finds matching FLAC files in `/data` directory
3. **Quality Checks**: Validates tags, detects 24-bit files, checks for multichannel
4. **Transcoding**: Creates missing formats using `flac`, `lame`, and `sox`
5. **Torrent Creation**: Generates .torrent files using `mktorrent`
6. **Upload**: Automatically uploads to Orpheus Network (unless `-U` flag is used)
7. **Caching**: Marks processed torrents to avoid duplicate work

---

## Troubleshooting

### Config file not found

If the container complains about missing config:
1. Run the container once to generate default config
2. Edit `/config/.orpheusmorebetter/config`
3. Add your credentials and paths

### FLAC files not found

- Ensure your source directory is mounted correctly
- Check that filenames match Orpheus naming
- Verify file permissions (should be readable by PUID)

### Permission denied errors

- Check `PUID` and `PGID` match your system
- Verify volume mount permissions
- Ensure `/config` and `/data/torrents` are writable

### Authentication errors

- Verify username and password in config
- If using 2FA, provide TOTP with `-t` flag
- Check API endpoint is correct: `https://orpheus.network/`

---

## Security Notes

- Container briefly runs as root to set up user/permissions, then drops privileges
- Defaults to `99:100` (`nobody:users` on Unraid)
- Credentials are stored in **plaintext** config files — protect `/config` directory
- Avoid setting `PUID=0` unless you understand the security implications

---

## Credits

- **Original project**: [orpheusmorebetter](https://github.com/walkrflocka/orpheusmorebetter) by walkrflocka
- **Based on**: whatbetter-crawler
- **Primary Coder**: my friend Claude.ai

---

## License

See the [upstream project](https://github.com/walkrflocka/orpheusmorebetter) for license information.

---
