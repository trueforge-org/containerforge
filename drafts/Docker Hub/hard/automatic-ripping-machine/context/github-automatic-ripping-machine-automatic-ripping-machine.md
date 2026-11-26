# automatic-ripping-machine/automatic-ripping-machine (upstream source, Dockerfile, releases, wiki)

**Source URL(s) + fetch date:** https://github.com/automatic-ripping-machine/automatic-ripping-machine (raw Dockerfile @ a380622a715072a524b7ae17a9736d8b925bb4b4; raw `main/README.md`; https://github.com/automatic-ripping-machine/automatic-ripping-machine/releases/latest; https://github.com/automatic-ripping-machine/automatic-ripping-machine/wiki and its linked pages listed below) · fetched 2026-11-26. Source tarball `https://github.com/automatic-ripping-machine/automatic-ripping-machine/archive/refs/tags/${VERSION}.tar.gz` is recorded, not downloaded (see README.md).

## What it is
Automatic Ripping Machine (ARM): headless tool that detects an inserted optical disc (Blu-ray, DVD, CD), identifies audio, video or data, and rips it. Uses udev for disc detection; MakeMKV or HandBrake for video; abcde for audio CDs (MusicBrainz metadata); ISO backup for data discs. Includes a Python Flask web UI. Titles come from the disc or OMDb. Notifications via IFTTT, Pushbullet, Slack, Discord and others.

## Install/build steps and build deps
Dockerfile is two-stage on `automaticrippingmachine/arm-dependencies:1.8.0` (native toolchain lives in that base, not in this file):
- Stage `base`: `EXPOSE 8080`; OCI labels (`source`, `license=MIT`, description); creates `/home/arm`, `/home/arm/config`, `/mnt/dev/sr0` through `/mnt/dev/sr20`, mode 0777; appends fstab lines `/dev/srN  /mnt/dev/srN  udf,iso9660  defaults,users,utf8,ro  0  0` for N=0..20; removes `/etc/service/sshd` and `/etc/my_init.d/00_regen_ssh_host_keys.sh`; installs runit service `/etc/service/armui/run` from `scripts/docker/runsv/armui.sh`; `/etc/my_init.d/arm_user_files_setup.sh` and `start_udev.sh` from `scripts/docker/runit/`; `scripts/docker/custom_udev` copied to `/etc/init.d/udev`.
- Stage `automatic-ripping-machine` (final): `COPY . /opt/arm/`; `ln -sv /opt/arm/setup/51-docker-arm.rules /lib/udev/rules.d/`; `git config --global --add safe.directory /opt/arm`; `CMD ["/sbin/my_init"]`; `WORKDIR /home/arm`.
- No apt in this file; packages come from the base image. No ARG, ENV, USER, VOLUME, ENTRYPOINT.

## Runtime deps
Provided by `arm-dependencies:1.8.0` (not fetched). Python app (plan.md cites requirements.txt, not fetched in this run).

## Binaries/entrypoint/CLI flags
`/sbin/my_init` (runit init, from base). Web UI service `armui` via `/etc/service/armui/run`. Udev started by `/etc/my_init.d/start_udev.sh`.

## Env vars
Not set in the Dockerfile. Chart sets `ARM_UID` (from `securityContext.container.PUID`) and `ARM_GID` (from `securityContext.pod.fsGroup`). Wiki env list (ARM_UID, ARM_GID, TZ per plan.md) was not in the fetched wiki index.

## Ports
`EXPOSE 8080` (web UI).

## Volumes/paths and persistent data
- `/home/arm` (state; media under `media/{raw,transcode,completed}`, music, logs per plan.md).
- `/home/arm/config`, `/etc/arm/config` (arm.yaml, apprise.yaml, abcde.conf; chart mounts `/etc/arm/config`).
- `/mnt/dev/srN` for N=0..20 mount points; device `/dev/srN` must be passed to the container.

## User/UID & permissions
Dockerfile sets no USER (runs as root via my_init). Chart: runAsUser 0, runAsGroup 0, `allowPrivilegeEscalation: true`, init container chowns `/home/arm` and `/etc/arm/config` to PUID:fsGroup.

## Config files and formats
`arm.yaml`, `apprise.yaml`, `abcde.conf` (wiki pages: Config-arm.yaml, Config-apprise.yaml, Config-abcde.conf).

## Healthcheck/readiness endpoints
None in Dockerfile.

## Version/release info and asset naming
- Latest GitHub release: `2.25.0` (marked Latest), 25 Nov, commit `d9b80ce`, by github-actions. Four assets listed; names did not load.
- Tarball: `archive/refs/tags/<version>.tar.gz` (bare tag, no `v` prefix per chart/plan).
- Draft's Docker Hub copy-from tag `2.24.4` is older than the current release.

## Arch support
Not stated in Dockerfile or README. Hub architectures not listed.

## Licence
MIT (Dockerfile OCI label `org.opencontainers.image.license=MIT`; README "MIT License"). MakeMKV and HandBrake carry their own licences (see wiki MakeMKV-EULA and plan.md).

## Wiki index (linked from the wiki page; not summarised further)
Getting-Started; docker (prebuilt image); Building-ARM-docker-image-from-source; Podman-prebuilt-image; Setting-up-ARM-script-(Debian-OMV); Ubuntu-20.04-Automatic-Installation; upgrading; Web-Jobs; Web-Settings; Web-Settings-Drives; Web-Settings-UI; Web-Settings-System-Info; Configuring-ARM; Config-arm.yaml; Config-apprise.yaml; Config-abcde.conf; Config-ui-skins; MakeMKV-Info; ffmpeg.md; Alternate-Install-Ubuntu, Alternate-Install-Debian, Alternate-Install-OMV, Alternate-Install-TrueNAS, Alternate-Install-macOS-UTM; Hardware-Transcode-Intel-QSV, Hardware-Transcode-AMD-VCE, Hardware-Transcode-Nvidia-NVENC; FAQ; General-Troubleshooting; Docker-Troubleshooting; Status-Known-Issues; Status-Roadmap; Contribute; Contribute-Docker; workflow-diagram; related-howtos; Change-Log.
Sidebar only: Docker-From-Source, Docker-Upgrading, MakeMKV-Codes, MakeMKV-EULA.

## Gotchas
- Wiki's `docker` page (run command, env, volumes, device flags, privileged need, default login) was NOT fetched; the wiki index did not include its content. Do not assume the privileged setting from the chart (it is not set in chart values).
- Native install: Ubuntu 20.04 is the only officially supported OS (per wiki main page, which is an older statement).

## Contradictions with plan.md
- plan.md section 1 Version `2.24.4` (published 3 Oct): stale. Latest GitHub release is `2.25.0` (25 Nov) and the TrueCharts chart pins `2.25.0`. plan.md corrected.
- plan.md section 1 Dockerfile facts (base `arm-dependencies:1.8.0`, EXPOSE 8080, /home/arm, /home/arm/config, sr0..sr20 fstab, udev, armui + udev services): confirmed.
- plan.md section 1 licence MIT: confirmed.
- plan.md section 1 chart tag: chart pins `2.25.0`, not `2.24.4` as stated.
