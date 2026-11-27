# backube/volsync Dockerfile (pinned commit 22b97b07)

Source URL(s): https://raw.githubusercontent.com/backube/volsync/22b97b0717c74f328853d92877151392ff5ecb42/Dockerfile (blob variant maps here; fetched 2026-11-27)

## Stages
- golang-builder: FROM golang:1.25 ; CGO_ENABLED=1 ; GOFLAGS=-mod=readonly.
- manager-builder: go build -o manager ./cmd/... (ldflags version_arg). Output /manager.
- rclone-builder: git clone rclone tag ARG RCLONE_VERSION=v1.74.2, hash check (RCLONE_GIT_HASH=b22fe981...), make rclone.
- restic-builder: local /mover-restic/restic + minio-go; go run build.go --enable-cgo.
- syncthing-builder: tag ARG SYNCTHING_VERSION=v1.30.0, hash check (0945304a...), go run build.go -no-upgrade.
- diskrsync-builder: tag DISKRSYNC_VERSION=v1.3.0, hash check (507805c4...), output diskrsync.
- diskrsync-tcp-builder: local diskrsync-tcp/main.go.

## Runtime
- FROM registry.access.redhat.com/ubi9-minimal
- microdnf installs: findutils, acl, openssh, openssh-clients, openssh-server, python3, stunnel, openssl, vim-minimal, tar, rsync (install_weak_deps=0); microdnf clean all.
- Copies: /manager, /usr/local/bin/rclone, restic, syncthing, diskrsync, /diskrsync-tcp ; mover scripts under /mover-rclone, /mover-restic, /mover-rsync, /mover-rsync-tls, /mover-syncthing.
- sshd hardened via sed (PasswordAuthentication no, UsePAM no, etc.). PidFile /tmp/sshd.pid.
- ENV SYNCTHING_DATA_TRANSFERMODE=sendreceive ; ARG version_arg, builddate_arg, labels (OCI), license AGPL-3.0-or-later.
- ENTRYPOINT ["/bin/bash"] (chart overrides command to /manager).
- No USER directive in final stage.

## Gotchas
- Symlinks /etc/ssh/ssh_host_rsa_key -> /keys/destination (mover ssh keys).
- Build-time git hash assertions for rclone, syncthing, diskrsync.
