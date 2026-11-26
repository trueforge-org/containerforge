# m-bers/docker-virt-manager Dockerfile

Source URL: https://raw.githubusercontent.com/m-bers/docker-virt-manager/master/Dockerfile (fetched 2026-11-26)
Blob URL: https://github.com/m-bers/docker-virt-manager/blob/master/Dockerfile

## Base
- `FROM mber5/broadway-baseimage:latest` (unpinned)

## ENV
| Var | Value |
| --- | --- |
| FAVICON_URL | raw.githubusercontent.com virt-manager 256x256 `virt-manager.png` (commit 931936a3…) |
| APP_TITLE | Virtual Machine Manager |
| CORNER_IMAGE_URL | same icon URL as FAVICON_URL |
| HOSTS | `[]` |

## RUN
- `apt-get update`; install (no recommends): virt-manager, dbus-x11, libglib2.0-bin, gir1.2-spiceclientgtk-3.0, ssh, at-spi2-core.
- Clean apt (`clean`, `autoclean`), rm `/var/lib/apt/lists/*`.
- mkdir `/root/.ssh`; appends `Host *` with `StrictHostKeyChecking no` to `/root/.ssh/config`.

## COPY / CMD
- `startapp.sh` -> `/usr/local/bin/startapp`
- `CMD ["/usr/local/bin/startapp"]`

## Not present
- ARG, EXPOSE, VOLUME, USER, HEALTHCHECK, ENTRYPOINT, WORKDIR.
- Runs as root (ssh config under /root).
