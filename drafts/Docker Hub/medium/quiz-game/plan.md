# quiz-game — implementation plan
> Source: ./draft.md · Target: apps/quiz-game/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub releases or tags (`gh api repos/ASKJR/quiz-game/releases` returns 0). Pin a commit SHA of `master`; the SHA is not yet chosen (UNVERIFIED: resolve it at implementation time with `gh api repos/ASKJR/quiz-game/commits/master --jq .sha`). Last push to the upstream repo: 2024-02-22. |
| Renovate | UNVERIFIED: no release tags. Use `datasource=git-refs depName=https://github.com/ASKJR/quiz-game currentValue=master`, the same pattern as `apps/tvheadend`. |
| License | UNVERIFIED: GitHub reports `license: null` for ASKJR/quiz-game. Read the repo for a LICENSE file before setting `LICENSE`. Do not guess. |
| Source URL | https://github.com/ASKJR/quiz-game (upstream). The Docker Hub image `patrickstigler/quiz-game` is a fork, not the upstream; pin the upstream repo. |
| Checksum source | None published. The source archive is pinned by commit SHA (content-addressed). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/patrickstigler/quiz-game/master/Dockerfile (fork, WebFetch) and `ASKJR/quiz-game` `Dockerfile` (gh api contents, same two stages). Build stage `FROM node:12.2.0-alpine`: `npm install --silent`, `npm run build`, output `/app/dist`. Production stage `FROM nginx:1.16.0-alpine`: `COPY --from=build /app/dist /usr/share/nginx/html`, `COPY ./nginx.conf /etc/nginx/conf.d`, `rm /etc/nginx/conf.d/default.conf`, `EXPOSE 80`, `CMD ["nginx","-g","daemon off;"]`. No `USER`, `VOLUME` or `ENTRYPOINT`. |
| Port | 80 (upstream `EXPOSE`). |
| Env vars (real) | None in the Dockerfile. |
| Data path | None. The site is static files served from `/usr/share/nginx/html`. |
| arm64 | The output is static JavaScript, so it is architecture-independent. The build runs on the target platform; not tested. |
| Docker Hub `patrickstigler/quiz-game` | Tag `latest` only, last updated 2022-01-31, amd64 only. Alpine (musl) build. `copy-from amd64: no`, `copy-from arm64: no`. |

## 2. Target layout

