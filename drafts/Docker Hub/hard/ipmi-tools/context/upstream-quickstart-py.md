# IPMI-Fan-Controller quickstart.py (pinned commit)

Source URL(s): https://raw.githubusercontent.com/EdwardChamberlain/IPMI-Fan-Controller/d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246/quickstart.py; repo tree: https://github.com/EdwardChamberlain/IPMI-Fan-Controller/tree/d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246. Fetched 2026-11-26.

## Repo root
- `app/` (folder), `dockerfile`, `quickstart.py`, `README.md`, `.gitignore`
- Contents of `app/` NOT visible in fetch (gap).

## quickstart.py (host-side helper, not part of image)
- Imports only `os`; no env vars read; no ipmitool strings; no config paths.
- `os.system('sudo docker build -t quickstart_image .')`
- `os.system('docker run -d --name App_Quickstart -p 6060:80 quickstart_image')`
- Implies container listens on port 80, host 6060.
- No return-code checks; no existing-container cleanup.
