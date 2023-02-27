#!/bin/sh

exec sudo -u "$PUSER" -g "$PGROUP" /opt/google/chrome/chromedriver \
	--disable-dev-shm-usage \
	--whitelisted-ips \
	--enable-chrome-logs \
	--port=${CHROMEDRIVER_PORT:-9515} \
	--log-level=${CHROMEDRIVER_LOG_LEVEL:-WARNING} \
	--url-base=${CHROMEDRIVER_URL_BASE:-/}
