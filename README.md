# orpheusmorebetter Docker

Docker container for [orpheusmorebetter](https://github.com/CHODEUS/orpheusmorebetter) - automatic transcode uploader for Orpheus.

This is a Docker implementation of the orpheusmorebetter script.

## Features

- Based on Python 3.13 alpine image
- Includes all required dependencies (mktorrent, flac, lame, sox)
- Runs as non-root user for security
- Configurable volume mounts for data, output, and torrents

## Quick Start

### 1. Install Container

### 2. Edit configuration

Edit `~/orpheus/config/.orpheusmorebetter/config` with your Orpheus credentials and paths:

```ini
[orpheus]
username = YOUR_USERNAME
password = YOUR_PASSWORD
data_dir = /data
output_dir = /output
torrent_dir = /torrents
formats = flac, v0, 320
media = cd, vinyl, web
24bit_behaviour = 0
tracker = https://home.opsfet.ch/
api = https://orpheus.network
mode = both
source = OPS
```

### 3. Run the container

```bash
docker run --rm \
  -v ~/orpheus/config:/config \
  -v ~/orpheus/cache:/cache \
  -v /path/to/your/flac/files:/data:ro \
  -v /path/to/output:/output \
  -v /path/to/watch/folder:/torrents \
  chodeus/orpheusmorebetter:latest
```

## Usage

### Scan all snatches and uploads

```bash
docker run --rm \
  -v ~/orpheus/config:/config \
  -v ~/orpheus/cache:/cache \
  -v /path/to/flacs:/data:ro \
  -v /path/to/output:/output \
  -v /path/to/watch:/torrents \
  chodeus/orpheusmorebetter:latest
```

### Transcode a specific release

```bash
docker run --rm \
  -v ~/orpheus/config:/config \
  -v ~/orpheus/cache:/cache \
  -v /path/to/flacs:/data:ro \
  -v /path/to/output:/output \
  -v /path/to/watch:/torrents \
  chodeus/orpheusmorebetter:latest \
  "https://orpheus.network/torrents.php?id=1000&torrentid=1000000"
```

### Additional options

```bash
# Use 4 threads for transcoding
docker run --rm ... chodeus/orpheusmorebetter:latest -j 4

# Don't upload (test mode)
docker run --rm ... chodeus/orpheusmorebetter:latest -U

# With 2FA TOTP
docker run --rm ... chodeus/orpheusmorebetter:latest -t 123456
```

## Unraid Setup

### 1. Add Container in Unraid Web UI

1. Go to **Docker** tab
2. Click **Add Container**
3. Configure:

**Basic Unraid Template:**
```<?xml version="1.0"?>
<Container version="2">
  <Name>orpheusmorebetter</Name>
  <Repository>chodeus/orpheusmorebetter:latest</Repository>
  <Registry>https://hub.docker.com/r/chodeus/orpheusmorebetter</Registry>
  <Network>bridge</Network>
  <Privileged>false</Privileged>
  <Support>https://github.com/CHODEUS/orpheusmorebetter</Support>
  <Project>https://github.com/CHODEUS/orpheusmorebetter</Project>
  <Overview>CLI-only container to automatically transcode and upload FLACs to orpheus.network. No web UI or listening ports. Configure via files under the /config mount (HOME).</Overview>
  <Category>Other</Category>
  <WebUI/>
  <Icon/>
  <ExtraParams/>
  <PostArgs/>
  <CPUset/>
  <DateInstalled>1762235398</DateInstalled>
  <DonateText/>
  <DonateLink/>
  <Requires>Edit the configuration files under the mapped /config path (default: /mnt/user/appdata/orpheusmorebetter) before running. This container expects directories: /config (HOME), /cache, /data, /output and /torrents.</Requires>

  <Config Name="Host Path for /config" Target="/config" Default="/mnt/user/appdata/orpheusmorebetter" Mode="rw" Description="Container HOME and persistent configuration. The app stores ~/.orpheusmorebetter here." Type="Path" Display="always" Required="true" Mask="false">/mnt/cache/appdata/orpheusmorebetter</Config>
  <Config Name="Host Path for /data (input)" Target="/data" Default="" Mode="rw" Description="Input directory for music files to be processed." Type="Path" Display="always" Required="true" Mask="false">/mnt/user/data/torrents/music/</Config>
  <Config Name="Host Path for /torrents" Target="/torrents" Default="" Mode="rw" Description="Torrent/watch directory (torrent_dir in config)." Type="Path" Display="always" Required="true" Mask="false">/mnt/user/data/torrents/rips</Config>
  <Config Name="TZ" Target="TZ" Default="Etc/UTC" Mode="" Description="Timezone (e.g. America/New_York)" Type="Variable" Display="advanced" Required="false" Mask="false">Australia/Perth</Config>
  <Config Name="UMASK" Target="UMASK" Default="022" Mode="" Description="Optional umask for created files (if supported by the container)" Type="Variable" Display="advanced" Required="false" Mask="false">022</Config>
  <Config Name="HOME" Target="HOME" Default="/config" Mode="" Description="Container HOME. The image sets HOME=/config so configuration is under this path." Type="Variable" Display="advanced" Required="false" Mask="false">/config</Config>

  <TailscaleStateDir/>
</Container>
```

**Volume Mappings:**

| Container Path | Host Path | Access Mode |
|---------------|-----------|-------------|
| `/config` | `/mnt/user/appdata/orpheusmorebetter` | Read/Write |
| `/data` | `/mnt/user/path/to/flacs` | Read Only |
| `/output` | `/mnt/user/path/to/output` | Read/Write |
| `/torrents` | `/mnt/user/path/to/watch` | Read/Write |

### 2. Running on Unraid

Since this is a task-based container (not a daemon), you'll run it via container start. The container will stop when it is complete.


## Environment Variables

- `HOME=/config` - Config directory location

## Volumes

- `/config` - Configuration files
- `/data` - Your FLAC source files (read-only recommended)
- `/output` - Transcode output directory
- `/torrents` - Torrent watch directory

## Security Notes

- Container runs as non-root user (UID 99)
- Credentials are stored in config file - keep this volume secure
- Consider using read-only mount for source FLAC directory

## Credits

- Original script: [orpheusmorebetter](https://github.com/walkrflocka/orpheusmorebetter)
- Based on whatbetter-crawler

## License

See the [original project](https://github.com/walkrflocka/orpheusmorebetter) for license information.
