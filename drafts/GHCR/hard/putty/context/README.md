# Context: putty

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/putty/values.yaml + Chart.yaml | truecharts-putty.md |
| https://raw.githubusercontent.com/jlesage/docker-putty/v26.09.1/Dockerfile (+ blob URL duplicate) | docker-putty-dockerfile.md |
| https://github.com/jlesage/docker-putty (fetched as raw README at tag v26.09.1) | docker-putty-readme.md |

Skipped: blob variant of the Dockerfile (duplicate of raw); github.com repo HTML page (replaced by raw README at v26.09.1); upstream source tarball https://the.earth.li/~sgtatham/putty/0.85/ (binary/source download, not fetched).

Failures:
- https://www.putty.org: returned an unrelated notice page ("Final Warning"), not the PuTTY project site. Upstream README links https://putty.software as the PuTTY website. Not retried.

## plan.md corrections
1. Line 8 (Chart image): `ghcr.io/jlesage/putty:v26.09.1` -> `ghcr.io/jlesage/putty:v26.11.2` (source: TrueCharts values.yaml tag `v26.11.2@sha256:f04c14dc...`; chart appVersion 26.11.2).
2. Line 12 (Source URL): `https://www.putty.org/` -> `https://putty.software` (source: docker-putty README links PuTTY to putty.software; putty.org returned unrelated page).
3. Line 17 (Env): "No user-facing env var was confirmed." replaced with a note that the upstream README documents user env vars (source: docker-putty-readme.md). Plan does not reuse the jlesage base scripts that read them.

Unverified conflict (not edited): plan line 9 says latest upstream release is v26.09.1 (2026-09-22), but the TrueCharts chart pins image tag v26.11.2, which is newer. The release date and tag list were not re-checked here (GitHub API was not called).
