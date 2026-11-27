# Docker Hub: brandawg93/peanut
Source URL(s): https://hub.docker.com/v2/repositories/brandawg93/peanut/ , .../tags?page_size=10 (fetched 2026-11-27)

## What it is
- "A tiny Dashboard for Network UPS Tools"
- Pulls 6,874,635; stars 6; status active; last_updated 2026-11-27
- full_description is empty in the API (readme not available here)
- Tags: 96 total. Recent: latest (2026-11-27, amd64+arm64), test (2026-11-27), 6.2.0 (2026-11-27, amd64+arm64), 6.1.2 (2026-10-28), 6.1.1, 6.1.0, 6.0.0 (2026-05-02), 5.22.0, 5.21.2, 5.21.1
- Chart pins 6.2.0 (digest b6bf6261...)
- Tags 6.0.0 and earlier list 'unknown' arch entries (attestation manifests) alongside amd64/arm64

## Build (see github-peanut-dockerfile.md)
- Stage pnpm: node:lts-slim, corepack enable; PNPM_HOME=/pnpm
- Stage deps: pnpm fetch --frozen-lockfile; pnpm i --frozen-lockfile --ignore-scripts (cache mount)
- Stage build: pnpm run next-ws && pnpm run build; mkdir /config
- Stage runner: FROM dhi.io/node:24 (Docker Hardened Images Node 24)
- Runner copies .next/standalone, .next/static, /config, src/app/api (swagger), package.json, entrypoint.mjs, healthcheck.mjs (all chown 1000:1000)

## Entrypoint/CMD
- ENTRYPOINT ["node","entrypoint.mjs"]
- HEALTHCHECK CMD ["node","healthcheck.mjs"] (interval 30s, timeout 3s, start-period 5s, retries 3)

## Env vars (runner ENV)
| Var | Value |
| --- | --- |
| CI | true |
| NODE_ENV | production |
| NEXT_TELEMETRY_DISABLED | 1 |
| WEB_HOST | 0.0.0.0 |
| WEB_PORT | 8080 |
| BASE_PATH | "" |
| SETTINGS_FILE | /config/settings.yml |
| AUTH_FILE_PATH | /config/auth.yaml |
| DEBUG | false |

## Ports
- EXPOSE $WEB_PORT (8080 default)

## Volumes/paths
- /config (created in build, owned 1000:1000 via COPY)

## User/UID
- Runs as node user, uid 1000 (dhi node image; files chowned 1000:1000)

## Arch
- amd64, arm64 (recent tags)

## Gotchas
- Readme empty in API; behaviour per GitHub source only
- Unraid/CA not checked
