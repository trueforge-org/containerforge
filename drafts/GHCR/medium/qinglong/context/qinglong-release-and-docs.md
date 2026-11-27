# Upstream release and deployment docs: whyour/qinglong v2.24.0

Source URL(s):
- https://github.com/whyour/qinglong/releases/tag/v2.24.0 (fetched 2026-11-27; used as fallback for the API)
- https://qinglong.online/guide/getting-started/installation-guide (index, fetched)
- https://qinglong.online/guide/getting-started/installation-guide/docker (fetched)

## Release v2.24.0
- Title `2.24.0 · whyour/qinglong`; `datetime="2026-10-29T15:57:45Z"`.
- Mentions a `2.24.0-debian` variant: no longer updated, Python 3.10 users must evaluate migration.
- Assets: not extracted (API call failed; see README).

## Docker deployment (qinglong.online)
| Item | Value |
| --- | --- |
| Data mount | `-v $PWD/ql/data:/ql/data` |
| Port | `-p 5700:5700` (QlPort must match right side of -p) |
| Env | `QlBaseUrl` (optional path prefix, default `/`), `QlPort` (default `5700`) |
| User | `--user qinglong` in one example (non-root variant) |
| Init | Browse http://localhost:5700 to initialise |

Gotchas:
- Empty host directory mounted on /ql/data shadows the Python deps preinstalled in the image. Install `requests` from the panel's dependency manager after first start.
- Upgrades reuse the existing data dir.
- Docs use an Alpine image in the examples.
