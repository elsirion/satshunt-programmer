#!/bin/bash
set -e

# This script builds the APK inside the Docker container

echo "==================================="
echo "Building Bolt Card Programmer APK"
echo "==================================="

BUILD_MODE="${1:-release}"

if [[ "$BUILD_MODE" != "debug" && "$BUILD_MODE" != "release" ]]; then
    echo "Error: Build mode must be 'debug' or 'release'"
    echo "Usage: $0 [debug|release]"
    exit 1
fi

echo "Build mode: $BUILD_MODE"
echo ""

# Conditional cleaning based on CLEAN flag
if [[ "${CLEAN}" == "1" ]]; then
    echo "CLEAN=1 enabled - wiping all build caches..."
    rm -rf android/.gradle android/build android/app/build
    rm -rf node_modules
else
    echo "Quick build - using incremental build caches..."
fi
echo ""

# Install npm dependencies
echo "Installing npm dependencies..."
npm install

# Generate android folder if it doesn't exist
if [ ! -d "android" ]; then
    echo "Generating android folder with expo prebuild..."
    npx expo prebuild --platform android
fi

# Generate local.properties with correct SDK/NDK paths for Docker environment
echo "Generating local.properties..."
cat > android/local.properties << EOF
sdk.dir=$ANDROID_SDK_ROOT
ndk.dir=$ANDROID_NDK_HOME
EOF

# Keystore is expected at project root: my-upload-key.keystore
# Passwords come from ANDROID_KEYSTORE_PASSWORD and ANDROID_KEY_PASSWORD env vars
if [[ "$BUILD_MODE" == "release" ]]; then
    if [[ -f "my-upload-key.keystore" ]]; then
        echo "Using keystore: my-upload-key.keystore"
    else
        echo "WARNING: Keystore not found, release build may fail"
    fi
fi

# Build APK
echo "Building Android APK..."
cd android

if [[ "$BUILD_MODE" == "release" ]]; then
    ./gradlew assembleRelease
    APK_PATH="app/build/outputs/apk/release/app-release.apk"
    # Also check for unsigned APK if signing failed
    if [[ ! -f "$APK_PATH" && -f "app/build/outputs/apk/release/app-release-unsigned.apk" ]]; then
        APK_PATH="app/build/outputs/apk/release/app-release-unsigned.apk"
        echo "WARNING: Built unsigned APK (signing not configured)"
    fi
else
    ./gradlew assembleDebug
    APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
fi

cd ..

# Get version from app.config.ts
VERSION=$(grep -oP 'version:\s*"\K[^"]+' app.config.ts 2>/dev/null || echo "0.0.0")
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Copy APK to project root with versioned name
OUTPUT_DIR="build"
mkdir -p "$OUTPUT_DIR"
OUTPUT_APK="$OUTPUT_DIR/bolt-card-programmer-${VERSION}-${BUILD_MODE}-${TIMESTAMP}.apk"
cp "android/$APK_PATH" "$OUTPUT_APK"

echo ""
echo "==================================="
echo "Build complete!"
echo "==================================="
echo "APK: $OUTPUT_APK"
echo ""
