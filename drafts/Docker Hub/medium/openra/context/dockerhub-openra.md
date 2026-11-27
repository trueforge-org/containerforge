# Docker Hub: rmoriz/openra
Source URL(s): https://hub.docker.com/v2/repositories/rmoriz/openra/ , .../tags?page_size=10 (fetched 2026-11-27)

## What it is
- "Docker Images for openRA.net"; OpenRA dedicated server image by Roland Moriz (rmoriz)
- Pulls 1,963,267; stars 7; status active; last_updated 2021-03-22 (no updates since 2021)
- Readme: Dockerfile at https://github.com/rmoriz/openra-dockerfile ; license GPL-3.0 (OCI label)

## Tags (10 most recent of 36)
| Tag | Last updated | Arch |
| --- | --- | --- |
| latest, latest-amd64 | 2021-03-22 | amd64 |
| master, master-amd64 | 2021-03-22 | amd64 |
| 20210321, 20210321-amd64 | 2021-03-22 | amd64 |
| 20200503, 20200503-amd64 | 2020-05 | amd64 |
| master-arm | 2020-02-01 | arm |
| master-aarch64 | 2020-02-01 | arm64 |

- Manifest list `latest`: only amd64 listed in the tag results. Readme says amd64, arm32v5, aarch64 (2019 news).

## Install/build (see github-openra-dockerfile.md)
- Base: FROM ${BASE_IMAGE_PREFIX}mono (official mono image, Debian)
- Build arg OPENRA_RELEASE_VERSION (default 20231010), OPENRA_RELEASE_TYPE (default release)
- Source tarball: https://github.com/OpenRA/OpenRA/releases/download/${type}-${version}/OpenRA-${type}-${version}-source.tar.bz2
- Build: `make all RUNTIME=mono`, files moved to /home/openra/lib/openra

## Runtime deps (apt, kept)
ca-certificates, liblua5.1, libsdl2-2.0-0, libopenal1, xdg-utils, zenity, wget
(build-only and purged: curl, make, patch, unzip)

## Entrypoint/CMD
- CMD ["/home/openra/lib/openra/launch-dedicated.sh"] (no ENTRYPOINT)
- WORKDIR /home/openra/lib/openra

## Env vars
- OPENRA_RELEASE_VERSION (build-time, ENV default 20231010)
- OPENRA_RELEASE_TYPE (build-time, default release)
- OPENRA_RELEASE (build-time, full tarball URL)
- Runtime env read by launch-dedicated.sh: see github-openra-launch-dedicated.md

## Ports
- EXPOSE 1234

## Volumes/paths
- VOLUME ["/home/openra/.openra"] (created with Logs/ and maps/ subdirs, owned by openra)

## User/UID
- useradd openra (no fixed UID stated), USER openra; home /home/openra, shell /sbin/nologin

## Healthcheck
- none defined

## Version/asset naming
- Tag form: release-YYYYMMDD / 20210321 etc.; GitHub release assets: OpenRA-release-20250330-source.tar.bz2

## Arch
- amd64 confirmed in tag data; arm/arm64 tags last built 2020

## Gotchas
- Image not rebuilt since 2021; the `latest` tag points to 2021 build
- Server with RA mod needs >=500MB memory (readme)
- Port 1234 default; Kubernetes NodePort optional
