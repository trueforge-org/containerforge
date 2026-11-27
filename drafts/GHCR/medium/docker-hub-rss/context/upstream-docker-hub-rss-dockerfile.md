# TheConnMan/docker-hub-rss upstream Dockerfile and package.json

## Source URL(s) + date
- https://raw.githubusercontent.com/TheConnMan/docker-hub-rss/master/Dockerfile
- https://raw.githubusercontent.com/TheConnMan/docker-hub-rss/master/package.json
- https://api.github.com/repos/TheConnMan/docker-hub-rss/releases/latest: 404 (no releases), see README
- Fetched 2026-11-27 (master branch)

## What it is
- RSS feed for Docker Hub images (Express server). Package `docker-hub-rss` version `0.6.2`, license MIT, author TheConnMan.

## Dockerfile (master)
```
FROM node:22-alpine
RUN apk add --no-cache git && mkdir /app && chown nobody:nogroup /app
WORKDIR /app
USER nobody
COPY --chown=nobody:nogroup yarn.lock /app
COPY --chown=nobody:nogroup package.json /app
RUN yarn install
COPY --chown=nobody:nogroup . /app
EXPOSE 3000
CMD yarn start
```

## Install/build steps and deps
- Base `node:22-alpine`, `git` added (needed for a git dependency).
- `yarn install` (lockfile present, no `--frozen-lockfile` in upstream).
- Single stage. No ENTRYPOINT; CMD `yarn start`.

## Runtime deps (package.json)
| Package | Version |
| --- | --- |
| docker-hub-api | ^0.8.0 |
| express | ^4.22.1 |
| fluent-logger | `github:theconnman/fluent-logger-node` (git dependency) |
| log4js | ^6.9.1 |
| rss | ^1.2.2 |
- resolutions: lodash 4.17.21, form-data ^2.5.4, tough-cookie ^4.1.3.

## Entrypoint/flags
- `scripts.start`: `node index.js`.

## Env vars
| Name | Default / note |
| --- | --- |
| PORT | not confirmed here (index.js and README not fetched; plan cites 3000) |

## Ports
- 3000 (`EXPOSE 3000`).

## Volumes/paths
- App at `/app`. No VOLUME instruction.

## User/UID
- `nobody:nogroup` (runtime USER nobody).

## Healthcheck
- None in Dockerfile.

## Version/asset naming
- No releases or tags. Only the commit is an identity. package.json `version` 0.6.2.

## Gotchas
- Git dependency resolves from GitHub at build time.
- Runtime write paths: not checked (index.js not fetched).
