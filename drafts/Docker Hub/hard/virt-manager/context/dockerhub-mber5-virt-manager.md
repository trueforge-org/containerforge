# Docker Hub mber5/virt-manager

Source URL: https://hub.docker.com/r/mber5/virt-manager (fetched 2026-11-26)

- Tags: only `latest`. Digest sha256:111674d87… (truncated). Size 182.7 MB. 500K+ pulls. Last updated ~4 years ago.
- Architectures: not stated.
- Env: `DARK_MODE` (true/false), `HOSTS` (libvirt URIs, e.g. `"['qemu:///system']"`, `"['qemu:///session']"`, or comma-separated `qemu+ssh://` strings).
- Ports: host 8185 -> container 80. UI at http://localhost:8185.
- Volumes: libvirt-sock, `/var/lib/libvirt/images`; device `/dev/kvm`; optional SSH key mount for remote hosts.
- Pull: `docker pull mber5/virt-manager`.
