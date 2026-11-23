# homelablabelmaker — implementation plan
> Source: ./draft.md · Target: apps/homelablabelmaker/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No releases or tags (`/releases/latest` redirects to the empty releases page). The draft pins commit `d52776c7bd405bf388f53a725a640f2c1a461ae4` (the Dockerfile link). Use that SHA as `VERSION`. UNVERIFIED: whether it is still the head of `master` (the commit feed shows last activity 2020-03-27, so very likely). |
| Renovate | `// renovate: datasource=git-refs depName=https://github.com/DavidSpek/homelablabelmaker currentValue=master` (same style as `apps/tvheadend/docker-bake.hcl`). |
| License | None found: no `LICENSE` file at the pinned commit (raw URL 404) and GitHub reports no license. UNVERIFIED, see section 10. |
| Source URL | https://github.com/DavidSpek/homelablabelmaker (default branch `master`) |
| Download | Source archive `https://github.com/DavidSpek/homelablabelmaker/archive/<sha>.tar.gz`. Static files, so the same for amd64 and arm64. |
| Checksum | None published. The 40-char commit SHA in the URL pins the content. |
| Repo content | `index.html`, `css/`, `fonts/`, `img/`, `js/`, `v1/`, `reddit_snoo.png`, `README.md`, `Docker Files/`. |
| Upstream Dockerfile reviewed | `Docker Files/Dockerfile`: `FROM httpd:alpine`, `apk add git`, `git clone`, `mv ./homelablabelmaker/* /usr/local/apache2/htdocs/`. No env vars, no config, no volumes. |
| Port | The upstream image serves on 80 (Apache). The draft's 8080 is the nginx base default (`apps/nginx` `EXPOSE 8080`), so 8080 is correct for this image. |
| Env vars | None. |

## 2. Target layout

```
apps/homelablabelmaker/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  defaults/default.conf              # nginx server block
  docker-entrypoint.d/10-copyconfig.sh   # seeds /config/sites/default.conf
```

`defaults/` and `docker-entrypoint.d/` are the same pattern as `apps/it-tools` (both allow-listed by `include/.dockerignore`). No `start.sh`: the nginx base's `CMD` runs nginx through the ubuntu entrypoint, which runs `docker-entrypoint.d/*.sh` first. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Builder: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
Final: `ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`.
Why: static files served by nginx, as the draft says. Closest sibling: `apps/it-tools` (builder stage plus nginx final stage, `COPY --from=builder --chown=568:568`).

## 4. Dockerfile

1. Stage `builder` (ubuntu): `ARG VERSION`; `USER root`; `WORKDIR /tmp/src`; one RUN: `curl -fsSL "https://github.com/DavidSpek/homelablabelmaker/archive/${VERSION}.tar.gz" | tar xz --strip-components=1`, then `mkdir /tmp/site && cp -r index.html css fonts img js v1 reddit_snoo.png /tmp/site/` (drop `README.md` and `Docker Files/`). Fail if `index.html` is missing. No apt packages (curl and tar are in the base).
2. Final stage (nginx): `USER root`; `COPY --from=builder --chown=568:568 /tmp/site/ /usr/share/nginx/html/`.
3. Licenses: upstream ships none, so nothing to copy to `/usr/share/licenses/homelablabelmaker/`; add a one-line `NOTICE` there stating the source URL and commit so provenance is visible (create it in the RUN, not as a repo file).
4. `COPY --chmod=0755 . /` (it-tools has it twice, once as root and once after `USER apps`; keep the one after `USER apps` mandatory, and keep the earlier one only if the sibling needs it, check at implementation).
5. `USER apps`; `WORKDIR /usr/share/nginx/html`. EXPOSE 8080 and the nginx `CMD` are inherited from the base. No `VOLUME` needed beyond the inherited `/config`.

## 5. docker-bake.hcl

