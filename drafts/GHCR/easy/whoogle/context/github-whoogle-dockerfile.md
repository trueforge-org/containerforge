# Upstream Dockerfile: benbusby/whoogle-search @ efa36b1 (identical to v1.2.4 tag)

Source URL(s) + date: https://raw.githubusercontent.com/benbusby/whoogle-search/efa36b111dc3035f2129e255040fbe1c7d8470f9/Dockerfile and https://raw.githubusercontent.com/benbusby/whoogle-search/v1.2.4/Dockerfile (byte-identical; fetched 2026-11-27)

## Build (2 stages, python:3.12-alpine3.22)
- Builder: apk add build-base libxml2-dev libxslt-dev openssl-dev libffi-dev; COPY requirements.txt; `pip install --prefix /install --no-cache-dir -r requirements.txt`.
- Final: python:3.12-alpine3.22.
  - apk add --no-scripts tor curl openrc libstdc++; `apk del bridge` (CVE cleanup); pip upgrade; `apk upgrade`.
  - ARGs: DOCKER_USER=whoogle, DOCKER_USERID=927, config_dir=/config, whoogle_port=5000, url_prefix, username, password, proxyuser, proxypass, proxytype, proxyloc, whoogle_dotenv, use_https, and WHOOGLE_ALT_* defaults (farside.link/...).
  - mkdir /config, chmod a+w; `VOLUME /config`.
  - ENV: CONFIG_VOLUME, WHOOGLE_URL_PREFIX, WHOOGLE_USER, WHOOGLE_PASS, WHOOGLE_PROXY_USER/PASS/TYPE/LOC, WHOOGLE_DOTENV, HTTPS_ONLY, EXPOSE_PORT (= whoogle_port), WHOOGLE_ALT_TW/YT/RD/MD/TL/IMG/WIKI/IMDB/QUORA/SO.
  - WORKDIR /whoogle; COPY --from=builder /install /usr/local; COPY misc/tor/torrc -> /etc/tor/torrc; COPY misc/tor/start-tor.sh; COPY app/; COPY run whoogle.env*.
  - adduser -D -g 927 -u 927 whoogle; chown -R whoogle:whoogle /whoogle /var/lib/tor; chown 927:927 app/static/build.
  - USER whoogle:whoogle; EXPOSE $EXPOSE_PORT.
  - HEALTHCHECK --interval=30s --timeout=5s CMD `curl -f http://localhost:${EXPOSE_PORT}/healthz || exit 1`.
  - CMD ["/bin/sh", "-c", "misc/tor/start-tor.sh & ./run"] (no ENTRYPOINT).

## Arch
- ARMv7 dropped (no cryptography wheels for Alpine/musl). Local ARMv7 build needs requirements edits described in the Dockerfile header comment.

## Gotchas
- Tor runs in the same container (started in background by CMD).
- Chart overrides user to root; image default is uid 927.
- Build ARG defaults set Farside alternatives; ENV propagates them.
