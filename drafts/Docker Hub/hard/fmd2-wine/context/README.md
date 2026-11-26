# Context for fmd2-wine

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://github.com/Banh-Canh/docker-FMD2 | github-banh-canh-docker-fmd2.md |
| https://github.com/Banh-Canh/docker-FMD2/blob/master/Dockerfile | github-banh-canh-docker-fmd2.md |
| https://github.com/dazedcat19/FMD2 | github-dazedcat19-fmd2.md |
| https://api.github.com/repos/dazedcat19/FMD2/releases/latest | github-dazedcat19-fmd2.md |
| https://hub.docker.com/r/banhcanh/docker-fmd2 | dockerhub-banhcanh-docker-fmd2.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fmd2-wine | truecharts-fmd2-wine.md |

Skipped: CLA link, containerforge apps/<base> links (ubuntu, kasmvnc), ghcr image refs (`ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble`), templated binary download `releases/download/${VERSION}/fmd_..._x86_64-win64.7z` (asset name recorded in github-dazedcat19-fmd2.md). Linked but not in the URL list, not fetched: ElryGH/docker-FMD2 (fork named in the upstream README), Bealvio/fmd2-oci, TKVH-Apps/fmd2.

## Fetch failures

- None.

## plan.md corrections

- Section 1, Download row: "The release has 4 assets" -> "The release has 2 assets (`fmd_${VERSION}_i386-win32.7z`, `fmd_${VERSION}_x86_64-win64.7z`)"; "UNVERIFIED by name" -> "asset name verified via the GitHub API". Source: github-dazedcat19-fmd2.md.
- Unverified conflict (not edited): plan uses ports 3000/3001, consistent with upstream (`EXPOSE 3000`, compose `3000:3000`), but the TrueCharts chart's service port is `6080`. Source: truecharts-fmd2-wine.md.
- Unverified (not edited): plan section 4 installs `wine32:i386`; the upstream Dockerfile installs only `wine64` (after `dpkg --add-architecture i386`).
- Unverified (not edited): license "or later". README says "GPLv2 license" only.
- Unverified (not edited): checksum. The GitHub API returned no digest or checksum asset.
