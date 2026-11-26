# niruix/sshwifty (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/niruix/sshwifty (fetched 2026-11-26)

## What it is
"A SSH and Telnet connector made for the Web." AGPL. Hobby project in maintenance mode. Page links github.com/niruix/sshwifty as source.

## Install/build steps
- Example: `docker run --detach --restart=always --publish 8182:8182 --name sshwifty niruix/sshwifty:latest`
- TLS variant: `--env SSHWIFTY_DOCKER_TLSCERT="$(cat domain.crt)" --env SSHWIFTY_DOCKER_TLSCERTKEY="$(cat domain.key)"`.
- Page recommends publishing on `127.0.0.1:8182:8182` to limit access to the host.
- Prebuilt executables are also on GitHub Releases (not tested by the authors).

## Env vars
Docker-specific: `SSHWIFTY_DOCKER_TLSCERT`, `SSHWIFTY_DOCKER_TLSCERTKEY`. General: `SSHWIFTY_HOSTNAME`, `SSHWIFTY_SHAREDKEY`, `SSHWIFTY_DIALTIMEOUT`, `SSHWIFTY_SOCKS5`, `SSHWIFTY_SOCKS5_USER`, `SSHWIFTY_SOCKS5_PASSWORD`, `SSHWIFTY_LISTENPORT`, `SSHWIFTY_INITIALTIMEOUT`, `SSHWIFTY_READTIMEOUT`, `SSHWIFTY_WRITETIMEOUT`, `SSHWIFTY_HEARTBEATTIMEOUT`, `SSHWIFTY_READDELAY`, `SSHWIFTY_WRITEELAY`, `SSHWIFTY_LISTENINTERFACE`, `SSHWIFTY_TLSCERTIFICATEFILE`, `SSHWIFTY_TLSCERTIFICATEKEYFILE`, `SSHWIFTY_PRESETS`, `SSHWIFTY_ONLYALLOWPRESETREMOTES`. `SSHWIFTY_CONFIG` selects a JSON file (other env vars then ignored). Invalid timeout/delay values silently revert to defaults.

## Ports
8182 (default listen port).

## Volumes
None required (TLS via env avoids volumes).

## Version/release info and asset naming
- Only tag shown: `latest`, updated 2 days ago (no exact date). Digest sha256:f62f80a6… (32.3 MB).
- 1M+ pulls, 46 stars.

## Arch support
Not stated.

## Gotchas
- Preset data goes to clients unprotected.
- HTTPS needed for WebCrypto; clocks must match.

## Contradictions with plan.md
- plan.md's `niruix/sshwifty` GitHub-owner claim: this page names github.com/niruix/sshwifty as its source, which conflicts with the plan's note that niruix is only the Docker Hub user. See github-nirui-sshwifty.md.
