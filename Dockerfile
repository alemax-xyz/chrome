FROM clover/base AS base

RUN groupadd \
        --gid 50 \
        --system \
        chrome \
 && useradd \
        --home-dir /tmp \
        --no-create-home \
        --system \
        --shell /bin/false \
        --uid 50 \
        --gid 50 \
        chrome

FROM library/debian:stable-slim AS build

ENV LANG=C.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y \
        apt-utils

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y \
        wget \
        unzip \
        gnupg

#RUN export DEBIAN_FRONTEND=noninteractive \
# && echo "deb [arch=amd64,trusted=yes] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/chrome.list \
# && apt-get update

RUN mkdir -p /build /rootfs/opt/google
WORKDIR /build
RUN apt-get download \
    libatomic1 \
    libudev1 \
    libx11-xcb1 \
    libasound2t64 \
    libatk1.0-0t64 \
    libatk-bridge2.0-0t64 \
    libatspi2.0-0t64 \
    libcairo2 \
    libcups2t64 \
    libdbus-1-3 \
    libexpat1 \
    libgdk-pixbuf-2.0-0 \
    libglib2.0-0t64 \
    libgtk-3-0t64 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libuuid1 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    libxau6 \
    libxdmcp6 \
    libffi8 \
    libgssapi-krb5-2 \
    libgnutls30t64 \
    libgmp10 \
    libhogweed6t64 \
    libp11-kit0 \
    libtasn1-6 \
    libunistring5 \
    libcom-err2 \
    libk5crypto3 \
    libkrb5-3 \
    libkrb5support0 \
    libidn2-0 \
    libldap2 \
    libgssapi3t64-heimdal \
    libasn1-8t64-heimdal \
    libhcrypto5t64-heimdal \
    libheimbase1t64-heimdal \
    libheimntlm0t64-heimdal \
    libwind0t64-heimdal \
    libkrb5-26t64-heimdal \
    libhx509-5t64-heimdal \
    libsqlite3-0 \
    libroken19t64-heimdal \
    libsasl2-2 \
    libsasl2-modules-db \
    libldap-common \
    libnettle8t64 \
    libavahi-common3 \
    libavahi-client3 \
    libsystemd0 \
    libmount1 \
    libfontconfig1 \
    libpangoft2-1.0-0 \
    libfreetype6 \
    libthai0 \
    libpixman-1-0 \
    libpng16-16t64 \
    libxcb-shm0 \
    libxcb-render0 \
    libcairo-gobject2 \
    libepoxy0 \
    libxinerama1 \
    libxkbcommon0 \
    libwayland-cursor0 \
    libwayland-egl1 \
    libwayland-client0 \
    libbsd0 \
    liblzma5 \
    liblz4-1 \
    libgcrypt20 \
    libblkid1 \
    libharfbuzz0b \
    libdatrie1 \
    libkeyutils1 \
    libgpg-error0 \
    libgraphite2-3 \
    libpulse0 \
    libwrap0 \
    libsndfile1 \
    libasyncns0 \
    libflac14 \
    libogg0 \
    libvorbis0a \
    libvorbisenc2 \
    libmd0 \
    libdrm2 \
    libgbm1 \
    libwayland-server0 \
    libfribidi0 \
    libzstd1 \
    libbrotli1 \
    libcurl4t64 \
    libnghttp2-14 \
    librtmp1 \
    libssh2-1t64 \
    libpsl5t64 \
    fontconfig-config \
    libunwind8 \
    libx11-data \
    fonts-liberation
RUN find *.deb | xargs -I % dpkg-deb -x % /rootfs \
 && rm -Rf *.deb

# https://googlechromelabs.github.io/chrome-for-testing/#stable
RUN wget -O chrome.zip https://storage.googleapis.com/chrome-for-testing-public/147.0.7727.57/linux64/chrome-linux64.zip \
 && wget -O chromedriver.zip https://storage.googleapis.com/chrome-for-testing-public/147.0.7727.57/linux64/chromedriver-linux64.zip


WORKDIR /rootfs

RUN unzip -d opt/google /build/chrome.zip \
 && mv opt/google/chrome-linux64 opt/google/chrome \
 && unzip -d opt/google /build/chromedriver.zip \
 && mv opt/google/chromedriver-linux64/chromedriver opt/google/chrome/ \
 && rm -rf opt/google/chromedriver-linux64

RUN rm -rf \
    etc/fonts/conf.d/README \
    usr/share/X11 \
    usr/share/appdata \
    usr/share/applications \
    usr/share/bug \
    usr/share/doc \
    usr/share/doc-base \
    usr/share/gnome-control-center \
    usr/share/libgcrypt20 \
    usr/share/lintian \
    usr/share/locale \
    usr/share/man \
    usr/share/menu \
    etc/cron* \
    opt/google/chrome/WidevineCdm/LICENSE \
    opt/google/chrome/ABOUT \
    opt/google/chrome/chrome-wrapper \
    opt/google/chrome/cron \
    opt/google/chrome/*.png \
    opt/google/chrome/*.xpm \
    opt/google/chrome/*.deps \
    opt/google/chrome/default-app-block \
    opt/google/chrome/xdg-* \
 && echo > etc/ldap/ldap.conf \
 && echo > etc/pulse/client.conf

COPY --from=base /etc/group /etc/gshadow /etc/passwd /etc/shadow etc/

COPY etc/ etc/
COPY opt/ opt/
RUN mkdir -p usr/bin \
 && ln -s /opt/google/chrome/google-chrome usr/bin/google-chrome

WORKDIR /


FROM clover/common

ENV LANG=C.UTF-8
ENV CHROME_ARGUMENTS="--disable-dev-shm-usage --disable-crash-reporter"

COPY --from=build /rootfs /

EXPOSE ${CHROMEDRIVER_PORT:-9515}
