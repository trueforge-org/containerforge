# Wizarr docs: installation

Source URL(s): https://docs.wizarr.dev/getting-started/installation.md (fetched 2026-11-27; first part only)

- Compose example: image ghcr.io/wizarrrr/wizarr, port 5690:5690, volume `/path/to/appdata:/data`, env PUID=1000, PGID=1000, DISABLE_BUILTIN_AUTH=false (set true only with external auth), TZ=<tz database name>.
- Persistence requires mounting the host dir at /data (docs), TZ must be a tz database name.
- Update: pull image and recreate with same parameters.
- Unraid section present (not read).
