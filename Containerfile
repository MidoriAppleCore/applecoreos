
## 1. BUILD ARGS
ARG SOURCE_IMAGE="base"
ARG SOURCE_SUFFIX="-nvidia"
ARG SOURCE_TAG="latest"

## 2. SOURCE IMAGE
FROM ghcr.io/ublue-os/${SOURCE_IMAGE}${SOURCE_SUFFIX}:${SOURCE_TAG}

## 3. MODIFICATIONS
COPY build.sh /tmp/build.sh
COPY wallpaper.jpg /tmp/wallpaper.jpg

RUN chmod +x /tmp/build.sh && /tmp/build.sh
