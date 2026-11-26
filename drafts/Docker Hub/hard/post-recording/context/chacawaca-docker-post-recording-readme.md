# chacawaca/docker-post-recording README

Source: https://github.com/chacawaca/docker-post-recording (raw: raw.githubusercontent.com/.../master/README.md), fetched 2026-11-26

## What it is
- Watches a folder for .ts files from Live TV recordings; converts them, extracts .srt, adds chapters (comchap) or removes ads (comcut).
- Tested with Emby recordings.

## Env vars
| Var | Meaning |
| --- | --- |
| DELETE_TS | 0=delete original, 1=keep, 2=move to /backup. Doc says use 1 until verified |
| SUBTITLES | 0=extract .srt, 1=no |
| CONVERSION_FORMAT | output extension (custom.sh must support it) |
| SOURCE_EXT | input extension (default ts) |
| POST_PROCESS | comchap or comcut (default comchap) |
| PUID / PGID | runtime uid/gid |
| UMASK | file creation mask |
| NVIDIA_VISIBLE_DEVICES | GPU UUID (Unraid nvidia) |

## Volumes/paths
| Path | Use |
| --- | --- |
| /config | config, logs, persistent files |
| /watch | input .ts files (other files ignored) |
| /backup | only used when DELETE_TS=2 |

## Config files
- /scripts/custom.sh (must be user-configured)
- /hooks (custom code hooks)
- /comskip/comskip.ini

## Gotchas
- Intel iGPU needs /dev/dri; Nvidia needs runtime=nvidia (Unraid-specific steps).
- Listed upstream projects: djaydev/docker-recordings-transcoder, BrettSheleski/comchap, erikkaashoek/Comskip, jlesage/docker-handbrake, ffmpeg, CCExtractor/ccextractor, linuxserver/docker-baseimage-ubuntu, jrottenberg/ffmpeg.
