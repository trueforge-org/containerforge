# context README: etesync

| Source URL | File |
| --- | --- |
| https://github.com/etesync/server | upstream-github.md |
| https://github.com/etesync/server/releases | upstream-github.md (releases API: 404, tags only) |
| https://api.github.com/repos/etesync/server/releases/latest | upstream-github.md (404) |
| https://raw.githubusercontent.com/etesync/server/master/README.md | upstream-github.md |
| https://github.com/victor-rds/docker-etebase | upstream-github.md (repo, Dockerfile covers) |
| https://github.com/victor-rds/docker-etebase/blob/c06eb631/tags/base/Dockerfile | upstream-github.md |
| https://raw.githubusercontent.com/victor-rds/docker-etebase/c06eb631/tags/base/Dockerfile | upstream-github.md |
| https://hub.docker.com/r/victorrds/etesync | upstream-github.md (tags API used, HTML not fetched) |
| https://hub.docker.com/v2/repositories/victorrds/etesync/tags/latest | upstream-github.md |
| https://github.com/etesync (org page) | not fetched (org index, no install facts) |
| https://www.etesync.com | not fetched (marketing site) |

Skipped: TrueCharts tree page (chart reference, not build source).
Failures: GitHub releases API 404 (expected, tags only; no alternative tried).
Not fetched within budget: victor-rds `context/entrypoint.sh` (referenced by ENTRYPOINT).

## plan.md corrections
None edited. Checked against fetched sources:
- victor-rds Dockerfile matches plan section 1 (python:3.12.4, clone of tag, pip install requirements + psycopg2-binary + python-ldap, collectstatic, uid 373, DATA_DIR /data, PORT 3735).
- No GitHub releases: consistent with plan (tags only).
- Plan's version v0.14.2 and tag-based download were not verified here (no tag fetch).
