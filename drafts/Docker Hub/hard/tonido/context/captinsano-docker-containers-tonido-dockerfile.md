# captinsano/docker-containers Tonido Dockerfile

Source URL: https://raw.githubusercontent.com/captinsano/docker-containers/bc771a38db8113da381410a5c3c3714172183bf5/Tonido/Dockerfile (pinned commit, fetched 2026-11-26)
Blob URL: https://github.com/captinsano/docker-containers/blob/bc771a38db8113da381410a5c3c3714172183bf5/Tonido/Dockerfile

## Base
- `FROM phusion/baseimage:0.9.16` (old phusion base, my_init as CMD)
- MAINTAINER Capt.Insano (unRAID-targeted)

## ENV
| Var | Value |
| --- | --- |
| HOME | /root |
| DEBIAN_FRONTEND | noninteractive |
| LC_ALL | C.UTF-8 |
| LANG / LANGUAGE | en_US.UTF-8 |
| LD_LIBRARY_PATH | /usr/local/tonido |

## RUN (summary)
1. User: `nobody` set to UID 99, GID 100, home `/config`; `/home` chowned nobody:users (unRAID match).
2. SSH disabled: removes `/etc/service/sshd` and `/etc/my_init.d/00_regen_ssh_host_keys.sh`.
3. `mkdir /usr/local/tonido`.
4. apt: wget, tmux, libjpeg8, libfontconfig1, curl; clean lists.
5. In `/usr/local/tonido`: `wget` `http://www.tonido.com/download.php?tonido64.tar.gz` (Firefox UA string) -> `tonido64.tar.gz`; extract; delete archive.
6. mkdir `/unRAID` and `/config`.
7. chmod +x `/etc/my_init.d/firstrun.sh` and `/etc/service/tonido/run`.

## ADD / files
- `firstrun.sh` -> `/etc/my_init.d/firstrun.sh`
- `tonido.sh` -> `/etc/service/tonido/run`

## Ports / volumes / cmd
- EXPOSE 10001
- VOLUME `/unRAID`, `/config`
- CMD `["/sbin/my_init"]`

## Not present
- ARG, USER, HEALTHCHECK, ENTRYPOINT, WORKDIR, COPY.

## Gotchas
- Binary source is tonido.com, which is shut down (see tonido-com-shutdown-notice.md). The download URL is plain HTTP and may not resolve.
- Base phusion/baseimage:0.9.16 is very old.
