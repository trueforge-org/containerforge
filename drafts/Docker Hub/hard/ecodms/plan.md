# ecodms — implementation plan
> Source: ./draft.md · Target: apps/ecodms/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | UNVERIFIED for the chart image: `ecodms/allinone-18.09:latest` is the only tag, ecoDMS 18.09 (apu), about 729.5 MB, last updated about 3 years ago (Docker Hub). The vendor's current release is Build 26.01 (per the current installation manual, 2026). The chart is therefore 8 years behind. |
| Renovate | Not applicable: no GitHub/registry datasource for the vendor repository `http://www.ecodms.de/ecodms_260164/...`. The path segment changes per release (`ecodms_250264`, `ecodms_260164` seen in manuals); manual bumps. |
| License | Proprietary, commercial (ecoDMS GmbH). No SPDX id (use `LicenseRef-ecoDMS-Proprietary`, UNVERIFIED). The image would redistribute vendor packages; permission is UNVERIFIED. |
| Source URL | https://www.ecodms.de/ (download page https://www.ecodms.de/de/download). Closed source, no repository. |
| Downloads | Vendor apt repository (Debian/Ubuntu), per the vendor's download page for Build 26.01: Ubuntu 24.04 `deb http://www.ecodms.de/ecodms_260164/noble /`, key `http://www.ecodms.de/gpg/ecodms.key`, package `ecodmsserver` (also `ecodmsclient`, `ecodmspackages`). Debian 12/13 entries also exist. Ubuntu 26.04 repository: UNVERIFIED (not listed). Architecture: amd64 only per draft, arm64 UNVERIFIED. |
| Checksum | apt repository signature only (GPG key above); no standalone checksum. |
| Upstream Dockerfile reviewed | None public (draft says `-`). Docker Hub description only: ports 17001 (standard ecoDMS port), 8080 (web), 8180; volumes `/srv/data`, `/srv/scaninput`, `/srv/backup`, `/srv/restore`; no env vars documented; backup by uploading an empty file `create` into the backup folder; restore by placing `restore.zip` in the restore folder. Sources: https://hub.docker.com/r/ecodms/allinone-18.09 and https://ecodms.datamagic.at/download/. |
| Manual notes | The server package bundles a PostgreSQL database and a container storage system; on VMs `haveged` is recommended; installation shows interactive dialogs (needs `DEBIAN_FRONTEND=noninteractive`, UNVERIFIED how the package behaves then). |

## 2. Target layout

