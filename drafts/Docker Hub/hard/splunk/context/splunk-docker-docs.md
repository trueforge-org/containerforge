# splunk.github.io/docker-splunk docs (SETUP, STORAGE_OPTIONS, ADVANCED)

Source URL(s): https://splunk.github.io/docker-splunk (landing), https://splunk.github.io/docker-splunk/SETUP.html, .../STORAGE_OPTIONS.html, .../ADVANCED.html (WebFetch 2026-11-26)

## Env vars
| Name | Default | Notes |
| --- | --- | --- |
| SPLUNK_PASSWORD | none (required in examples) | admin password; must meet Splunk password rules |
| SPLUNK_START_ARGS | none (required) | `--accept-license`, must be set on every container or Splunk won't start |
| SPLUNK_GENERAL_TERMS | not on these pages | (appears in Docker Hub quickstart for 10.x; see README) |
| SPLUNK_DEFAULTS_URL | - | fetch default.yml from URL; alt: mount /tmp/defaults/default.yml |
| SPLUNK_APPS_URL | - | install apps from URL (.tgz) |
| SPLUNK_LICENSE_URI | - | apply license from URL |
| SPLUNK_ROLE | not on this page | default `splunk_standalone` in Dockerfile full stage |
| SPLUNK_UPGRADE | - | `true` on upgrade with same volumes |

## Ansible / default.yml defaults (ADVANCED)
- retry_num 100; splunk.opt /opt; home /opt/splunk; user/group splunk; exec /opt/splunk/bin/splunk
- pid /opt/splunk/var/run/splunk/splunkd.pid
- ports: svc 8089, s2s 9997, http 8000, hec 8088
- HEC: enable True, ssl True, token no default
- password: no default, required
- shc: enable false, replication_factor 3, replication_port 9887, secret required for SHC
- idxc: search_factor 2, replication_factor 3, replication_port 9887, secret required for indexer clustering
- smartstore null (enabled only if all params given)
- Full env var list lives in splunk-ansible docs (not fetched)

## Ports
- 8000 SplunkWeb (quickstart maps 8000:8000). Others per Dockerfile exposure.

## Volumes / paths (STORAGE_OPTIONS)
- `/opt/splunk/var` indexes and search artifacts (mount to keep data)
- `/opt/splunk/etc` configuration (mount to keep config; drift risk)
- `/splunkdata`: not mentioned on docs (but present in TrueCharts)
- Persistence in-container folders "not supported"; mount outside volumes only. Both var and etc must be mounted for upgrades.
- Named volumes recommended; never mount same folder into two instances.

## Run example
```
docker run -p 8000:8000 -e "SPLUNK_PASSWORD=<password>" -e "SPLUNK_START_ARGS=--accept-license" -it splunk/splunk:latest
```
- Login admin:<SPLUNK_PASSWORD> at http://localhost:8000

## Not covered
- Healthcheck, container OS user details beyond splunk/UID in Dockerfile, non-root support.
- SPLUNK_GENERAL_TERMS (not on these pages).
