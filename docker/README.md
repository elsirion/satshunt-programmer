# Docker Build System

Reproducible Android APK builds using Docker.

## Setup

Install Docker:

```bash
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker "$USER"
exec sudo su -l $USER
```

## Quick Start

Build a release APK:
```bash
./docker/build-apk.sh release
```

Build a debug APK:
```bash
./docker/build-apk.sh debug
```

The APK will be output to `build/bolt-card-programmer-<version>-<mode>-<timestamp>.apk`

## Build Options

- `CLEAN=1`: Wipe all build caches (npm, Gradle)
- `REBUILD_IMAGE=1`: Rebuild the Docker image

Example:
```bash
CLEAN=1 REBUILD_IMAGE=1 ./docker/build-apk.sh release
```

## What's Included

The Docker image contains:
- Ubuntu 24.04
- Node.js 20
- OpenJDK 17
- Android SDK with:
  - Build tools 34, 35, 36
  - Platforms 34, 35, 36
  - NDK 27.1.12297006
  - CMake 3.22.1
