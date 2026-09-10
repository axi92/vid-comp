# Video Converter Docker Setup

This directory contains Docker configuration for the video conversion script (`convert.sh`).

## Files

- **Dockerfile** - Builds the container image with Ubuntu 26.04, FFmpeg, and ab-av1
- **entrypoint.sh** - Main entrypoint script that handles file discovery and conversion
- **docker-compose.yml** - Optional compose file for easier container management
- **.dockerignore** - Excludes unnecessary files from the build context

## Usage

### Build the image

```bash
docker build -t vid-comp:latest .
```

### Run with docker

```bash
# Basic usage with default settings (min-vmaf=94)
docker run --rm \
  -u 1000:1000 \
  -v "/path/to/input/videos:/input:ro" \
  -v "/path/to/output:/output" \
  vid-comp:latest

# With custom min-vmaf and file pattern
docker run --rm \
  -u 1000:1000 \
  -e MIN_VMAF=90 \
  -e FILE_PATTERN="*.mp4|*.mkv|*.avi" \
  -e EXCLUDE_PATTERN="none" \
  -v "/path/to/input:/input:ro" \
  -v "/path/to/output:/output" \
  vid-comp:latest
```

### Run with docker-compose

Create a `.env` file:

```env
INPUT_MOUNT=/path/to/input/videos
OUTPUT_MOUNT=/path/to/output
MIN_VMAF=94
FILE_PATTERN=*.mp4|*.mkv
EXCLUDE_PATTERN=*.x265.mkv
UID=1000
GID=1000
```

Then run:

```bash
docker-compose up --build
docker-compose run --rm vid-comp
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `INPUT_DIR` | `/input` | Input directory path in container |
| `OUTPUT_DIR` | `/output` | Output directory path in container |
| `MIN_VMAF` | `94` | Minimum VMAF score for conversion |
| `FILE_PATTERN` | `*.mp4\|*.mkv` | Pipe-separated file patterns to include |
| `EXCLUDE_PATTERN` | `*.x265.mkv` | Pattern to exclude (use `none` to disable) |
| `UID` | `1000` | User ID for the container user |
| `GID` | `1000` | Group ID for the container user |

## Volume Mounts

- **Input** (`/input`): Read-only mount for your source videos
- **Output** (`/output`): Writable mount for converted files (preserves directory structure)

## User

The container runs as user `1000:1000` by default (matching many Linux systems).

## Overriding the Entrypoint

The container uses `entrypoint.sh` as its entrypoint. To run commands directly (e.g., for debugging), use `--entrypoint`:

```bash
# Get help for ab-av1
docker run --rm --entrypoint "" vid-comp:latest ab-av1 --help

# Start a shell
docker run --rm --entrypoint "" -it vid-comp:latest bash
```
