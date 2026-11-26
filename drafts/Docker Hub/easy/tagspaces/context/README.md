# tagspaces context

Fetched 2026-11-26.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/tagspaces/tagspaces (LICENSING.md, README.md, package.json at v6.15.1; releases page) | github-tagspaces-tagspaces.md |
| https://github.com/tagspaces/tagspaces/releases | github-tagspaces-tagspaces.md |
| https://github.com/fardjad/tagspaces-lite-docker (Dockerfile at 495b180) | github-fardjad-tagspaces-lite-docker.md |
| https://hub.docker.com/r/fardjad/tagspaces-lite-web | dockerhub-fardjad-tagspaces-lite-web.md |
| https://docs.tagspaces.org/ | docs-tagspaces.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tagspaces (values.yaml) | truecharts-tagspaces.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema (skip rule).
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu and .../apps/nginx: containerforge base app links (skip rule).
- https://github.com/tagspaces/tagspaces/releases/download/v6.0.2/tagspaces-linux-amd64-6.0.2.deb, .../v6.0.2/tagspaces-mac-arm64-6.0.2.zip, .../v6.15.1/tagspaces-web-6.15.1.zip, .../v${VERSION}/tagspaces-web-${VERSION}.zip, and .../v6.15.1/SHA256SUMS.txt (and the v6.15.1 SHA256SUMS in plan.md): release assets / archive downloads (skip rule). Asset names are recorded in github-tagspaces-tagspaces.md.
- https://github.com/tagspaces/tagspaces (repo root): covered.
- https://github.com/fardjad/tagspaces-lite-docker/blob/495b180.../Dockerfile: covered by the raw Dockerfile.
- https://docs.tagspaces.org/ and the draft's docs link: covered.

## Fetch failures

- None. The web zip and its SHA256SUMS entries were not visible in the releases list; plan.md's HTTP 200 and checksum were not re-checked here.

## plan.md corrections

None made. Checked and consistent:
- Version 6.15.1 (16 Nov, Latest) and 6.0.2 as the draft's stale version.
- AGPL-3.0 core with proprietary Pro; Lite packages hold only the AGPL core.
- Upstream Dockerfile at 495b180: unzip a web zip, copy `web` into the nginx web root, `EXPOSE 8080`.
- `npm run run-web` for the web build (README).

## Unverified (not changed in plan.md)

- Section 1 "tagspaces-web-6.15.1.zip returned HTTP 200, 24.5 MB" and the SHA256 `acf12dec...` in SHA256SUMS: web zip not visible in the releases list; not re-checked here.
- Section 1 "archived by its author": the fardjad Docker Hub and Dockerfile pages do not say so. Left as is.
- Section 1 "no server env vars": the TrueCharts chart sets an env `KEY` from a secret (truecharts-tagspaces.md). Whether the lite image reads it is not confirmed. Left as is.
- Section 8 `extconfig.js`, `sw.js`, `LICENSE.txt` inside the zip: zip not fetched.
- Section 10 PWA/service worker and "secure context" claim: not stated on fetched pages (the build has sw.js in the plan only).
- Section 10 "LICENSING.md states Lite builds contain only the AGPL core": confirmed by LICENSING.md. The question whether the non-Pro web zip counts as Lite is open (left as is).
- Section 1 "AGPL-3.0-only vs or-later": source headers not read.