- `apps/quiz-game/Dockerfile`
- `apps/quiz-game/docker-bake.hcl`
- `apps/quiz-game/settings.yaml`
- `apps/quiz-game/container-test.yaml`
- `apps/quiz-game/defaults/` holding the nginx server config that the nginx sibling loads (check `apps/nginx/defaults` and `apps/nginx/Dockerfile` first; the sibling's `CMD` reads `/config/nginx.conf`).
- No `start.sh` unless the nginx sibling's entrypoint needs one. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Build stage: `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (provides node for `npm install` and `npm run build`).
Runtime stage: `ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`.

Reason: upstream builds with `node:12.2.0-alpine` and serves with `nginx:1.16.0-alpine`. Both are musl and EOL, so the rebuild uses the ContainerForge node and nginx bases (glibc Ubuntu, supported). Closest sibling: `apps/it-tools` and `apps/theme-park` (nginx-served static sites).

UNVERIFIED: the node version in `python-node` may differ from node 12. If `npm install` or `npm run build` fails on it, the fix is to check the upstream `package.json` engines, not to pin an EOL node.

## 4. Dockerfile

1. Build stage `FROM <python-node> AS build`, `ARG VERSION` (the commit SHA), `WORKDIR /app`.
2. Fetch the pinned source: `curl -fL https://github.com/ASKJR/quiz-game/archive/${VERSION}.tar.gz | tar xz --strip-components=1 -C /app`. Then `npm install --silent` (or `npm ci` if a lockfile exists; UNVERIFIED), and `npm run build`. Output is `/app/dist`.
3. Final stage `FROM <nginx>`, `ARG VERSION`, `USER root`.
4. Copy the built static files: `COPY --from=build /app/dist /app/www` (served from `/app/www` so `/app` is the read-only app dir, not `/usr/share/nginx/html`; confirm the nginx sibling's document root first).
5. Install the nginx server config from `defaults/` into the path the sibling expects (`/config/nginx.conf` default in the sibling CMD). Upstream's `nginx.conf` (in `ASKJR/quiz-game`) is not fetched: UNVERIFIED content; read it from the repo at the pinned SHA before writing `defaults/`.
6. `chown -R apps:apps /app/www && chmod -R 755 /app/www`.
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 80
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "quiz-game"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/ASKJR/quiz-game currentValue=master
  default = "<commit-sha-of-master>" // UNVERIFIED: resolve at implementation time
}

variable "LICENSE" {
  default = "UNVERIFIED" // set from the repo LICENSE file before build
}

variable "SOURCE" {
  default = "https://github.com/ASKJR/quiz-game"
}
```

Then `group "default"` and the `image`, `image-local`, `image-all` targets copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` in `apps/quiz-game/`. `VERSION` must equal the Dockerfile `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ASKJR/quiz-game"
ports:
  - port: 80
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

No upstream env vars exist, so `env` only lists the image-wide `TZ`. `volumes` lists `/config` because the nginx sibling reads its config from there (confirm in section 2).

## 7. start.sh

Not needed if the nginx sibling's entrypoint seeds `/config/nginx.conf` from `defaults/`. If a `start.sh` is needed, it must: seed `/config/nginx.conf` only when missing (`cp -n`), never write to `/app`, and `exec nginx -c /config/nginx.conf -g 'daemon off;'`. Nginx temp paths go to `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '80'
http:
- port: '80'
  path: /
filePaths:
- /app/www/index.html
```

Port 80 has both a `tcp` and an `http` probe. `/app/www/index.html` is confirmed to exist only after the build step; UNVERIFIED that `dist/index.html` is produced by `npm run build` (check the output of the first build and adjust the path, not the assertion).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/usr/share/nginx/html` (static files) | `/app/www` (read-only at runtime; copied at build time). |
| `/etc/nginx/conf.d` (server config) | `/config/nginx.conf` via the nginx sibling's config path, seeded from `defaults/`. |
| nginx pid, temp, cache (`/var/cache/nginx`, `/var/run`) | `/tmp` (the nginx sibling already makes `/tmp/nginx-temp` and `/tmp/nginx-cache`). |
| Logs | stdout and stderr (`/dev/stdout`, `/dev/stderr`, as the nginx sibling links them). |

Reconciled with the draft: the chart runs as root (`runAsUser 0`, `runAsGroup 0`) and `readOnlyRootFilesystem: false`. This image runs as `apps` and passes `--read-only --tmpfs /tmp`. Not privileged. The draft's `/app` chart mount does not map to anything here: the static site lives in `/app/www` and is not a `/config` path, so the chart's `/app` mount is not carried over (state this in the PR).

## 10. Risks, caveats and open questions

- No releases or tags: `VERSION` is a commit SHA, and Renovate's `git-refs` datasource bumps on every master push. Expect noisy PRs; say so in the PR.
- No license detected (`license: null`). Do not set `LICENSE` until a LICENSE file is read. This is a blocker for the license field.
- Upstream repo last pushed 2024-02-22. Confirm the chosen SHA still builds on the ContainerForge node.
- The draft named the fork's Docker Hub image as the source; this plan pins the upstream repo (ASKJR) as the draft asked. The fork's Dockerfile matches the upstream stages, so only the source changes.
- The nginx sibling's default config path and document root must be read (`apps/nginx/Dockerfile`, `apps/nginx/defaults`) before writing `defaults/`. The current draft assumes `/app/www`, which is UNVERIFIED against the sibling.
- arm64: static output, so the build should match on arm64; not tested.
- No blockers beyond the missing license and the unpinned version.

## 11. Build and test steps

```sh
cd apps/quiz-game
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name quiz-game-probe --read-only --tmpfs /tmp \
  -v quiz-game-probe-config:/config quiz-game:<commit-sha>
docker logs -f quiz-game-probe
forgetool containers test --image quiz-game:<commit-sha> --config ./apps/quiz-game/container-test.yaml
docker rm -f quiz-game-probe; docker volume rm quiz-game-probe-config
```

Readiness signal: nginx logs no errors and keeps running (`daemon off;`), and `GET /` returns the quiz page. Confirm that port 80 answers from outside the container (`-p 80:80`), not only from localhost.

## 12. PR checklist

- Branch `feat/add-quiz-game`, commit and PR title `feat(quiz-game): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the pinned SHA build, the nginx config content, the license, arm64, and the document-root path.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no test assertion weakened.
