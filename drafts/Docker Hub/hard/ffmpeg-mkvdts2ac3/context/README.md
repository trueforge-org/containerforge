# Context for ffmpeg-mkvdts2ac3

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://ffmpeg.org | ffmpeg-org.md |
| https://ffmpeg.org/ | ffmpeg-org.md |
| https://ffmpeg.org/documentation.html | ffmpeg-org.md |
| https://github.com/JakeWharton/mkvdts2ac3 | github-jakewharton-mkvdts2ac3.md |
| https://github.com/JakeWharton/mkvdts2ac3/archive/refs/tags/1.6.0.tar.gz | not fetched (binary archive); asset pattern in github-jakewharton-mkvdts2ac3.md |
| https://hub.docker.com/r/snoopy86/ffmpeg | dockerhub-snoopy86-ffmpeg.md |
| https://registry.hub.docker.com/r/snoopy86/ffmpeg | dockerhub-snoopy86-ffmpeg.md (301 redirect to hub.docker.com) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ffmpeg-mkvdts2ac3 | truecharts-ffmpeg-mkvdts2ac3.md |
| (named, no URL in draft) mkvtoolnix | mkvtoolnix-download.md (from https://mkvtoolnix.download) |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| ghcr.io/trueforge-org/ubuntu, ghcr.io/trueforge-org/ubuntu:26.04@sha256:... | ghcr image refs, not web pages |

## Fetch failures

- None.

## plan.md corrections

- Section 1 "Verified upstream facts", Flags line: `-d` described as "drop DTS" -> "make the AC3 track default" (script help: `-d, --default`). Source: github-jakewharton-mkvdts2ac3.md.
- Section 1 Flags line: `-n` described as "no AC3 if present?" -> "drop the DTS track" (script help: `-n, --no-dts`). Source: github-jakewharton-mkvdts2ac3.md.
- Section 1 Flags line: `--new` meaning marked UNVERIFIED -> confirmed: writes `NAME-AC3.mkv` next to the original (script help). Source: github-jakewharton-mkvdts2ac3.md.
- Unverified (not changed): mkvtoolnix GPL-2.0 license (page does not state it); FFmpeg GPL/LGPL status (legal.html not fetched); ffmpeg `ac3` encoder and `dca` decoder presence in the Ubuntu build.