- `APP` = `homelablabelmaker`
- `VERSION`: renovate comment above, `default = "d52776c7bd405bf388f53a725a640f2c1a461ae4"`
- `LICENSE`: no upstream license exists. Open question; do not invent one. Use `NOASSERTION` only if the maintainer accepts that value, otherwise ask upstream (issue on the repo) first.
- `SOURCE` = `https://github.com/DavidSpek/homelablabelmaker`
- Standard targets from `apps/it-tools/docker-bake.hcl` (`docker-metadata-action`, `image`, `image-local`, `image-all`, default group). `image-local` tag will be `homelablabelmaker:<sha>`; the long SHA is a valid tag.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/DavidSpek/homelablabelmaker"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

No `dependencies`. (`TZ` is listed as in `it-tools`; the app itself reads nothing.)

## 7. start.sh

Not applicable: no `start.sh`. Startup config comes from `docker-entrypoint.d/10-copyconfig.sh` (bash, executable):

```bash
#!/usr/bin/env bash
echo "[10-copyconfig] Seeding nginx site config for homelablabelmaker"
mkdir -p /config/sites
if [ ! -f /config/sites/.homelablabelmaker-seeded ]; then
  cp /defaults/default.conf /config/sites/default.conf
  touch /config/sites/.homelablabelmaker-seeded
fi
```

Why the marker: the nginx base's own `03-copyconfig.sh` already does `cp -n` of its default site file, and it-tools overwrites it on every start. The marker overwrites once (to replace the nginx default) and then leaves user edits alone. `defaults/default.conf` is the it-tools server block (listen 8080 and `[::]:8080`, `root /usr/share/nginx/html`, `try_files $uri $uri/ /index.html`). Listening on all interfaces is covered by `listen 8080`. The base `nginx.conf` already puts `pid` and temp paths in `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /
filePaths:
- /usr/share/nginx/html/index.html
```

`timeoutSeconds` left at the default like `it-tools` and `theme-park` (they set none). No env needed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| Apache logs and pid under `/usr/local/apache2` | Replaced by nginx; pid and temp dirs in `/tmp`, logs to stdout/stderr via the base. |
| `git clone` at build time | Replaced by a pinned tarball. |
| Site config | `/config/sites/default.conf`, seeded on first start. |

The chart runs as UID 0 with a writable rootfs; here UID 568, `--read-only` with `/tmp` tmpfs, port 8080 (no privileged port needed). No extra persistence: static content stays in the image.

## 10. Risks, caveats and open questions

- **No license** in the repository: `LICENSE` in docker-bake.hcl cannot be filled truthfully. Ask upstream or the maintainer before publishing; this is the main blocker for merging.
- No releases: updates follow `master` commits via renovate `git-refs` (draft caveat, confirmed).
- UNVERIFIED: that `index.html` is self-contained (it may load fonts/scripts from CDNs; the image then needs internet in the browser, not in the container).
- UNVERIFIED: the exact top-level file list at the pinned commit; adjust the `cp` list after unpacking (fail loudly on missing entries).
- Draft port was marked inferred; confirmed correct for the nginx base.
- No musl, GPU, privileged or arm64 issues.

## 11. Build and test steps

```sh
cd apps/homelablabelmaker
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create homelablabelmaker-probe-config
docker run --rm -d --name homelablabelmaker-probe --read-only --tmpfs /tmp \
  -v homelablabelmaker-probe-config:/config homelablabelmaker:d52776c7bd405bf388f53a725a640f2c1a461ae4
docker logs -f homelablabelmaker-probe
```

Readiness: log lines `[10-copyconfig] Seeding ...` followed by nginx start without `emerg`/`alert`; `curl http://<container>:8080/` returns the label maker page from a second container. Restart on the same volume to confirm no re-seed. Then `forgetool containers test --image homelablabelmaker:<sha> --config ./apps/homelablabelmaker/container-test.yaml`, and `docker rm -f` plus `docker volume rm`.

## 12. PR checklist

- Branch `feat/add-homelablabelmaker`, commit and PR title `feat(homelablabelmaker): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; tick only what applies.
- Notes: `🤖 This PR is AI generated.` and the license question.
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Honest untested list: arm64 build, behaviour of external CDN assets, license status.
