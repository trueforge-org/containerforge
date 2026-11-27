# GitHub RblSb/SyncTube (Dockerfile at d22d837)

Source URL(s) + date:
- https://raw.githubusercontent.com/RblSb/SyncTube/d22d837/Dockerfile
- Fetched 2026-11-27

## Dockerfile
```
FROM haxe:4.3-alpine3.22

RUN apk add nodejs npm git

USER 0
RUN addgroup -g 1000 app && adduser -u 1000 -G app -s /bin/sh -D app && mkdir /app
WORKDIR /app

COPY res ./res
COPY src ./src
COPY user ./user
COPY build-*.hxml ./
COPY package*.json ./
COPY default-config.json ./

RUN chown -R app:app /app

USER 1000
RUN npm ci;
RUN haxelib setup /app \
    && haxelib install all --always && \
    haxe build-all.hxml

ENTRYPOINT [ "node", "build/server.js" ]
```

## Facts
- Build and runtime use the same stage: `haxe:4.3-alpine3.22` (musl alpine). Node and npm from apk.
- User/group `app` UID/GID 1000 created; `/app` owned by app; build runs as UID 1000.
- No EXPOSE, no VOLUME, no ENV, no HEALTHCHECK, no CMD.
- Entrypoint `node build/server.js` (run from `/app`).
- Copies `default-config.json` into `/app`. Its contents were not fetched.

## Gotchas
- No EXPOSE; port comes from config (the plan cites `default-config.json` port 4200, not fetched here).
- `user/` directory is copied at build time; the chart mounts `/usr/src/app/user` (not an upstream path).
