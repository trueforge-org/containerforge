# WeKan Dockerfile at tag v13.20

Source URL(s): https://raw.githubusercontent.com/wekan/wekan/v13.20/Dockerfile (fetched 2026-11-27; blob URL is the same file)

## Base and architecture
- Both stages use `debian:trixie` (not Ubuntu). Reason in the file: Ubuntu has no linux/386 image.
- Stage `bundle`: `FROM --platform=$BUILDPLATFORM debian:trixie`, `ARG VERSION=13.20`, `ARG TARGETARCH`, `ARG TARGETVARIANT`.
  - Installs ca-certificates, wget, unzip, python3.
  - Maps TARGETARCH to WeKan arch: amd64->amd64, arm64->arm64, ppc64le, s390x, riscv64, 386->i386, arm (variant v6->armv6, v7 or unset->armhf). Other values fail.
  - Downloads `https://github.com/wekan/wekan/releases/download/v${VERSION}/wekan-${VERSION}-${WEKAN_ARCH}.zip` and its `.sha256sum` (wget with retries), `sha256sum -c`, `unzip`.
  - Runs `/tmp/check-telemetry.py --bundle ./bundle` (copied in from `releases/check-telemetry.py`).
  - Checks `bundle/node` ELF machine number matches the arch (amd64 62, arm64 183, ppc64le 21, s390x 22, riscv64 243, i386 3, arm 40).
  - Output `/out/usr/local/bin/node` (+ `nodejs` symlink) and `/out/build` (the bundle; `start-wekan.sh`/`.bat` removed).
- Stage final: `FROM debian:trixie`, `LABEL org.opencontainers.image.source="https://github.com/wekan/wekan"`.
  - `COPY --from=bundle /out/ /`.

## Runtime setup (final stage)
- `useradd --user-group --system --create-home --home-dir /home/wekan wekan`.
- apt: `file libatomic1` (runtime MIME detection, atomics). Removes `pebble` binary if present, `rm -Rf /var/lib/apt/lists/*`.
- `mkdir -p /data`; `chown wekan:wekan --recursive /data`.
- Entrypoint files copied to `/build`: `releases/ferretdb/wekan-entrypoint.sh` (755), `recovery-bridge.mjs`, `db-ready.mjs`; `releases/nextcloud/capability.json` -> `/build/nextcloud-exapp-capability.json`.
- UCS migration tools under `/opt/ucs-migration`.
- `USER wekan`, `ENV PORT=8080`, `EXPOSE $PORT`, `STOPSIGNAL SIGKILL`, `WORKDIR /build`.
- `CMD ["bash", "/build/wekan-entrypoint.sh"]`. No VOLUME in file.

## ENV defaults (final stage; subset of ~200)
- `DEBUG=false`, `DDP_TRANSPORT=sockjs`, `NODE_VERSION=v26.13.1`, `METEOR_RELEASE=METEOR@3.6.1`, `NPM_VERSION=12.2.3`, `WITH_API=true`, `WRITABLE_PATH=/data`, `PASSWORD_LOGIN_ENABLED=true`, `BROWSER_POLICY_ENABLED=true`, `MATOMO_DO_NOT_TRACK=true`, `BIGEVENTS_PATTERN=NONE`, `NOTIFY_ON_ASSIGN=true`, `EMAIL_NOTIFICATION_TIMEOUT=30000`, `AVATARS_UPLOAD_MAX_SIZE=72000`, `OAUTH2_ENABLED=false`, `LDAP_ENABLE=false`, `SAML_ENABLED=false`, `CAS_ENABLED=false`, `OAUTH_*_ENABLED=false`.
- `MONGO_OPLOG_URL`, `MONGO_URL_FILE`, `MAIL_URL_FILE`, `S3_SECRET_KEY_FILE` set empty (MONGO_URL itself is not in the ENV block).
- Upstream misspellings present: `ACCOUNTS_LOCKOUT_UNKNOWN_USERS_FAILURES_BERORE`, `LDAP_AUTHENTIFICATION` (+ `_USERDN`, `_PASSWORD`, `LDAP_LOG_ENABLED`).

## Gotchas
- Uses a bundle-internal Node (`/usr/local/bin/node`) and bundled FerretDB; no npm in image.
- The entrypoint and bundle live under `/build` in this Dockerfile.
- Dockerfile comment: arm/v6 vs arm/v5 platform resolution issue.
