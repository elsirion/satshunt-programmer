FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_NDK_HOME=/opt/android-sdk/ndk/27.1.12297006
ENV PATH="/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    openjdk-17-jdk \
    cmake \
    ninja-build \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Install Android SDK command-line tools
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools \
    && cd $ANDROID_SDK_ROOT/cmdline-tools \
    && curl -o commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
    && unzip commandlinetools.zip \
    && rm commandlinetools.zip \
    && mv cmdline-tools latest

RUN yes | sdkmanager --licenses \
    && sdkmanager \
        "ndk;27.1.12297006" \
        "platform-tools" \
        "platforms;android-34" \
        "platforms;android-35" \
        "platforms;android-36" \
        "build-tools;34.0.0" \
        "build-tools;35.0.0" \
        "build-tools;36.0.0" \
        "cmake;3.22.1"

WORKDIR /workspace

CMD ["/bin/bash"]
