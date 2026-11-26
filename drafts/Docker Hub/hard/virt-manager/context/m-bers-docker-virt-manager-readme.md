# m-bers/docker-virt-manager README (summary)

Source URL: https://raw.githubusercontent.com/m-bers/docker-virt-manager/master/README.md (fetched 2026-11-26)

## What it is
- Containerized virt-manager (libvirt GUI) via GTK3 Broadway HTML5 backend; used in browser. No VNC/xrdp.
- Password and SSH passphrase entry via ttyd (terminal icon bottom-left). Dark mode option.
- Requires git, docker, docker-compose, and a libvirt/KVM host.

## Compose (local libvirt on same host)
- image `mber5/virt-manager:latest`, `restart: always`, ports `8185:80`
- env: `DARK_MODE: false`, `HOSTS: "['qemu:///system']"` (`qemu:///session` for user session)
- volumes: `/var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock`, `/var/lib/libvirt/images:/var/lib/libvirt/images`
- devices: `/dev/kvm:/dev/kvm`
- privilege: on Ubuntu or hosts with libvirt AppArmor, use SSH to localhost, or `qemu:///system` with `privileged: true` (commented).

## Compose (remote libvirt)
- Same image/ports/restart. `HOSTS` = comma-separated `qemu+ssh://user@host/system` strings; default `"[]"`.
- Optional key mount: `/home/user/.ssh/id_rsa:/root/.ssh/id_rsa:ro` if not using password auth. No devices needed.

## Env
| Var | Purpose |
| --- | --- |
| DARK_MODE | true/false |
| HOSTS | libvirt connection URIs |

## Build
- `git clone https://github.com/m-bers/docker-virt-manager.git && cd docker-virt-manager && docker build -t docker-virt-manager . && docker-compose up -d`
- UI at http://localhost:8185.

## Not stated
- UID/user setting (SSH mount path under /root suggests root).
