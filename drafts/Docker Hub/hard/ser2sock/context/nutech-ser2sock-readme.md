# nutechsoftware/ser2sock README (upstream project)

Source URL(s): https://github.com/nutechsoftware/ser2sock ; https://raw.githubusercontent.com/nutechsoftware/ser2sock/master/README.md (fetched 2026-11-26). Latest README version noted: 1.4.5 (dated 05/04/14).

## What it is
- Serial-to-socket redirector: shares a serial device over TCP/IP; optional SSL via OpenSSL.

## Build/install
- Deps: OpenSSL dev package (needed for SSL support).
- Steps: `autoreconf -f -i`, `./configure`, `make`, `cp ser2sock /usr/local/bin/`, `cp -R etc/ser2sock /etc/`
- Config file: /etc/ser2sock/ser2sock.conf (device, port, etc.)
- Init scripts (init/ser2sock, init.d/systemd not in container scope) not needed for container.

## Usage (flags)
```
ser2sock -p <socket listen port> -s <serial port dev>
  -h, -help            help
  -f <config pathname> override config file pathname
  -p port              socket port to listen on
  -s <serial device>   e.g. /dev/ttyUSB0
  -i IP                bind to IP; default ALL
  -b baudrate          default 9600
  -d                   daemonize
  -0                   raw device mode, no info messages
  -t                   send terminal init string
  -P <PID file>        override PID file path
  -g                   debug level 0-3
  -c                   keep incoming connections when serial device disconnects
  -w milliseconds      delay between serial open attempts (default 5000)
  -e                   use SSL
```

## Gotchas
- Multiple instances: each needs unique port and config file (per README).
- Mac OS X / Debian packaging steps in README are not relevant to the container.
