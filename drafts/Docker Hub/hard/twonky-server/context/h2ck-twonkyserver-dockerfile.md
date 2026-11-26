# H2CK/twonkyserver Dockerfile

Source URL: https://raw.githubusercontent.com/H2CK/twonkyserver/a4d34f54e62617b359df5bf8dd745e4742d74c2e/Dockerfile (pinned commit, fetched 2026-11-26)
Blob URL: https://github.com/H2CK/twonkyserver/blob/a4d34f54e62617b359df5bf8dd745e4742d74c2e/Dockerfile

## Base
- `FROM ubuntu:20.04`

## ENV
| Var | Value |
| --- | --- |
| DEBIAN_FRONTEND | noninteractive |
| HOME | /root |
| LC_ALL | C.UTF-8 |
| LANG / LANGUAGE | en_US.UTF-8 |
| supervisor_conf | /etc/supervisor/supervisord.conf |
| start_scripts_path | /bin |

## RUN (main install)
- `apt-get upgrade`; installs apt-utils, cron, supervisor, ssl-cert, wget, unzip, xz-utils, sudo.
- mkdir `/etc/service/twonky`, `/config`, `/usr/local/twonky`.
- Downloads FFmpeg 4.3.2 static amd64: `https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-4.3.2-amd64-static.tar.xz` -> `/tmp/ffmpeg.tar.xz`.
- Downloads Twonky Server 8.5.2: `http://download.twonky.com/8.5.2/twonky-x86-64-glibc-2.22-8.5.2.zip` -> `/tmp/twonkyserver.zip`.
- Unzip into `/usr/local/twonky`; delete zip; `chmod -R +x /usr/local/twonky`.
- `/config` chown `root:users`, mode 770.
- FFmpeg extracted to /tmp, `manpages` removed, contents copied into `/usr/local/twonky/cgi-bin/`.
- `usermod -a -G users root`.
- Cleans apt lists, /var/cache/*, /var/tmp/*, /tmp/*.

## COPY
| Src | Dest |
| --- | --- |
| supervisord.conf | ${supervisor_conf} |
| 01_user_config.sh | /bin/ |
| 02_auto_update.sh | /bin/ |
| start.sh | /start.sh |

- chmod +x on 01_user_config.sh, 02_auto_update.sh, /start.sh.

## Entrypoint / ports / volumes
- `CMD ["/start.sh"]`
- `VOLUME /config`, `/data`
- `EXPOSE 1030/udp 1900/udp 9000/tcp`

## Not present
- ARG, USER, HEALTHCHECK, ENTRYPOINT, WORKDIR. Runs as root.
