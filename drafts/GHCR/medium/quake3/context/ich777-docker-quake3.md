# Upstream image: ich777/docker-quake3 (Dockerfile)

Source URL: https://raw.githubusercontent.com/ich777/docker-quake3/master/Dockerfile (fetched 2026-11-27, branch master, not pinned)

## Build
- `FROM ich777/debian-baseimage` (Debian).
- Label: org.opencontainers.image.source=https://github.com/ich777/docker-quake3
- `dpkg --add-architecture i386`; apt install `screen unzip lib32z1` (no-install-recommends); rm apt lists.
- `mkdir $DATA_DIR`; `useradd -d $DATA_DIR -s /bin/bash quake3`; `chown -R quake3 $DATA_DIR`; `ulimit -n 2048`.
- `ADD /scripts/ /opt/scripts/`; `chmod -R 777 /opt/scripts/`.

## Entrypoint / flags
- `ENTRYPOINT ["/opt/scripts/start.sh"]`; no CMD. No USER instruction (runs as root). No EXPOSE. No VOLUME.
- start.sh contents NOT fetched (a guessed raw path returned 404).

## Env vars (image defaults)
| Name | Default |
| --- | --- |
| DATA_DIR | /quake3 |
| GAME_PARAMS | +set sv_punkbuster 0 +set fs_game osp +set com_hunkMegs 32 |
| Q3_PORT | 27960 |
| Q3_MAP | q3dm0 |
| DL_URL_PR | https://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/quake3/linux/linuxq3apoint-1.32b-3.x86.run |
| DL_URL_PATCH | https://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/quake3/quake3-1.32c.zip |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| DATA_PERM | 770 |
| USER | quake3 |

## Ports
- 27960 (Q3_PORT). Protocol not declared in Dockerfile.

## Volumes/paths
- /quake3 (DATA_DIR), owned by quake3.

## Gotchas
- Game data is downloaded at runtime by upstream scripts from the ftp.gwdg.de URLs above. Not inspected.
- Image is Debian with i386 multiarch (32-bit libs).
