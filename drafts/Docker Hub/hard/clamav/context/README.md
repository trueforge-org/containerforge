# clamav: source context (fetched 2026-11-26)

## Sources fetched

| Source URL | Summary file |
| --- | --- |
| https://github.com/Cisco-Talos/clamav (repo; release clamav-1.5.5 page; COPYING.txt) | github-cisco-talos-clamav.md |
| https://github.com/Cisco-Talos/clamav/releases/tag/clamav-1.5.5 | github-cisco-talos-clamav.md |
| https://github.com/Cisco-Talos/clamav-docker/blob/0d44a2479470a57af03f1e212e764f1bee57fc8a/clamav/1.5/debian/Dockerfile | github-cisco-talos-clamav-docker.md |
| https://hub.docker.com/r/clamav/clamav | dockerhub-clamav-clamav.md |
| https://www.clamav.net/downloads | clamav-net-downloads.md |
| https://docs.clamav.net/ | docs-clamav-net.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/clamav (values.yaml) | truecharts-clamav.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (never fetched) |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base app link |
| https://github.com/Cisco-Talos/clamav/releases/download/clamav-${VERSION}/clamav-${VERSION}.linux.x86_64.deb | direct binary (.deb) download; pattern recorded in github-cisco-talos-clamav.md |
| https://github.com/Cisco-Talos/clamav/releases/download/clamav-${VERSION}/clamav-${VERSION}.linux.aarch64.deb | direct binary (.deb) download; pattern recorded |
| https://github.com/Cisco-Talos/clamav/releases/download/clamav-1.5.5/clamav-1.5.5.linux.x86_64.deb | direct binary (.deb) download (pinned draft version); pattern recorded |
| https://github.com/Cisco-Talos/clamav/releases/download/clamav-1.5.5/clamav-1.5.5.linux.aarch64.deb | direct binary (.deb) download; pattern recorded |
| https://www.clamav.net/downloads (the .deb links on it) | direct binary downloads; listed in clamav-net-downloads.md |

## Fetch failures

- GitHub release clamav-1.5.5: asset list did not load (error on page). Asset names and digests NOT confirmed from GitHub; the names match the clamav.net listing.
- No other failures.

## plan.md corrections

- Section 1 Checksum: "UNVERIFIED: the release asset list did not load ... Take the sha256 from the GitHub asset digest or https://www.clamav.net/downloads and pin it per arch" -> clamav.net publishes **no SHA256**; it publishes detached `.sig` signatures per .deb and a PGP key at `https://www.clamav.net/downloads/gpg_public_key`. Verify the `.sig` and then compute and pin sha256 yourself. Source: clamav-net-downloads.md.
- Section 10 memory bullet: "clamd memory use is high (about 1 to 2 GiB); advise limits" -> docs say baseline **3 GiB+ RAM** and 5 GiB free disk, Docker about 3-4 GiB RAM. Source: docs-clamav-net.md.
- Section 1 Upstream Dockerfile: already matched (confirmed). No change.
- Section 1 License (GPL-2.0-only): COPYING.txt confirms GPLv2 with OpenSSL exception but does not settle only vs or-later. Not edited; see unverified list.

## Unverified (plan.md left as-is)

- GPL version suffix: `GPL-2.0-only` (plan) vs `GPL-2.0-or-later` (the clamav-docker Dockerfile SPDX header, which concerns the docker repo). COPYING.txt does not decide it. Keep unverified until the ClamAV source headers are checked.
- GitHub asset digests and exact names (release list failed to load).
- Docker Hub page says the official image is **Alpine-based** while the reviewed Dockerfile is Debian. The plan builds from the vendor .deb, so this does not change the plan, but it affects the `copy-from` reference.

## Notes (not edited)

- Upstream image health check: `clamdcheck.sh` (HEALTHCHECK 6-minute start period). Could be borrowed for a probe if useful.
- Upstream `/init-unprivileged` exists; the plan's own non-root start.sh is separate.
