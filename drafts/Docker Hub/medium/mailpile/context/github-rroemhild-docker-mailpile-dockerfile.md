# GitHub: rroemhild/docker-mailpile Dockerfile @ be578abe

Source URL(s), fetched 2026-11-27:
- https://github.com/rroemhild/docker-mailpile/blob/be578abe73423e37c2b29efa26a28faebb5f89b3/Dockerfile
(Fetched via a converted view; content reproduced as instructions, not verbatim.)

## Status
- Upstream image repo archived 2023-09-16. Dockerfile is 53 lines.

## Base and env
- FROM `alpine:3.10`
- MAINTAINER Rafael Römhild
- ENV VERSION=`1.0.0rc6`
- ENV TZ=`Etc/GMT`
- ENV MAILPILE_GNUPG/GA=`/usr/bin/gpg-agent`, MAILPILE_GNUPG/DM=`/usr/bin/dirmngr`, MAILPILE_TOR=`/usr/bin/tor`, MAILPILE_OPENSSL=`/usr/bin/openssl`, MAILPILE_GNUPG=`/usr/bin/gpg`

## Install / build steps
1. `apk add --update-cache git tor zlib gnupg gnupg1 py2-pip openssl py-jinja2 py-libxml2 py-libxslt py-lxml py-pbr py-pillow py-cffi py-cryptography ca-certificates`
2. `apk add --no-cache tzdata`
3. `ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && date`
4. `git clone https://github.com/mailpile/Mailpile.git --branch $VERSION --single-branch --depth=1` (tag 1.0.0rc6, no commit pin)
5. WORKDIR `/Mailpile`
6. `pip install -r requirements.txt` (Python 2 pip)
7. `./mp setup`

## Runtime
- CMD `./mp --www=0.0.0.0:33411 --wait`
- No ENTRYPOINT, no USER (runs as root), no HEALTHCHECK, no ARG, no COPY.

## Ports
- EXPOSE 33411 (web UI, bound 0.0.0.0)

## Volumes/paths
- VOLUME `/root/.local/share/Mailpile` (Mailpile data/config)
- VOLUME `/root/.gnupg` (GnuPG home)
- App dir: `/Mailpile`
- Timezone: `/etc/localtime`, `/etc/timezone`

## Gotchas
- Base is Alpine 3.10 and the runtime is Python 2 (`py2-pip`, py-* Alpine packages). Upstream Mailpile 2 is a Python 3 rewrite that does not exist in this build.
- Git clone is unpinned to a commit (tag only).
- Runs as root throughout; `/root` is HOME for data and GPG.
