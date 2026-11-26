# import-ics: context sources

Fetched 2026-11-26. Summaries for every web source referenced by `draft.md` and `plan.md`.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/Vilhjalmr26/import_ics (+ raw README, dockerfile, import_ics/requirements.txt, import_ics/import_ics.py, entrypoint.sh, releases) | github-vilhjalmr26-import-ics.md |
| https://github.com/Vilhjalmr26/import_ics/blob/ec04d6c/dockerfile | github-vilhjalmr26-import-ics.md (raw dockerfile) |
| https://github.com/Vilhjalmr26/import_ics/blob/HEAD/import_ics/requirements.txt | github-vilhjalmr26-import-ics.md (same file) |
| https://hub.docker.com/r/vilhjalmr26/import_ics | dockerhub-vilhjalmr26-import-ics.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/import-ics | truecharts-import-ics.md (Chart.yaml and values.yaml read via raw) |
| https://pypi.org/project/caldav/ (named dependency `caldav`) | pypi-caldav.md |
| https://pypi.org/project/requests/ (named dependency `requests`) | pypi-requests.md |
| https://github.com/aptible/supercronic (named dependency; releases/latest and README) | github-aptible-supercronic.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page, skipped by rule |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge base link, skipped by rule |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base link, skipped by rule |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema, skipped by rule |
| https://github.com/Vilhjalmr26/import_ics/archive/ec04d6c.zip | direct archive download. Asset pattern recorded in the repo file: `archive/<sha>.tar.gz` or `.zip`, no checksum |
| https://github.com/Vilhjalmr26/import_ics/archive/<sha>.tar.gz and `archive/${VERSION}.tar.gz` | archive download, templated. Same pattern as above |
| https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH} | release binary download (templated). Asset names recorded in github-aptible-supercronic.md |
| https://example.com/dav.php | placeholder from the upstream Dockerfile ENV, not a source |
| https://...ics | placeholder in plan (`calendar_download_map` URL), not a source |

Other names mentioned without a URL and not fetched: CalDAV servers "Radicale" and "Nextcloud" (examples only in plan section 6 and 10), Dockerfile base `python:3.15.2` (plan base image, not a source link).

## Fetch failures

- https://raw.githubusercontent.com/Vilhjalmr26/import_ics/ec04d6c113aa9014f2127639db9801a1fb4f9d3b/LICENSE: HTTP 404. Alternative tried: https://raw.githubusercontent.com/Vilhjalmr26/import_ics/main/LICENSE: HTTP 404. Confirms plan section 10 (no license).

## plan.md corrections

No edits made. The only candidate issues are unverified (see below), so none meet the "clearly a factual mistake" bar.

Unverified:
- plan.md section 4 step 3: the supercronic checksum values (`cc232108...a123` amd64, `4ae22576...2b94` arm64) are described as sha256 digests GitHub shows. The release page summary shows SHA-1 values only (amd64 `1692066e350a88ff4d7d6474fe3c7a6c41ec5e89`, arm64 `9d4c2000493215a1898502b2fc2dada3e8ea8c7a`). Could not confirm which the plan values are.
- plan.md section 10: caldav 3.x API (`DAVClient`, `principal().calendars()`, `save_event(ical=...)`). PyPI shows `get_davclient()` and `principal.get_calendars()` for 3.x; `DAVClient` and `save_event` are not named there. Still open.
- plan.md section 1: "caldav 3.7.0 ... its PyPI metadata lists niquests" and no requests dependency. The PyPI page lists `niquests` only as an optional extra and shows no runtime dependency list.
- plan.md section 10: supercronic seconds syntax. Source confirms 5-field and 6/7-field forms are accepted; the plan's "UNVERIFIED" note can be resolved, but it is not a factual error.
