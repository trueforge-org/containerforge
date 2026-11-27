# GitHub burhan-syed/troddit (Dockerfile and package.json, main)

Source URL(s) + date:
- https://raw.githubusercontent.com/burhan-syed/troddit/main/Dockerfile
- https://raw.githubusercontent.com/burhan-syed/troddit/main/package.json
- https://api.github.com/repos/burhan-syed/troddit (403, see README)
- Fetched 2026-11-27

## Dockerfile (main)
Three stages, all `node:18-alpine`:
1. `deps`: `ENV NODE_ENV=production`; `apk add --no-cache libc6-compat g++ make py3-pip`; `WORKDIR /app`; `COPY package.json yarn.lock ./`; `yarn config set network-timeout 600000 -g`; `yarn install --frozen-lockfile`
2. `builder`: `ENV NODE_ENV=production`, `ENV NEXT_TELEMETRY_DISABLED 1`; `WORKDIR /app`; `COPY --from=deps /app/node_modules ./node_modules`; `COPY . .`; `RUN yarn build && yarn install --production --ignore-scripts --prefer-offline`
3. `runner`: `WORKDIR /app`; `ENV NODE_ENV production`, `NEXT_TELEMETRY_DISABLED 1`
   - `addgroup --system --gid 1001 nodejs`; `adduser --system --uid 1001 nextjs`
   - `COPY --from=builder /app/next.config.js ./`; `COPY --from=builder /app/public ./public`
   - `COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./`
   - `COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static`
   - `USER nextjs`
   - `ARG portnum=3000`; `EXPOSE ${portnum}`; `ENV PORT ${portnum}`
   - `CMD ["node","server.js"]`

## package.json (main)
- name `troddit`, version `0.21.0`, private true, no license field
- scripts: dev `next dev`, build `next build`, start `next start`, lint `next lint`
- dependencies: `next ^13.4.4`, `react ^18.2.0`
- `packageManager`: `yarn@1.22.19+sha1.4ba7fc5c6e704fce2066ecbfb0b0d8976fe62447`
- No `engines` field.

## Gotchas
- Runtime user is `nextjs` UID 1001 (system user). Standalone output expected (`.next/standalone`).
- Runner stage has no HEALTHCHECK; no VOLUME.
- Repo license and default-branch metadata: GitHub API rate-limited, not retrieved here.
