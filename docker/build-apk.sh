#!/usr/bin/env bash
set -e

# This script builds the Docker image and then builds the APK
# Run from the project root: ./docker/build-apk.sh [debug|release]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_MODE="${1:-release}"

if [[ "$BUILD_MODE" != "debug" && "$BUILD_MODE" != "release" ]]; then
    echo "Error: Build mode must be 'debug' or 'release'"
    echo "Usage: $0 [debug|release]"
    exit 1
fi

echo "==================================="
echo "Bolt Card Programmer Docker Build"
echo "==================================="
echo "Project root: $PROJECT_ROOT"
echo "Build mode: $BUILD_MODE"
echo ""

# Show build configuration
echo "Build configuration:"
if [[ "${REBUILD_IMAGE}" == "1" ]]; then
    echo "  - REBUILD_IMAGE=1: Rebuilding Docker image"
else
    echo "  - Using existing Docker image (set REBUILD_IMAGE=1 to rebuild)"
fi

if [[ "${CLEAN}" == "1" ]]; then
    echo "  - CLEAN=1: Wiping all build caches (npm, Gradle)"
    rm -rf "$PROJECT_ROOT/.docker-cache"
else
    echo "  - Using incremental build caches (set CLEAN=1 to wipe)"
fi

# Check for release signing configuration
KEYSTORE_MOUNT=""
KEYSTORE_ENV=""
if [[ "$BUILD_MODE" == "release" ]]; then
    if [[ -n "${KEYSTORE_FILE}" && -f "${KEYSTORE_FILE}" ]]; then
        echo "  - Using keystore: ${KEYSTORE_FILE}"
        KEYSTORE_MOUNT="-v $(realpath "${KEYSTORE_FILE}"):/keystore/release.keystore:ro"
        KEYSTORE_ENV="-e KEYSTORE_FILE=/keystore/release.keystore"
    else
        echo "  - WARNING: No keystore configured, building unsigned APK"
        echo "    Set KEYSTORE_FILE, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_PASSWORD for signed builds"
    fi
fi
echo ""

# Create cache directories (owned by current user)
mkdir -p "$PROJECT_ROOT/.docker-cache/gradle"
mkdir -p "$PROJECT_ROOT/.docker-cache/npm"

# Build the Docker image if it doesn't exist or if forced
IMAGE_NAME="bolt-card-programmer-builder"

if ! docker image inspect $IMAGE_NAME &> /dev/null || [[ "${REBUILD_IMAGE}" == "1" ]]; then
    echo "Building Docker image..."
    docker build -t $IMAGE_NAME "$SCRIPT_DIR"
    echo ""
else
    echo "Using existing Docker image: $IMAGE_NAME"
    echo ""
fi

echo "Starting build in Docker container..."
docker run --rm \
    --user "$(id -u):$(id -g)" \
    -v "$PROJECT_ROOT:/workspace" \
    -v "$PROJECT_ROOT/.docker-cache/gradle:/gradle-cache" \
    -v "$PROJECT_ROOT/.docker-cache/npm:/npm-cache" \
    $KEYSTORE_MOUNT \
    -w /workspace \
    -e CLEAN="${CLEAN}" \
    -e GRADLE_USER_HOME="/gradle-cache" \
    -e npm_config_cache="/npm-cache" \
    -e HOME="/workspace" \
    -e ANDROID_KEYSTORE_PASSWORD="${ANDROID_KEYSTORE_PASSWORD}" \
    -e ANDROID_KEY_PASSWORD="${ANDROID_KEY_PASSWORD}" \
    $KEYSTORE_ENV \
    $IMAGE_NAME \
    bash /workspace/docker/entrypoint.sh "$BUILD_MODE"
