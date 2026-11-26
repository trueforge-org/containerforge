# Docker Hub crazyq/pt_helper

Source: https://hub.docker.com/r/crazyq/pt_helper (API https://hub.docker.com/v2/repositories/crazyq/pt_helper), fetched 2026-11-26. Description is in Chinese; facts translated.

| Field | Value |
| --- | --- |
| description | PT小助手 (PT helper: automatic brushing and check-in) |
| star_count / pull_count | 134 / 264805 |
| last_updated | 2023-09-07T10:51:35Z |

## Run (from full description)
- `docker run --restart=always -d --name pt_helper -p <port>:8192 -v <data dir>:/data crazyq/pt_helper:latest`
- Web UI: http://<host>:<port>, default login username/password `admin` / `admin`.
- Arch: AMD64, ARM, ARM64 (description mentions all three).

## Function
- Auto-brush free torrents from supported PT sites, auto-delete after free period, check-in for supported sites; HR mode; per-site upload speed limits (listed per site).
- Supports ~22 PT sites (CHD, OB, MSG, TCCF, NICEPT, HDHOME, PTHOME, SSD, FRDS, LEMONHD, PTER, HDSKY, U2, TLF, TTG, HARES, AUDIENCES, OPENCD, HDCHINA, HHAN).
- OPENCD check-in needs Baidu OCR config; U2 needs downloader able to reach U2.

## Changelog notes
- Image tags: `latest` and `arm64_latest` were merged into `latest` (changelog).
- ARM64 Docker version added (changelog).
- UserAgent setting added (changelog).

## Gotchas
- Data must persist in /data.
