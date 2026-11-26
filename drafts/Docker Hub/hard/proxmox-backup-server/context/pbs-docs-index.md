# Proxmox Backup Server docs (index page)

Source: https://pbs.proxmox.com/docs , fetched 2026-11-26

- Documentation version: 4.2.14 (dated 2026-11-18), GNU FDL 1.3.
- Page is a table of contents; sections: Introduction, Installation, Terminology, GUI, Backup Storage, User Management, Backup Client, PVE Integration, pxar, Tape, Remotes & Sync, Maintenance, Host admin, Network, Notifications, Technical Overview, FAQ, Appendix.
- Install sections: Server install (ISO installer, unattended, on Debian, on PVE); Client install (Debian, static client); Repos (enterprise, no-subscription, test, debug symbol, client-only).

## Facts (from index)
- Web UI on HTTPS port 8007 (`https://<ip>:8007`).
- Supported browsers: Firefox (current year or ESR), current Edge.

## Follow-up pages merged (installation.html, sysadmin.html; grep excerpts, fetched 2026-11-26)
### Ports / paths
- Web UI: HTTPS on port 8007.
- Config dir: `/etc/proxmox-backup/`; cert/key: `/etc/proxmox-backup/proxy.pem`, `/etc/proxmox-backup/proxy.key`.
- Node config: `/etc/proxmox-backup/node.cfg`; ACME plugins: `/etc/proxmox-backup/acme/plugins.cfg`.
- Services/CLIs: `proxmox-backup-proxy`, `proxmox-backup-manager`.
- ACME http-01 needs port 80 reachable (not relevant to container default).

### Notes
- Sysadmin: ZFS-on-hardware-RAID not supported; Secure Boot / GRUB only bootloader (host-level, not container).
- Proxy HTTP proxy config format: `[http://]<host>[:port]`.
- Root superuser is `root@pam` (installation page).
