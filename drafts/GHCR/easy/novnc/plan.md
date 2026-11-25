# novnc — implementation plan
> Source: ./draft.md · Target: apps/novnc/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | noVNC v1.7.0, published 2026-04-28 (https://api.github.com/repos/novnc/noVNC/releases/latest). No release assets. Tag object sha `9e7def8703ac3234c4bae0cd08663f5dd526ee22` (https://api.github.com/repos/novnc/noVNC/git/ref/tags/v1.7.0). |
| Renovate | `datasource=github-tags depName=novnc/noVNC versioning=semver` (v-prefixed tags). |
| License | MPL-2.0 (package.json and LICENSE.txt, https://raw.githubusercontent.com/novnc/noVNC/v1.7.0/LICENSE.txt). GitHub API reports NOASSERTION (mixed licenses), so use LICENSE.txt as authority. |
| Source | https://github.com/novnc/noVNC |
| Download | Tag tarball https://api.github.com/repos/novnc/noVNC/tarball/v1.7.0 or git checkout of the tag. |
| Checksum source | None published upstream. UNVERIFIED: pin the tag commit sha in the Dockerfile, or record the tarball sha256 at build time. |
| websockify | 0.13.0 on PyPI, LGPLv3 (https://pypi.org/pypi/websockify/json). Wheel `websockify-0.13.0-py3-none-any.whl`. Digest UNVERIFIED. |
| Draft's image | `ghcr.io/nicholaswilde/novnc:version-1.2.0`. Upstream Dockerfile at `caa724f` (https://raw.githubusercontent.com/nicholaswilde/docker-novnc/caa724f/Dockerfile) is based on `ghcr.io/linuxserver/baseimage-alpine:3.14`, clones noVNC and websockify 0.9.0 from git, installs python2/python3, `ENV REMOTE_HOST=localhost`, `ENV REMOTE_PORT=5900`, `EXPOSE 6080`, `VOLUME /app`, `CMD ["sh","-c","./utils/launch.sh --vnc ${REMOTE_HOST}:${REMOTE_PORT}"]`. The draft's nginx port 8080 is not in this Dockerfile. UNVERIFIED whether `caa724f` matches tag version-1.2.0. |
| Env vars | REMOTE_HOST (default `localhost`), REMOTE_PORT (default `5900`), from the upstream Dockerfile. |
| Port | 6080 (websockify serves the static web client with `--web`). |
| Data paths | None found. |
| Dependency | A reachable VNC server, supplied by the user or another container. |

## 2. Target layout

- `apps/novnc/Dockerfile`
- `apps/novnc/docker-bake.hcl`
- `apps/novnc/settings.yaml`
- `apps/novnc/container-test.yaml`
- `apps/novnc/start.sh`

No `defaults/`, `etc/` or `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. websockify is a Python package and noVNC is static files, so the python base fits. Nginx is not needed because websockify serves the files with `--web`. Closest sibling: `apps/bazarr` (python). The draft's nginx base is not used. Ubuntu base is not needed.

## 4. Dockerfile

1. `ARG VERSION`, `USER root`.
2. Fetch the noVNC v1.7.0 tarball to `/tmp`, verify the pinned hash, extract to `/app/novnc`.
3. Install websockify from PyPI into `/app/venv`-style location or the base venv (check the python base's venv rules in `python-runtime.instructions.md`; do not write to `/app/venv` at runtime). Pin `websockify==0.13.0`.
4. Ship the noVNC license: `/usr/share/licenses/novnc/LICENSE.txt` from the tarball.
5. `ENV REMOTE_HOST=localhost REMOTE_PORT=5900`, `ENV HOME=/config`.
6. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 6080`, `VOLUME /config`.

## 5. docker-bake.hcl

- `APP` = `novnc`; `VERSION` = `1.7.0` with `// renovate: datasource=github-tags depName=novnc/noVNC versioning=semver`.
- `LICENSE` = `MPL-2.0`; `SOURCE` = `https://github.com/novnc/noVNC`.
- Standard four targets and default group. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header and `schema_version: 1`; `upstream_env_url: "https://github.com/novnc/noVNC"`.
- `ports`: 6080/tcp, `required: true`.
- `env`: `REMOTE_HOST` (default `localhost`), `REMOTE_PORT` (default `5900`), both `required: false`.
- `volumes`: `/config` required.
- `dependencies`: none (external VNC server is not a ContainerForge dependency).

## 7. start.sh

- `exec websockify --web /app/novnc 6080 "${REMOTE_HOST}:${REMOTE_PORT}"`.
- No config to seed; nothing written to `/app`.
- Bind `0.0.0.0` by default in websockify (UNVERIFIED on this version; check the listen address in logs).

## 8. container-test.yaml

- Schema header; `timeoutSeconds` from python siblings (UNVERIFIED value).
- `tcp: - port: '6080'`; `http: - port: '6080', path: /vnc.html` (UNVERIFIED path in the release).
- `filePaths: [/app/novnc/vnc.html, /usr/share/licenses/novnc/LICENSE.txt]`.

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps`, port 6080 is unprivileged.
- Only `/tmp` and `/config` are writable.
- The chart's `runAsUser 0` and `readOnlyRootFilesystem false` are not carried over.

## 10. Risks, caveats and open questions

- The draft's image and nginx port do not match the fetched upstream Dockerfile. Use the plan above, not the draft's port 8080.
- The noVNC checksum is UNVERIFIED upstream; the build pins the commit.
- No VNC server in the test, so the test only proves the web side starts.
- Blockers: none found.

## 11. Build and test steps

```sh
cd apps/novnc
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name novnc-probe --read-only --tmpfs /tmp -v novnc-probe-config:/config novnc:1.7.0
docker logs -f novnc-probe
forgetool containers test --image novnc:1.7.0 --config ./apps/novnc/container-test.yaml
docker rm -f novnc-probe; docker volume rm novnc-probe-config
```

Expected readiness: websockify logs that it is listening on 6080 (exact line UNVERIFIED).

## 12. PR checklist

- Branch `feat/add-novnc`; commit `feat(novnc): add new container`.
- PR template; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Not tested: no build or run in this planning step.
