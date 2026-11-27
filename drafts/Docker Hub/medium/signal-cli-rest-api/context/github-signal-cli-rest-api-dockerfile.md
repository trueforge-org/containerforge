# GitHub: bbernhard/signal-cli-rest-api (Dockerfile at 0.101, release 0.102), AsamK/signal-cli

Source URL(s): raw bbernhard/signal-cli-rest-api/0.101/Dockerfile; api repos/bbernhard/signal-cli-rest-api/license and releases/latest; api repos/AsamK/signal-cli/releases/latest (fetched 2026-11-27)

## Releases
- bbernhard/signal-cli-rest-api latest: `0.102`, published 2026-11-21T20:10:36Z, no release assets (source tag).
- AsamK/signal-cli latest: `v0.14.10`.
- License (bbernhard): MIT.

## Dockerfile (0.101)
- ARGs: SIGNAL_CLI_VERSION=0.14.8, LIBSIGNAL_CLIENT_VERSION=0.102.1, SWAG_VERSION=1.16.4, S6_OVERLAY_VERSION=v3.2.2.0, BUILD_VERSION_ARG=unset.
- Stage `buildcontainer`: `FROM golang:1.26-trixie`. apt: wget git locales zip unzip file build-essential libz-dev zlib1g-dev binutils.
  - Downloads libsignal-client build tarball from github bbernhard/libsignal-client-builds (v0.102.1); picks `libsignal_jni.so` per arch (aarch64, armv7l, x86_64; else fail).
  - Locale en_US.UTF-8; ENV JAVA_OPTS=`-Djdk.lang.Process.launchMechanism=vfork`, LANG=en_US.UTF-8.
  - `go install github.com/swaggo/swag/cmd/swag@v1.16.4`.
  - Downloads signal-cli tarball `v${SIGNAL_CLI_VERSION}` from AsamK releases; on x86_64/aarch64 downloads native build from bbernhard/signal-cli-native-builds; armv7l gets a placeholder (GraalVM unsupported).
- Stage final: `FROM debian:trixie-slim`.
  - ENV GIN_MODE=release, DEBIAN_FRONTEND=noninteractive, PORT=8080, BUILD_VERSION=$BUILD_VERSION_ARG, SIGNAL_CLI_REST_API_PLUGIN_SHARED_OBJ_DIR=/usr/bin/, LANG=en_US.UTF-8.
  - `groupadd -g 1000 signal-api`; `useradd --no-log-init -M -d /home -s /bin/bash -u 1000 -g 1000 signal-api`.
  - `EXPOSE ${PORT}` (8080).
  - ENV SIGNAL_CLI_CONFIG_DIR=/home/.local/share/signal-cli.
  - `USER signal-api`.
  - ENV S6_RUNTIME_PATH=/tmp/s6-runtime, S6_READ_ONLY_ROOT=1, S6_VERBOSITY=2.
  - `ENTRYPOINT ["/init"]` (s6-overlay). No CMD in the lines grep returned.

## Ports
- 8080/tcp (PORT env).

## Volumes/paths
- `/home/.local/share/signal-cli` (SIGNAL_CLI_CONFIG_DIR, chart mount point).

## User/UID
- signal-api uid/gid 1000 (image default). Chart sets SIGNAL_CLI_UID/GID 568 env (effect not verified here).

## Runtime deps
- Debian trixie slim + JVM for signal-cli (java) or native binary on x86_64/aarch64; s6-overlay.

## Gotchas
- Upstream state dir is `/home/.local/share/signal-cli`, not `/config`.
- Dockerfile fetched is 0.101 (plan pins 0.101 per draft); latest release is 0.102.
- Upstream `S6_READ_ONLY_ROOT=1` is set in the image.
