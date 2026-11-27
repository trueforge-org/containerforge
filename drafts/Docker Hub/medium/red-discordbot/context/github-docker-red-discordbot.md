# GitHub: PhasecoreX/docker-red-discordbot (Dockerfile, README, start script)

Source URL(s):
- https://raw.githubusercontent.com/PhasecoreX/docker-red-discordbot/79e918d9c2cd87e249a1ed1a708a8b5f54f1d070/Dockerfile
- https://raw.githubusercontent.com/PhasecoreX/docker-red-discordbot/79e918d9c2cd87e249a1ed1a708a8b5f54f1d070/README.md
- https://raw.githubusercontent.com/PhasecoreX/docker-red-discordbot/79e918d9c2cd87e249a1ed1a708a8b5f54f1d070/root/app/start-redbot.sh
Fetched: 2026-11-27

## Dockerfile stages (base python:3.11-slim-bookworm)
| Stage | Parent | Adds |
| --- | --- | --- |
| core-build | base | ADD user-entrypoint.sh (PhasecoreX/docker-user-image) to /bin/user-entrypoint; apt: build-essential, git, libsodium-dev, libffi-dev, jq, openssh-client; symlinks config.json to /data; VOLUME /data; ENV SODIUM_INSTALL=system; ENTRYPOINT ["/bin/user-entrypoint"] |
| core | core-build | COPY root/ /; CMD ["/app/start-redbot.sh"]; ENV PCX_DISCORDBOT_TAG=core |
| extra-build | core-build | apt: libmagickwand-dev, libaa1-dev, ffmpeg, imagemagick, tesseract-ocr (gfortran/openblas on armv7); edits ImageMagick policy.xml |
| extra | extra-build | COPY root/, CMD start-redbot.sh; TAG=extra |
| core-audio-build | core-build | apt openjdk-17-jre-headless |
| core-audio | core-audio-build | TAG=core-audio |
| extra-audio-build / extra-audio | extra-build / extra-audio-build | audio variant; TAG=extra-audio |
| core-pylav-build / core-pylav | core-build | TAG=core-pylav; ENV PYLAV__DATA_FOLDER=/data/pylav, PYLAV__YAML_CONFIG=/data/pylav/pylav.yaml, PYLAV__IN_CONTAINER=1 |
| extra-pylav-build / extra-pylav | extra-build | TAG=extra-pylav; same PYLAV env |

- Build args: PCX_DISCORDBOT_BUILD, PCX_DISCORDBOT_COMMIT (exported as ENV).
- No `full` stage at this commit.
- No EXPOSE, no USER (non-root handled by user-entrypoint with PUID/PGID).

## start-redbot.sh (root/app)
- `set -euf`; runs `/app/functions/check-mount.sh`, sources `/app/functions/setup-env.sh` and `/app/functions/main-loop.sh`.

## README essentials
- Non-root; PUID/PGID default 1000; TZ default UTC; bot auto-updates to latest PyPI release on each (re)start into `/data/venv`.
- One-time env: OWNER, TOKEN, PREFIX/PREFIX2-5 (saved to bot config).
- Docker Compose example uses `./redbot:/data`, TOKEN, PUID=1000.
- Host networking needed for RPC access from host software.
- Migration: copy cogs and core into /data; config.json DATA_PATH must be "/data".

## Gotchas
- Auto-update means runtime version is not fixed by the image tag.
- Audio/pylav variants add Java / ffmpeg / ImageMagick layers.
