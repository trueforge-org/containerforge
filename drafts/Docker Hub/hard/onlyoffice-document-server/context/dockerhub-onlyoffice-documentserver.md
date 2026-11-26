# Docker Hub: onlyoffice/documentserver

Source URL(s): https://hub.docker.com/r/onlyoffice/documentserver · fetched 2026-11-26

- Publisher Ascensio System SIA (verified). License: GNU AGPL v3.0.
- Tags: `latest` shown; digest sha256:ca17889f…; ~899.7 MB; last updated ~2 months ago.
- Architectures: not listed. Pulls 100M+ total; 275,280 last week.
- Requirements: RAM 4 GB+, dual-core 2 GHz, swap 2 GB+, 2 GB+ disk.
- Run: `docker run -i -t -d -p 80:80 onlyoffice/documentserver`; volumes `/var/log/onlyoffice`, `/var/www/onlyoffice/Data`.
- HTTPS: `-p 443:443`; certs `onlyoffice.key`/`onlyoffice.crt` (page) vs `tls.key`/`tls.crt` (Docker-DocumentServer README, default SSL_*_PATH) — naming conflict noted.
- Known issues: SELinux on RPM distros; mono on older kernels.
