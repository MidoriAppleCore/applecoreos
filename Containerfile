
## 1. BUILD ARGS
ARG SOURCE_IMAGE="base"
ARG SOURCE_SUFFIX="-asus-nvidia"
ARG SOURCE_TAG="latest"

## 2. SOURCE IMAGE
FROM ghcr.io/ublue-os/${SOURCE_IMAGE}${SOURCE_SUFFIX}:${SOURCE_TAG}

## 3. MODIFICATIONS
COPY build.sh /tmp/build.sh
COPY wallpaper.jpg /tmp/wallpaper.jpg
COPY install_firefox.sh /etc/install_firefox.sh

RUN chmod +x /tmp/build.sh /etc/install_firefox.sh && /tmp/build.sh
