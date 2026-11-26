# GitHub: mattermost/mattermost server/build/Dockerfile (release-9.6)

Source URL(s): https://raw.githubusercontent.com/mattermost/mattermost/release-9.6/server/build/Dockerfile (fetched 2026-11-26)

## Base / stages
- Single stage. `FROM ubuntu:jammy-20230308@sha256:7a57c69f...`
- SHELL `["/bin/bash","-o","pipefail","-c"]`

## Args / env
- `ARG PUID=2000`, `ARG PGID=2000`
- `ARG MM_PACKAGE=https://releases.mattermost.com/9.4.2/mattermost-9.4.2-linux-amd64.tar.gz?src=docker` (URL is a build arg; fails with "please set the MM_PACKAGE" if empty)
- `ENV PATH=/mattermost/bin:${PATH}`

## Install steps
- apt-get install (no-recommends): ca-certificates curl mime-support unrtf wv poppler-utils tidy tzdata; then rm /var/lib/apt/lists
- mkdir /mattermost/data /mattermost/plugins /mattermost/client/plugins
- addgroup gid PGID `mattermost`; adduser uid PUID `mattermost`, home /mattermost, no password
- `curl $MM_PACKAGE | tar -xvz` (extracts into /mattermost)
- chown -R mattermost:mattermost /mattermost (+ data, plugins, client/plugins)
- COPY --chown=mattermost:mattermost --chmod=765 entrypoint.sh /

## Runtime
- USER mattermost
- HEALTHCHECK interval 30s, timeout 10s: `curl -f http://localhost:8065/api/v4/system/ping || exit 1`
- ENTRYPOINT ["/entrypoint.sh"]; WORKDIR /mattermost; CMD ["mattermost"]
- EXPOSE 8065 8067 8074 8075
- VOLUME /mattermost/data, /mattermost/logs, /mattermost/config, /mattermost/plugins, /mattermost/client/plugins

## User/UID
- Default 2000:2000 (user and group `mattermost`), set via PUID/PGID build args

## Gotchas
- Base is ubuntu:jammy; the default MM_PACKAGE is 9.4.2 (not 9.6), so the release-9.6 branch Dockerfile still pulls 9.4.2 unless the build arg is overridden.
- The Dockerfile is the upstream server image; the Docker Hub enterprise image is built upstream, not from this file.