Not ready to scaffold. If maintainers accept the blockers, the layout would be:
```
apps/ecodms/
  Dockerfile, docker-bake.hcl, settings.yaml, container-test.yaml, start.sh
```
No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (the draft's alternative `java17` is unnecessary if the vendor package pulls its own Java as a dependency; UNVERIFIED which Java it needs). Vendor packages target Ubuntu 24.04 `noble`, so Ubuntu 26.04 compatibility is UNVERIFIED. Closest sibling: `apps/nextcloud-fpm` is not analogous; for multi-service in a single container look at `apps/unifi-network-application` (Java + bundled MongoDB handling) and `apps/postgresql` for DB start logic.

## 4. Dockerfile

Cannot be written faithfully today. Intended steps if permitted:
1. `ARG VERSION`, `USER root`; add the vendor apt source and key to `/etc/apt/sources.list.d/ecodms.list` and `/etc/apt/trusted.gpg.d/ecodms.asc` (path per the vendor guide, noble repo).
2. `DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ecodmsserver=<pinned version>` (pin the apt version and check it matches `VERSION`, as `apps/valkey` does; version string UNVERIFIED), `haveged` if needed.
3. Relocate the packaged PostgreSQL data dir, ecoDMS data dir and logs from `/var/lib`, `/var/log`, `/etc` to `/config` (needs knowledge of the package layout, UNVERIFIED) and make `/app` hold only read-only binaries.
4. Vendor license/EULA files to `/usr/share/licenses/ecodms/` (UNVERIFIED which exist).
5. `COPY --chmod=0755 . /`, `EXPOSE` the real ports, `VOLUME /config`, final `USER apps`.

## 5. docker-bake.hcl

Not applicable until a pinned version exists. Shape: `APP=ecodms`, `VERSION` = package version (no renovate datasource, so no annotation; explain in a comment), `LICENSE=LicenseRef-ecoDMS-Proprietary`, `SOURCE=https://www.ecodms.de/`, standard four targets with `image-all` limited to `linux/amd64` (arm64 UNVERIFIED), `default` group. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Draft facts plus Docker Hub (not all verified for an Ubuntu-based rebuild):
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.ecodms.de/"
ports:
  - {port: 8080, protocol: tcp, required: true}
  - {port: 17001, protocol: tcp, required: false}
  - {port: 8180, protocol: tcp, required: false}
env:
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - {path: /config, required: true}
  - {path: /config/data, required: true}
  - {path: /config/scaninput, required: false}
  - {path: /config/backup, required: false}
  - {path: /config/restore, required: false}
dependencies: []
```
Ports 8080, 17001, 8180 come from the Docker Hub run example (host 17004->8080, 17005->8180, 17001). The draft's port 80 is not confirmed and is dropped. No env vars are documented for the image; do not invent any. The volume layout under `/config` replaces the chart's `/srv/*` mounts (see 9). Dependencies: none (PostgreSQL is bundled in the vendor package; the ✅ `apps/postgresql` could replace it, UNVERIFIED if ecoDMS supports an external DB).

## 7. start.sh

Not writable until the package layout is known. Requirements: create `/config/{data,scaninput,backup,restore}` when missing; init the bundled PostgreSQL only if its data dir is empty; start PostgreSQL, then the ecoDMS server (Tomcat/Java) in order; passwords for the bundled DB read from env or generated once into `/config` and applied each start; bind `0.0.0.0`; a process supervisor for multiple services (none is in the base, UNVERIFIED); final `exec` of the supervisor or main service; backup trigger via the `create` file in the backup dir and restore via `restore.zip` stay vendor behavior.

## 8. container-test.yaml

Would use the schema header, `tcp` probes for each port in settings.yaml (8080, 17001, 8180), an `http` probe on 8080 `/`, `filePaths` for the server binary, and `timeoutSeconds` well above a Java plus PostgreSQL start (sibling `apps/unifi-network-application` as guide, UNVERIFIED value). No DB-dependency narrowing applies, since the DB is bundled. Not writable correctly yet.

## 9. Rootless and read-only-rootfs adaptations

Upstream (Docker Hub) mounts `/srv/data`, `/srv/scaninput`, `/srv/backup`, `/srv/restore`; the all-in-one image runs as root with PostgreSQL, Tomcat and other services (draft: UID 0, writable rootfs). Our remap: all four to `/config/*`, PostgreSQL data, Tomcat work and logs to `/config` or `/tmp`, services run as `apps`. The vendor package's postinst scripts, systemd units and fixed system paths (`/var/lib/postgresql`, `/etc/ecodms`, `/opt/ecodms`?) will fail unprivileged and on a read-only rootfs. All of these paths are UNVERIFIED because no package listing was inspected.

## 10. Risks, caveats and open questions

- BLOCKER: closed-source commercial software; redistribution of vendor packages in a public GHCR image is unconfirmed, and a license/activation may be needed (draft caveat, inferred).
- BLOCKER: no public Dockerfile; Docker Hub image is 18.09, about 3 years old. Current vendor build is 26.01 (amd64 Ubuntu 24.04 repo). A major version jump cannot be done directly from 16.09/14.08 per Docker Hub notes.
- Multi-service bundle (PostgreSQL, Tomcat, indexing) with root-expecting postinst scripts; hard to make rootless and read-only.
- No renovate datasource; versions change in the repo URL path.
- Ubuntu 26.04 support by the vendor repo is unknown; only noble (24.04) and Debian 12/13 are listed.
- Recommendation: do not port until maintainers decide on redistribution; if so, build FROM the vendor apt repo, not by copying the Docker Hub image.

## 11. Build and test steps

Not applicable now. If it proceeds: `docker buildx bake --print`, `docker buildx bake --set image-local.platform=linux/amd64 image-local`, run `docker run --rm -d --name ecodms-probe --read-only --tmpfs /tmp -v ecodms-probe-config:/config ecodms:<version>`, read logs until the web server on 8080 is up (log wording UNVERIFIED), clean up with `docker rm -f ecodms-probe; docker volume rm ecodms-probe-config`, then `forgetool containers test --image ecodms:<version> --config ./apps/ecodms/container-test.yaml`.

## 12. PR checklist

- No PR until license and layout questions are answered.
- When ready: branch `feat/add-ecodms`, commit `feat(ecodms): add new container`, PR template filled, `🤖 This PR is AI generated.` in Notes.
- CLA: tell the user, https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: everything (no build, run, package layout, ports, or license check).
