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

ENV LANG=C.UTF-8 \
    SANDBOX_ROOT=/

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y wget openssl ca-certificates

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y unzip

ADD https://github.com/alemax-xyz/misc-tools.git#main /usr/local/bin/

RUN mkdir -p /build /rootfs

WORKDIR /build

COPY build/ .

COPY --from=clover/common:latest /var/lib/packages/ var/lib/packages/

RUN apt-sandbox --install --verstamp \
        --apt-config \
            APT::Install-Recommends=false \
            APT::Get::Upgrade==false \
        --repository . \
        --keyring . \
        --installed var/lib/packages \
        --obsolete packages.obsolete \
        --required packages.required

# https://googlechromelabs.github.io/chrome-for-testing/#stable
RUN wget -O chromedriver.zip https://storage.googleapis.com/chrome-for-testing-public/147.0.7727.57/linux64/chromedriver-linux64.zip

WORKDIR /rootfs

RUN unzip -d opt/google /build/chromedriver.zip \
 && mv opt/google/chromedriver-linux64/chromedriver opt/google/chrome/ \
 && rm -rf opt/google/chromedriver-linux64

RUN rm -rf \
    etc/X11 \
    etc/cron* \
    etc/fonts/conf.d/README \
    etc/sensors.d/.placeholder \
    usr/share/X11 \
    usr/share/appdata \
    usr/share/applications \
    usr/share/bug \
    usr/share/doc \
    usr/share/doc-base \
    usr/share/gnome-control-center \
    usr/share/lintian \
    usr/share/locale \
    usr/share/man \
    usr/share/pkgconfig \
    opt/google/chrome/cron \
    opt/google/chrome/CHROME_VERSION_EXTRA \
    opt/google/chrome/*.png \
    opt/google/chrome/default-app-block \
 && sed -i -E \
        -e 's,^[[:space:]]*[#].*$,,g' \
        -e '/^[[:space:]]*$/d' \
        etc/gtk-3.0/*.conf \
        etc/sensors3.conf \
 && sed -i -E -z \
        -e 's,<!--([^-]*|-[^-]|--[^>])*-->,,g' \
        -e 's/[[:space:]]+\n/\n/g' \
        -e 's/\n\n+/\n/g' \
        etc/fonts/fonts.conf \
        usr/share/fontconfig/conf.avail/*.conf \
        usr/share/xml/fontconfig/fonts.dtd \
 && ln -s /opt/google/chrome/google-chrome usr/bin/google-chrome

COPY --from=base /etc/group /etc/gshadow /etc/passwd /etc/shadow etc/

COPY rootfs/ .

WORKDIR /

FROM clover/common

ENV LANG=C.UTF-8 \
    CHROMEDRIVER_PORT=9515 \
    CHROMEDRIVER_DISABLE_DEV_SHM_USAGE=1 \
    CHROMEDRIVER_WHITELISTED_IPS=1 \
    CHROMEDRIVER_ALLOWED_ORIGINS=* \
    CHROME_ARGUMENTS="--disable-dev-shm-usage --disable-crash-reporter"

COPY --from=build /rootfs /

EXPOSE ${CHROMEDRIVER_PORT:-0}
