# auto-yt-dl — implementation plan
> Source: ./draft.md · Target: apps/auto-yt-dl/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | UNVERIFIED: no version or tag is published. Docker Hub image `guhu007/auto-yt-dl` (50K+ pulls, about 66.8 MB) was last updated almost 3 years ago; the chart uses `latest`. |
| Renovate | Not applicable: no upstream releases or tags. A pip-installed dependency (see below) could be tracked with `datasource=pypi`, but that is not the app. |
| License | UNVERIFIED: no source repository, no license text. |
| Source URL | https://github.com/xXGuhuXx/auto-yt-dl returns HTTP 404. The Docker Hub page lists no source link. |
| Downloads | None. There is no release asset, package or Dockerfile. The only artifact is the Docker Hub image (draft: `copy-from` path "app directory, path unknown"). |
| Checksum | None. |
| Upstream Dockerfile reviewed | None exists publicly. |
| What the Docker Hub page says | A web GUI to add and remove YouTube channels; every 15 minutes it compares each channel's stored video URLs and downloads new uploads; built with pytube; written for unRaid; port `5000/tcp` for the GUI; downloads written to `/app/Downloads` (example mount `-v /test:/app/Downloads:rw`). No env vars documented. The example run command uses a differently named image (`xxguhuxx/yt-channel-dl:latest`). |
| Draft `/app/data` | Chart persistence `/app/data` (pvc) is not mentioned on Docker Hub: UNVERIFIED what it holds (probably the channel list). |

## 2. Target layout

Not ready to scaffold. If the blockers in section 10 are resolved by the maintainers, the layout would be:
```
apps/auto-yt-dl/
  Dockerfile, docker-bake.hcl, settings.yaml, container-test.yaml, start.sh
```
No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Candidate: `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (the app is Python/pytube per Docker Hub; draft's "ubuntu" was a guess). UNVERIFIED that the app is Flask or similar. Closest sibling: `apps/bazarr` (python with a web UI, `/config` persistence).

## 4. Dockerfile

Cannot be written faithfully: the code is not public. Only an extraction from `guhu007/auto-yt-dl` (inspect `/app`) would reveal the code, and copying unlicensed code from a third-party image into our registry is not acceptable without the author's permission. If permission or source appears, the steps would be:
1. `ARG VERSION`, `USER root` only for installs.
2. Install the app's pinned requirements into `/app/venv` (python base), caches via `PIP_CACHE_DIR=/tmp/pip`; follow `python-runtime.instructions.md` (read-only `/app/venv`).
3. Copy source to `/app`; map `/app/Downloads` to `/config/downloads` and `/app/data` to `/config/data` by symlink or app setting.
4. License files to `/usr/share/licenses/auto-yt-dl/`.
5. `COPY --chmod=0755 . /`, `EXPOSE 5000`, `VOLUME /config`, final `USER apps`.

## 5. docker-bake.hcl

Not applicable until a source and version exist. It would use `APP=auto-yt-dl`, `SOURCE` of the real repo, `LICENSE` of that repo, and the 4 standard targets plus default group as in `apps/bazarr/docker-bake.hcl`. A Renovate comment is only possible with a real tagged upstream.

## 6. settings.yaml

Draft facts only (UNVERIFIED beyond Docker Hub):
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "<unknown: repo 404>"
ports:
  - {port: 5000, protocol: tcp, required: true}
env: []        # none documented; do not invent any
volumes:
  - {path: /config, required: true}
```
Dependencies: none.

## 7. start.sh

Not applicable until the app's entrypoint is known. Requirements when it is: create `/config/downloads` and `/config/data` when missing, bind `0.0.0.0:5000`, caches to `/tmp`, `exec` the app.

## 8. container-test.yaml

Would contain the schema header, `tcp` probe on port `5000`, an `http` GET `/` probe, and `filePaths` for the app entrypoint. `timeoutSeconds` copied from `apps/bazarr`. Not writable correctly yet.

## 9. Rootless and read-only-rootfs adaptations

Known write targets from the draft: `/app/Downloads` (chart mounts a host path) and `/app/data` (pvc). Both are under `/app`, which is read-only here, so both must move to `/config` (`/config/downloads`, `/config/data`) or be mounted by the user. The chart runs as UID 0 with `readOnlyRootFilesystem: false`; ours must be `apps`, read-only, not privileged. Host-path ownership may not match the `apps` UID (draft caveat, inferred).

## 10. Risks, caveats and open questions

- BLOCKER: no public source, repo 404 (confirmed), license unknown, last image update about 3 years old. Behaviour and dependencies cannot be verified, and redistributing unlicensed code is not possible.
- pytube is known to break frequently against YouTube changes (general knowledge, not verified from this page); an unmaintained image will likely not download anything today.
- Draft caveat confirmed: downloading from YouTube may breach platform terms and local law; maintainers should decide whether to host this at all.
- Docker Hub example uses a different image name (`xxguhuxx/yt-channel-dl`), so image provenance is unclear.
- arm64 and amd64 availability of the Docker Hub image: UNVERIFIED (draft says `no*`).
- Recommendation: do not port. Options are to ask the TrueCharts maintainers to switch the chart to a maintained project with public source (for example a yt-dlp based channel downloader with a real license), or to close this draft as not portable.

## 11. Build and test steps

Not applicable now: nothing to build. If a source is adopted, follow the protocol: `docker buildx bake --print`, `docker buildx bake --set image-local.platform=linux/amd64 image-local`, run with `--read-only --tmpfs /tmp` and a fresh `/config` volume (`auto-yt-dl-probe`, `auto-yt-dl-probe-config`), then `forgetool containers test --image auto-yt-dl:<version> --config ./apps/auto-yt-dl/container-test.yaml`. Readiness signal expected: the web server on 5000 listening (UNVERIFIED log text).

## 12. PR checklist

- No PR should be opened for this draft until a source exists.
- When it does: branch `feat/add-auto-yt-dl`, commit `feat(auto-yt-dl): add new container`, fill the PR template, put `🤖 This PR is AI generated.` in Notes, and tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State as untested: everything (no build, no run, no license, no version).
