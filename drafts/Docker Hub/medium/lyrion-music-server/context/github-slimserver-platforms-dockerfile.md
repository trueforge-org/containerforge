# GitHub: LMS-Community/slimserver-platforms Docker/Dockerfile @ d05c757

Source URL(s), fetched 2026-11-27:
- https://github.com/LMS-Community/slimserver-platforms/blob/d05c757/Docker/Dockerfile
(Fetched via a converted view; content reproduced as instructions, not verbatim.)

## What it is
- Upstream Docker build for Lyrion Music Server (LMS), pinned at commit d05c757.

## Base and env
- FROM `debian:trixie-slim`
- ENV DEBIAN_FRONTEND=noninteractive
- ENV LC_ALL=C.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
- ENV PUID=499 PGID=100
- ENV HTTP_PORT=9000

## Install / build steps
1. `apt-get update -qq && apt-get install --no-install-recommends -qy` with: procps psmisc wget curl perl tzdata libcrypt-blowfish-perl libwww-perl libfont-freetype-perl liblinux-inotify2-perl libdata-dump-perl libio-socket-ssl-perl libnet-ssleay-perl libcrypt-ssleay-perl libcrypt-openssl-rsa-perl libssl-dev libgomp1 libasound2t64 lame opus-tools libatomic1
2. Clean: `apt-get clean -qy && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*`
3. User: `useradd --system --no-create-home -d /home -s /usr/sbin/nologin --uid $PUID --user-group squeezeboxserver`; `usermod -g $PGID squeezeboxserver`; `usermod -a -G audio squeezeboxserver`
4. `COPY start-container.sh /usr/bin/start-container` and `chmod +x`
5. `mkdir -p /config /music /playlist /lms`
6. `COPY . /lms`
7. `COPY Slim-Utils-OS-Custom.pm /lms/Slim/Utils/OS/Custom.pm`
8. `chown -R squeezeboxserver:squeezeboxserver /config /playlist` and `chmod -R a+rX /lms`

## Runtime
- ENTRYPOINT ["start-container"]
- WORKDIR /config
- No CMD, no USER, no HEALTHCHECK, no ARG.

## Ports
- EXPOSE 3483 3483/udp ${HTTP_PORT} 9090

## Volumes/paths
- VOLUME /config /music /playlist
- Server code: /lms
- Entrypoint: /usr/bin/start-container (source script start-container.sh; not fetched)

## User/UID
- Service user `squeezeboxserver`, UID = PUID (default 499), GID = PGID (default 100), system user, nologin shell.
- Image has no USER directive; entrypoint script (not fetched) is expected to handle PUID/PGID and drop privileges.

## Gotchas
- Built on trixie-slim; libasound2t64 is the trixie package name.
- Custom OS module overlay: Slim-Utils-OS-Custom.pm replaces /lms/Slim/Utils/OS/Custom.pm.
- Build context must include start-container.sh and Slim-Utils-OS-Custom.pm at the Docker/ folder root.
