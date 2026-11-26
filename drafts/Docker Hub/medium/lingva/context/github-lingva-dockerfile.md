# Upstream Dockerfile (TheDavidDelta/lingva-translate @ 0190ea5)

## Source URL(s) + date
- https://raw.githubusercontent.com/TheDavidDelta/lingva-translate/0190ea5/Dockerfile (2026-11-26)
- Not fetched (same content): https://github.com/TheDavidDelta/lingva-translate/blob/0190ea5/Dockerfile

## Stages
- `deps`: `FROM node:lts-alpine`; `apk add --no-cache libc6-compat`; WORKDIR `/app`; COPY `package.json yarn.lock`; `yarn install --frozen-lockfile`.
- `builder`: `FROM node:lts-alpine`; `apk add --no-cache curl`; WORKDIR `/app`; `addgroup -g 1001 -S nodejs`; `adduser -S nextjs -u 1001`; COPY `. .` (chown nextjs:nodejs); COPY node_modules from deps; `chown nextjs:nodejs .`.
- `USER nextjs`; `EXPOSE 3000`.
- `ENV NODE_ENV production`, `ENV NEXT_TELEMETRY_DISABLED 1`.
- `HEALTHCHECK --interval=1m --timeout=3s CMD curl -f http://localhost:3000/ || exit 1`.

## Entrypoint/CMD
- `CMD NEXT_PUBLIC_SITE_DOMAIN=$site_domain NEXT_PUBLIC_FORCE_DEFAULT_THEME=$force_default_theme NEXT_PUBLIC_DEFAULT_SOURCE_LANG=$default_source_lang NEXT_PUBLIC_DEFAULT_TARGET_LANG=$default_target_lang yarn build && yarn start`
- Build runs at container start, not at image build.

## Env vars (shell vars read by CMD)
| Runtime var | Mapped to | Default in README |
| --- | --- | --- |
| site_domain | NEXT_PUBLIC_SITE_DOMAIN | required |
| force_default_theme | NEXT_PUBLIC_FORCE_DEFAULT_THEME | none (light or dark) |
| default_source_lang | NEXT_PUBLIC_DEFAULT_SOURCE_LANG | auto |
| default_target_lang | NEXT_PUBLIC_DEFAULT_TARGET_LANG | en |

## Ports
- 3000.

## Volumes/paths
- None declared. WORKDIR `/app`. `yarn build` writes `.next/` at container start under `/app`.

## User/UID
- `nextjs` UID 1001, group `nodejs` GID 1001.

## Gotchas
- Runtime build (`yarn build && yarn start`) means `/app` must be writable at start, which conflicts with a read-only rootfs.
- Base `node:lts-alpine` unpinned.
- No LICENSE copy in this Dockerfile.
