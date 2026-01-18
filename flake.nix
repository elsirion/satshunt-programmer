{
  description = "Bolt Card Programmer - Expo React Native Android development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        buildToolsVersion = "36.0.0";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [ buildToolsVersion "35.0.0" "34.0.0" ];
          platformVersions = [ "36" "35" "34" ];
          abiVersions = [ "arm64-v8a" "x86_64" ];
          includeNDK = true;
          ndkVersions = [ "27.1.12297006" "26.1.10909125" ];
          cmakeVersions = [ "3.22.1" ];
          includeEmulator = false;
          includeSystemImages = false;
          includeSources = false;
        };

        androidSdk = androidComposition.androidsdk;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Node.js environment
            nodejs_20
            corepack

            # Java for Android builds
            jdk17

            # Android SDK
            androidSdk

            # Watchman for file watching (React Native)
            watchman

            # Build tools
            gradle

            # Utilities
            git
            which
            gnumake
            gcc
          ];

          shellHook = ''
            export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
            export ANDROID_SDK_ROOT="$ANDROID_HOME"
            export ANDROID_NDK_ROOT="$ANDROID_HOME/ndk/27.1.12297006"
            export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$PATH"
            export JAVA_HOME="${pkgs.jdk17}"

            # Gradle configuration
            export GRADLE_OPTS="-Dorg.gradle.daemon=true"

            echo "Bolt Card Programmer development environment"
            echo ""
            echo "Available commands:"
            echo "  npm install     - Install dependencies"
            echo "  npx expo prebuild --platform android  - Generate android folder"
            echo "  npx expo run:android  - Build and run on device/emulator"
            echo "  cd android && ./gradlew assembleRelease  - Build release APK"
            echo ""
            echo "Environment:"
            echo "  Node.js: $(node --version)"
            echo "  Java:    $(java -version 2>&1 | head -n 1)"
            echo "  Android SDK: $ANDROID_HOME"
          '';

          JAVA_HOME = "${pkgs.jdk17}";
        };
      });
}
