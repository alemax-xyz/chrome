set -- /opt/google/chrome/chromedriver
[ -n "$CHROMEDRIVER_PORT" ] && set -- "$@" --port="$CHROMEDRIVER_PORT"
[ -n "$CHROMEDRIVER_ADB_PORT" ] && set -- "$@" --adb-port="$CHROMEDRIVER_ADB_PORT"
[ -n "$CHROMEDRIVER_BASE_URL" ] && set -- "$@" --base_url="$CHROMEDRIVER_BASE_URL"
[ -n "$CHROMEDRIVER_LOG_LEVEL" ] && set -- "$@" --log-level="$CHROMEDRIVER_LOG_LEVEL"
[ -n "$CHROMEDRIVER_LOG_PATH" ] && set -- "$@" --log-path="$CHROMEDRIVER_LOG_PATH"
[ "$CHROMEDRIVER_APPEND_LOG" = 1 ] && set -- "$@" --append-log
[ "$CHROMEDRIVER_REPLAYABLE" = 1 ] && set -- "$@" --replayable
[ "$CHROMEDRIVER_READABLE_TIMESTAMP" = 1 ] && set -- "$@" --readable-timestamp
[ -n "$CHROMEDRIVER_BIDI_MAPPER_PATH" ] && set -- "$@" --bidi-mapper-path="$CHROMEDRIVER_BIDI_MAPPER_PATH"
[ -n "$CHROMEDRIVER_ALLOWED_IPS" ] && set -- "$@" --allowed-ips="$CHROMEDRIVER_ALLOWED_IPS"
[ -n "$CHROMEDRIVER_ALLOWED_ORIGINS" ] && set -- "$@" --allowed-origins="$CHROMEDRIVER_ALLOWED_ORIGINS"
[ "$CHROMEDRIVER_DISABLE_DEV_SHM_USAGE" = 1 ] && set -- "$@" --disable-dev-shm-usage
[ "$CHROMEDRIVER_ENABLE_CHROME_LOGS" = 1 ] && set -- "$@" --enable-chrome-logs
[ "$CHROMEDRIVER_WHITELISTED_IPS" = 1 ] && set -- "$@" --whitelisted-ips

suexec sudo -u "$PUSER" -g "$PGROUP" "$@" &
