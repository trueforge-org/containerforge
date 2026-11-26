# channels-dvr: source context (fetched 2026-11-26)

## Sources fetched

| Source URL | Summary file |
| --- | --- |
| https://getchannels.com/dvr/setup.sh | getchannels-setup-sh.md |
| https://getchannels.com/dvr-server/ | getchannels-dvr-server.md |
| https://getchannels.com/dvr/ (redirect placeholder, no facts) | getchannels-dvr-server.md |
| https://getchannels.com/ | getchannels-home-and-docs.md |
| https://getchannels.com/docs/ | getchannels-home-and-docs.md |
| https://getchannels.com/docs/channels-dvr-server/quick-guide/installation-setup/ | getchannels-installation-setup.md |
| https://hub.docker.com/r/fancybits/channels-dvr | dockerhub-fancybits-channels-dvr.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/channels-dvr (values.yaml) | truecharts-channels-dvr.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (never fetched) |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base app link |

## Fetch failures

- https://getchannels.com/dvr/ returned only "Redirecting…" (no content). Per-arch download links therefore come from setup.sh instead.
- https://getchannels.com/docs/channels-dvr-server/quick-guide/installation-setup/ fetched (getchannels-installation-setup.md): no Docker, data-dir or hardware-group facts.
- https://getchannels.com/hardware/ not followed (not install/config relevant to the container).

## plan.md corrections

- Section 1 Version: "UNVERIFIED: ... A version must be read from the downloaded server at build time" -> setup.sh reads the current version from `https://cdn.channelsdvr.net/dvr/latest.txt` (override `DVR_VERSION`). Source: getchannels-setup-sh.md.
- Section 1 Download: "Direct per-arch URLs UNVERIFIED (the script resolves them)" -> host `https://cdn.channelsdvr.net/dvr`; files per version `channels-dvr-$os-$arch`, `ffmpeg-$os-$arch`, `ffprobe-$os-$arch`, `comskip-$os-$arch`, `ffmpeg-dl-$os-$arch`, `$os-$arch.sha256`. Source: getchannels-setup-sh.md.
- Section 1 Checksum: "UNVERIFIED: none known" -> a per-version `$os-$arch.sha256` file exists on the CDN, but setup.sh downloads it and does NOT verify it. Source: getchannels-setup-sh.md.
- Section 3: "The server bundles ffmpeg/comskip itself (UNVERIFIED)" -> confirmed: setup.sh downloads `ffmpeg`, `ffprobe`, `comskip` and `ffmpeg-dl` per version. Source: getchannels-setup-sh.md.
- Section 4 step 2: "(UNVERIFIED that it honours the target dir; if it always writes `./channels-dvr`, move it to `/app`)" -> it always writes `./channels-dvr` under the current directory (no target-dir variable); run it from `/app`, or move the result. Source: getchannels-setup-sh.md.
- Section 7 step 3: `cd /app/channels-dvr` and `exec ./channels-dvr` -> the executable is at `channels-dvr/<version>/channels-dvr`, reached via `channels-dvr/latest/`; use `cd /app/channels-dvr/latest` and `exec ./channels-dvr`. Source: getchannels-setup-sh.md.
- Section 8 `filePaths`: `/app/channels-dvr/channels-dvr` -> `/app/channels-dvr/latest/channels-dvr`. Source: getchannels-setup-sh.md.

## Verified, plan.md left as-is (or still UNVERIFIED)

- Port 8089 and web UI: confirmed (docs, Docker Hub, chart). Chart probes use port 8089 (path not stated).
- `--net=host` required for Bonjour; `/dev/dri` for hardware transcoding; `video` and `render` groups for `/dev/dri` (docs). GIDs 44 and 107 mapping still UNVERIFIED.
- Data dir: the Docker image maps config to `/channels-dvr`; the plan's use of `/config` and a `--data-dir`-style flag (section 7/9) is not confirmed by any fetched page.
- Tve variant: `:tve` is TV Everywhere; needs chromium plus xvfb on native installs (docs). Plan section 2 still says contents UNVERIFIED.
- Subscription or trial licence: not stated on any page fetched. Plan's "needs a subscription/trial" left unverified.

## Notes

- The official installer is not a versioned download; no per-version pin exists except through the version in `latest.txt` (renovate plan remains a custom manager question).
- Section 10 bullet 'Version identification and per-arch URLs UNVERIFIED' -> per-arch URLs and version source known; sha256 not verified by setup.sh. Source: getchannels-setup-sh.md.
