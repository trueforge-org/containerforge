# collaboraonline.com/code/docker/ (Docker page for CODE, reached via redirects)

Source URL(s) + fetch date:
- https://www.collaboraoffice.com/code/docker/ (301) -> https://www.collaboraonline.com//code/docker/ (301) -> https://www.collaboraonline.com/code/docker/ · fetched 2026-11-26 (final page)

## Facts
- Image `collabora/code` on Docker Hub; runs on x86-64, ppc64, arm64. "Fully configurable".
- Configuration is delegated to the SDK guide: https://sdk.collaboraonline.com/docs/installation/CODE_Docker_image.html (not fetched; the SDK docs are behind a bot challenge per plan.md).
- Integration examples use compose files (`docker compose up -d`); contents not shown.
- Ports in examples: 9980 for Collabora; Nextcloud on 8080; OpenCloud 9200; Seafile checks `https://seafile.local:6232`.
- Seafile `.env` keys `LOCAL_IP`, `BASIC_STORAGE_PATH`.
- No docker run command, no env var names (other than Seafile/OpenCloud example files), no capability, seccomp, rootless, read-only or user notes.
