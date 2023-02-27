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

FROM library/debian:unstable-slim AS build

ENV LANG=C.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y \
        software-properties-common \
        apt-utils

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y \
        wget \
        gnupg \
        unzip

RUN export DEBIAN_FRONTEND=noninteractive \
 && wget -qO - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/chrome.list \
 && apt-get update

RUN mkdir -p /build /rootfs
WORKDIR /build
RUN apt-get download \
    libudev1 \
    libx11-xcb1 \
    libasound2 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libatspi2.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
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
    libgnutls30 \
    libgmp10 \
    libhogweed6 \
    libp11-kit0 \
    libtasn1-6 \
    libunistring2 \
    libcom-err2 \
    libk5crypto3 \
    libkrb5-3 \
    libkrb5support0 \
    libidn2-0 \
    libldap-2.5-0 \
    libgssapi3-heimdal \
    libasn1-8-heimdal \
    libhcrypto5-heimdal \
    libheimbase1-heimdal \
    libheimntlm0-heimdal \
    libwind0-heimdal \
    libkrb5-26-heimdal \
    libhx509-5-heimdal \
    libsqlite3-0 \
    libroken19-heimdal \
    libsasl2-2 \
    libsasl2-modules-db \
    libldap-common \
    libnettle8 \
    libavahi-common3 \
    libavahi-client3 \
    libsystemd0 \
    libmount1 \
    libfontconfig1 \
    libpangoft2-1.0-0 \
    libfreetype6 \
    libthai0 \
    libpixman-1-0 \
    libpng16-16 \
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
    libflac12 \
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
    libcurl4 \
    libnghttp2-14 \
    librtmp1 \
    libssh2-1 \
    libpsl5 \
    fontconfig-config \
    libunwind8 \
    libx11-data \
    fonts-liberation \
    google-chrome-stable
RUN find *.deb | xargs -I % dpkg-deb -x % /rootfs \
 && rm -Rf *.deb
RUN wget -O chromedriver.zip https://chromedriver.storage.googleapis.com/110.0.5481.77/chromedriver_linux64.zip \
 && unzip -d /rootfs/opt/google/chrome chromedriver.zip

WORKDIR /rootfs
RUN rm -rf \
    usr/share/X11 \
    usr/share/appdata \
    usr/share/applications \
    usr/share/bug \
    usr/share/doc \
    usr/share/doc-base \
    usr/share/gnome-control-center \
    usr/share/lintian \
    usr/share/man \
    usr/share/menu \
    etc/cron* \
    opt/google/chrome/cron \
    opt/google/chrome/*.png \
    opt/google/chrome/*.xpm \
    opt/google/chrome/default-app-block \
    opt/google/chrome/xdg-*
COPY --from=base /etc/group /etc/gshadow /etc/passwd /etc/shadow etc/
COPY init/ /rootfs/etc/init/
COPY machine-id /rootfs/etc/
COPY google-chrome /rootfs/opt/google/chrome/
RUN chmod a+x /rootfs/opt/google/chrome/google-chrome \
 && ln -s /opt/google/chrome/google-chrome /rootfs/usr/bin/google-chrome

WORKDIR /


FROM clover/common

ENV LANG=C.UTF-8
ENV CHROME_ARGUMENTS="--disable-dev-shm-usage --disable-crash-reporter"

COPY --from=build /rootfs /

EXPOSE ${CHROMEDRIVER_PORT:-9515}
