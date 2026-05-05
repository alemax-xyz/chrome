## Google Chrome docker image

This image is based on official Google Chrome build with debian libraries and it is built on top of [clover/base](https://hub.docker.com/r/clover/base/).

### Environment variables

| Environment | Default value | Description
| ----------- | ------------- | -----------
| `CHROMEDRIVER_PORT` | `9515` | port to listen on
| `CHROMEDRIVER_ADB_PORT` | _not set_ | adb server port
| `CHROMEDRIVER_URL_BASE` | _not set_ (`/`) | base URL path prefix for commands, e.g. `wd/url`
| `CHROMEDRIVER_LOG_LEVEL` | _not set_ (`WARNING`) | set log level: `ALL`, `DEBUG`, `INFO`, `WARNING`, `SEVERE`, `OFF`
| `CHROMEDRIVER_LOG_PATH` | _not set_ | write server log to file instead of stderr (increases log level to `INFO`)
| `CHROMEDRIVER_APPEND_LOG` | _not set_ | append log file instead of rewriting
| `CHROMEDRIVER_REPLAYABLE` | _not set_ | (experimental) log verbosely and don't truncate long strings so that the log can be replayed
| `CHROMEDRIVER_READABLE_TIMESTAMP` | _not set_ | add readable timestamps to log
| `CHROMEDRIVER_BIDI_MAPPER_PATH` | _not set_ | custom bidi mapper path
| `CHROMEDRIVER_ALLOWED_IPS` | _not set_ | comma-separated allowlist of remote IP addresses which are allowed to connect to ChromeDriver
| `CHROMEDRIVER_WHITELISTED_IPS` | `1` | allow connections from any remote
| `CHROMEDRIVER_ALLOWED_ORIGINS` | `*` | comma-separated allowlist of request origins which are allowed to connect to ChromeDriver (use `*` to allow any host origin)
| `CHROMEDRIVER_DISABLE_DEV_SHM_USAGE` | `1` | do not use /dev/shm (add this switch if seeing errors related to shared memory)
| `CHROME_TIMEOUT` | _not set_ | timeout in seconds to autmatically close dangling chrome browsers _*_
| `CHROME_ARGUMENTS` | `--disable-dev-shm-usage --disable-crash-reporter` | additional (default) chrome command line arguments to pass to the `chrome` binary _*_
| `PUID` | _not set_ | desired user id of the process owner _**_
| `PGID` | _not set_ | desired group id of the process pwner (primary group of the `PUID` user) _**_
| `PUSER` | _not set_ | desired `PUID` user name _**_
| `PGROUP` | _not set_ | desired `PGID` group name _**_
| `CRON` | _not set_ (`0`) | will start _cron_ inside the container if set to `1`
| `TZ` / `TIMEZONE` | _not set_ (`UTC`) | desired container timezone

_*_ `/opt/google/chrome/google-chrome` is a wrapper around `/opt/google/chrome/chrome` binary that will be used by the `chromedriver` to launch the browser.
It forcibly passes `--headless` and `--disable-gpu` arguments to the `chrome` binary.
To override this behaviour pass `/opt/google/chrome/chrome` as a binary to the `chromedriver`:

    ChromeOptions options = new ChromeOptions();
    options.setBinary("/opt/google/chrome/chrome");

Wrapper also supports `CHROME_ARGUMENTS` environment variable to define additional (default) set of command line arguments.
Each argument may be overidden if passed to the `chromedriver`:

    options.addArguments("--window-size=1920,1080");

`chromedriver` does not close browsers on its own. If client craches before sending `quit` signal, browser will never be closed.
To prevent this wrapper has `CHROME_TIMEOUT` environment variable that will set the execution cap of the `chrome` binary.
This parameter is also available as an additional non-standard `--process-timeout={seconds}` command line argument.
`CHROME_TIMEOUT` is not set by default. If set to any positive non-zero value will cap execution time of each browser separately,
 unless command line argument is specified:

    options.addArguments("--process-timeout=60");

To disable execution time capping set it to zero (`0`).

_**_ There are three options to launch `chrome` in the docker:

 * as `root` user with `--no-sandbox` argument;
 * as non-`root` user with `SYS_ADMIN` docker capability (`--cap-add=SYS_ADMIN`);
 * as non-`root` user with `--no-sandbox` argument;

By default, `chromedriver` will be running as `chrome` user (`PUID=50`, `PGID=50`).
To launch under `root` specify `PUID=0`, `PGID=0`.
Custom `PUID`/`PGID` could be used to preserve data volume ownership on host.
Custom `PUSER`/`PGROUP` could be used to specify user and group names.

### Exposed ports

| Port                             | Description
| -------------------------------- | -----------
| `CHROMEDRIVER_PORT` (`9515`)     | TCP port _chromedriver_ is listening on

### Supported platforms

 * `linux/amd64`;
