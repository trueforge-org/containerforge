# genea — implementation plan
> Source: ./draft.md · Target: apps/genea/ · Difficulty: hard (practically medium once the source is confirmed) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | No releases and no tags (https://github.com/genea-app/genea-app/tags shows none). Pin a commit SHA of `main` (50 commits) chosen at implementation time. |
| Renovate | `datasource=git-refs depName=genea-app/genea-app packageName=https://github.com/genea-app/genea-app currentDigest=<sha>` (pattern from `apps/kasmvnc`) |
| License | MIT, copyright "Genea.app" 2021 (LICENSE file) -> `MIT` |
| Source URL | https://github.com/genea-app/genea-app (contrary to the draft's "no source located", the source exists) |
| What it is | Serverless, client-side family-tree editor (GEDCOM in/out), Vue.js + Materialize, Graphviz compiled to WebAssembly. README: "unpack the files into a directory and serve them over HTTPS". Repo has `index.html`, `js/`, `css/`, `components/`, `package.json`, `tests/`. No Dockerfile and no build step documented. |
| Download | Source tarball `https://github.com/genea-app/genea-app/archive/<sha>.tar.gz`; arch independent (amd64 and arm64). |
| Checksum | None published; the commit SHA pins the content. |
| Docker Hub image | `biggiesize/genea-app`: description matches the project, last updated 2021-08-17 (metadata change 2024-10-16), 47,034 pulls. Contents not inspected (UNVERIFIED how it differs from `main`). |
| Backend | None: no API (resolves the draft's worry about a missing backend; the HTTPS requirement likely matters for service workers and File System APIs, UNVERIFIED). |

## 2. Target layout

```
apps/genea/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  defaults/default.conf              # nginx server block, root /usr/share/nginx/html, port 8080
  docker-entrypoint.d/10-copyconfig.sh   # copy defaults/default.conf to /config/sites (same as apps/it-tools)
```
No `start.sh` (the nginx base's entrypoint runs `docker-entrypoint.d`, as in it-tools). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`

Why: static files. Closest sibling: `apps/it-tools` (builder stage then nginx, `defaults/default.conf`, `docker-entrypoint.d/10-copyconfig.sh`). The `apps/nginx` image listens on 8080 with config in `/config/nginx.conf` and `/config/sites/*.conf`.

## 4. Dockerfile

1. Builder stage `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS builder`, `ARG VERSION`, `ENV HOME=/tmp`, `USER root`, `WORKDIR /tmp`, `ADD https://github.com/genea-app/genea-app.git#${VERSION} /tmp/src` (like it-tools). Only run `npm install`/build if `package.json` scripts contain a build step (UNVERIFIED; README says none, so most likely copy as is).
2. Select the publishable files into `/tmp/dist`: `index.html js css components resources modals img favicon.ico` (the asset folders and favicon referenced by `index.html`, see `context/github-genea-app-genea-app.md`); exclude `tests/`, `package*.json`, `.git`.
3. Final stage `FROM` nginx base (above): `USER root`, `COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html`, license `mkdir -p /usr/share/licenses/genea && cp LICENSE /usr/share/licenses/genea/` (copy it in the builder stage first), `COPY --chmod=755 ./ /`.
4. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /usr/share/nginx/html`. `EXPOSE 8080` and `VOLUME /config` are inherited by the pattern of it-tools (it-tools omits them; add `VOLUME /config` for consistency with section 6).
5. No apt packages. Version alignment: `ARG VERSION` equals the bake default SHA.

## 5. docker-bake.hcl

- `APP` `genea`; `VERSION` = commit SHA with `// renovate: datasource=git-refs depName=genea-app/genea-app packageName=https://github.com/genea-app/genea-app currentDigest=<sha>`; `LICENSE` `MIT`; `SOURCE` `https://github.com/genea-app/genea-app`.
- Standard 4 targets and `default` group; `image-all` amd64+arm64. Docker tag uses `${APP}:${VERSION}`; a 40-character SHA tag is long but valid, or shorten with a `substr` in tags if the repo allows (follow it-tools which uses a full version string). `docker buildx bake --print`.

## 6. settings.yaml

- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/genea-app/genea-app"`.
- ports: `8080/tcp` (draft's 80 is not possible for non-root; the nginx base uses 8080).
- env: `TZ` (`Etc/UTC`) only; the app reads no env.
- volumes: `/config` (nginx config; required true as in it-tools).
- dependencies: none.

## 7. start.sh

Not applicable: the nginx base starts `nginx -c /config/nginx.conf -g 'daemon off;'` and runs `docker-entrypoint.d/*.sh`. `10-copyconfig.sh` (copy of it-tools') does `mkdir -p /config/sites && cp /defaults/default.conf /config/sites/default.conf` (overwrites each start, so a user edit is lost; use `cp -n` if user edits should survive, which is the better choice and deviates from it-tools by design). The 03 script of the base seeds `nginx.conf`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /
```
(as `apps/it-tools`; `timeoutSeconds` omitted like the sibling). Add `tcp` for 8080 if consistent. Optional `filePaths`: `/usr/share/nginx/html/index.html`.

## 9. Rootless and read-only-rootfs adaptations

- Draft: root, writable rootfs. Target: `USER apps` (inherited from nginx base), static files read-only in `/usr/share/nginx/html`, nginx pid and temp dirs in `/tmp` (base `nginx.conf` already does this), config in `/config`.
- No app writes: all state is in the browser (GEDCOM files are opened and saved client-side); no extra persistence.

## 10. Risks, caveats and open questions

- No releases: version is a commit SHA; Renovate will bump to every commit on `main`. Consider pinning and reviewing manually.
- Docker Hub image is from 2021; the repo `main` may differ. Not blocking.
- The app may need HTTPS (service worker, clipboard); terminate TLS on the ingress (UNVERIFIED).
- Runtime CDN: `index.html` loads `isomorphic-git@beta` and `lightning-fs` from unpkg.com (unversioned or `beta` tags). Vue, Materialize and the Graphviz wasm are local under `resources/`. Consider vendoring the unpkg scripts for offline use.
- Difficulty is overstated now that the source is found; only open question is whether a build step exists.

## 11. Build and test steps

```sh
cd apps/genea
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create genea-probe-config
docker run --rm -d --name genea-probe --read-only --tmpfs /tmp -v genea-probe-config:/config genea:<sha>
docker logs -f genea-probe     # expect nginx started, no [emerg]
curl -fsS http://localhost:8080/ | head   # from the host with -p 8080:8080, expect the Genea index.html
forgetool containers test --image genea:<sha> --config ./apps/genea/container-test.yaml
docker rm -f genea-probe; docker volume rm genea-probe-config
```

## 12. PR checklist

- Branch `feat/add-genea`, commit `feat(genea): add new container`.
- Template filled, `🤖 This PR is AI generated.` in Notes.
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: build, asset selection, CDN dependencies, arm64.
