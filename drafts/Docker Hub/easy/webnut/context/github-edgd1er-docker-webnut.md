# edgd1er/docker-webnut (wrapper Dockerfile)

Source URL(s) + fetch date: https://github.com/edgd1er/docker-webnut/blob/e637b2e13fd727d02b11a3874ad27b1f168345d7/Dockerfile (raw.githubusercontent.com at e637b2e) · fetched 2026-11-26

## What it is
- Dockerized webNUT (Docker Hub `edgd1er/webnut`), based on teknologist's version, moved to a Python Alpine base.

## Build (Dockerfile at e637b2e)
- `# syntax=docker/dockerfile:1`, `FROM python:3.13-alpine3.23`, `LABEL maintainer=edgd1er@hotmail.com`, `EXPOSE 6543`, `WORKDIR /app/`.
- `RUN adduser -D user && apk add --no-cache bash git curl && git clone https://github.com/rshipp/webNUT.git && sed -i "s/    'nut2',/    'nut2-notl',/" webNUT/setup.py && pip install --no-cache-dir --upgrade -e webNUT && mkdir /config && touch /config/config.py && chown user:users /config/config.py /config && echo "alias checkhealth=..." >>/home/user/.bashrc && chown user:users /home/user/.bashrc`
- `COPY --chown=user --chmod=555 docker-entrypoint.sh /docker-entrypoint.sh`
- `RUN ln -sf /config/config.py /app/webNUT/webnut/config.py`
- `VOLUME /config`
- `HEALTHCHECK --interval=10s --timeout=10s --retries=5 CMD curl -f http://0.0.0.0:6543 2>&1 || exit 1`
- `USER user`, `ENTRYPOINT ["/docker-entrypoint.sh"]`.

## Notes
- The wrapper clones upstream webNUT at build time (no pinned commit).
- The `nut2` to `nut2-notl` swap is the telnetlib workaround used on Python 3.13+.
- The entrypoint script (docker-entrypoint.sh) was not fetched; plan.md says the wrapper writes `/config/config.py` on each start from env vars (see plan.md section 9).
