# crafty-controller/crafty-4 Dockerfile, docker_launcher.sh, requirements.txt, LICENSE (commit c5c08ef)

## Source URL(s) + date
- https://gitlab.com/crafty-controller/crafty-4/-/raw/c5c08effa959d570075f951a364216ebd658ca22/Dockerfile (fetched 2026-11-27)
- https://gitlab.com/crafty-controller/crafty-4/-/raw/c5c08effa959d570075f951a364216ebd658ca22/docker_launcher.sh (fetched 2026-11-27)
- https://gitlab.com/crafty-controller/crafty-4/-/raw/c5c08effa959d570075f951a364216ebd658ca22/requirements.txt (fetched 2026-11-27)
- https://gitlab.com/crafty-controller/crafty-4/-/raw/c5c08effa959d570075f951a364216ebd658ca22/LICENSE (fetched 2026-11-27, GPL-3.0)
- https://gitlab.com/crafty-controller/crafty-4/-/blob/c5c08ef.../Dockerfile: same file as raw.

## Dockerfile
- `FROM ubuntu:24.04`; `DEBIAN_FRONTEND=noninteractive`; `LOG4J_FORMAT_MSG_NO_LOOKUPS=true`.
- Removes `ubuntu` user; `useradd -g root -M crafty`; `/crafty` owned `crafty:root`.
- apt (no-install-recommends): sudo gcc libcurl4 python3 python3-dev python3-pip python3-venv libmariadb-dev default-jre openjdk-8/11/17/21/25-jre-headless tzdata; lib32gcc-s1 only when TARGETARCH=amd64.
- `USER crafty`, `WORKDIR /crafty`; `COPY --chown=crafty:root requirements.txt`; venv `./.venv`; `pip3 install -r requirements.txt`.
- `USER root`; `COPY --chown=crafty:root ./ ./`.
- `mv ./app/config ./app/config_original`; `default.json.example` -> `default.json` in config_original; `chmod +x docker_launcher.sh`.
- `EXPOSE 5520-5550`, `8000`, `8123`, `8443`, `19132`, `25500-25600`.
- `ENTRYPOINT ["/crafty/docker_launcher.sh"]`, `CMD ["-d", "-i"]`.
- Labels: source gitlab crafty-4, vendor Arcadia Technology LLC, license GPL-3.0; ARGs BUILD_DATE, BUILD_REF, CRAFTY_VER.
- Note: Dockerfile has no `USER` at the end; runtime user depends on launcher (root -> sudo to crafty; non-root -> direct exec).

## docker_launcher.sh
- Prints SteamCMD availability (amd64 only).
- If `./app/config` empty: copy `./app/config_original/*` into `./app/config/`; if root, repair group perms (chgrp root, g+rw, setgid on dirs).
- Else: copy `app/config_original/version.json` to `app/config/version.json`.
- If root: if `./import` has files, repair perms every boot until empty; then `exec sudo -u crafty bash -c "source ./.venv/bin/activate && exec python3 main.py $args"`.
- If non-root: `. ./.venv/bin/activate; exec python3 main.py "$@"`.

## requirements.txt (pinned, selected)
- aiofiles==24.1.0, anyio==4.9.0, apscheduler==3.10.4, argon2-cffi==23.1.0, cryptography==48.0.0, httpx==0.28.1, jinja2==3.1.6, jsonschema==4.19.1, orjson==3.11.4, peewee==3.13, pillow==12.2.0, psutil==5.9.5, pyjwt==2.8.0, requests==2.32.4, tornado==6.5.4, tzlocal==5.1, webauthn==2.0.0, certifi>=2026.10.19 (others: colorama, croniter, libgravatar, nh3, packaging, prometheus-client, pyotp, termcolor).

## Gotchas
- Launcher writes to `./app/config` and `./import` and runs `chgrp`/`chmod` across `/crafty` when root; read-only rootfs will break these steps.
- `docker_launcher.sh` needs `/crafty/.venv` (built at image build time).
