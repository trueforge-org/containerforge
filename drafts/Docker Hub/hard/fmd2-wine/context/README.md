# Context for fmd2-wine

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://github.com/Banh-Canh/docker-FMD2 | github-banh-canh-docker-fmd2.md |
| https://github.com/Banh-Canh/docker-FMD2/blob/master/Dockerfile | github-banh-canh-docker-fmd2.md (raw Dockerfile) |
| https://github.com/dazedcat19/FMD2 | github-dazedcat19-fmd2.md |
| https://api.github.com/repos/dazedcat19/FMD2/releases/latest | github-dazedcat19-fmd2.md (asset names) |
| https://hub.docker.com/r/banhcanh/docker-fmd2 | dockerhub-banhcanh-docker-fmd2.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fmd2-wine | truecharts-fmd2-wine.md |

## Skipped URLs

Skipped categories: CLA link; containerforge apps/<base> links (ubuntu, kasmvnc); ghcr image refs (`ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble`); binary download `releases/download/.../fmd_..._x86_64-win64.7z` (asset name recorded in github-dazedcat19-fmd2.md, not downloaded).

Linked from fetched pages but not in the URL list (not fetched): https://github.com/ElryGH/docker-FMD2 (fork named in the upstream README), https://github.com/Bealvio/fmd2-oci (linked from Docker Hub page), https://github.com/TKVH-Apps/fmd2 (Kubernetes variant).

## Fetch failures

- None.

## plan.md corrections

- Section 1, "Download" row: "The release has 4 assets" -> "The release has 2 assets (`fmd_${VERSION}_i386-win32.7z`, `fmd_${VERSION}_x86_64-win64.7z`)" and "UNVERIFIED by name" -> "asset name verified via the GitHub API". Source: github-dazedcat19-fmd2.md (GitHub API `releases/latest`, 2 assets listed).
- Unverified conflict (not edited): plan section 1 and section 6 use ports 3000/3001 (consistent with upstream `EXPOSE 3000` and compose `3000:3000`), but the TrueCharts chart's service port is `6080`. Source: truecharts-fmd2-wine.md vs github-banh-canh-docker-fmd2.md. Not resolved.
- Unverified (not edited): plan section 4 installs `wine32:i386`. Upstream Dockerfile installs only `wine64` (after `dpkg --add-architecture i386`). Upstream pins `wine64=9.0~repack-4build3`; plan's pin statement is UNVERIFIED for Ubuntu 26.04 as before.
- Unverified (not edited): license "or later" wording. Source README says "GPLv2 license" with no "or later". Plan's `GPL-2.0-only` remains consistent but unconfirmed.
- Unverified (not edited): checksum. GitHub API returned no digest or checksum asset.
