# context: splunk

| Source URL | File |
| --- | --- |
| https://github.com/splunk/docker-splunk/blob/a2c049c/splunk/common-files/Dockerfile | splunk-common-files-dockerfile.md |
| https://splunk.github.io/docker-splunk (+ SETUP, STORAGE_OPTIONS, ADVANCED) | splunk-docker-docs.md |
| https://hub.docker.com/r/splunk/splunk | dockerhub-splunk.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/splunk | truecharts-splunk.md |
| https://www.splunk.com/en_us/download/splunk-enterprise.html | splunk-download-page.md |
| https://help.splunk.com/en | help-splunk-portal.md |
| https://docs.splunk.com/Documentation/Splunk | FAILED (403, see below) |

Skipped categories: none present in urls.txt.

## Failures
- https://docs.splunk.com/Documentation/Splunk : 403 Forbidden. Alternative https://help.splunk.com/en fetched instead (no build facts).

## plan.md corrections
- none applied (no proven factual error).
- Unverified conflict: Docker Hub shows tags `10.2` and `latest`; TrueCharts pins `10.6.2`; download page offers 10.6.2.5. Image tag existence for 10.6.2 not checked on Hub page.
- Note: `SPLUNK_GENERAL_TERMS` required for 10.x per Docker Hub quickstart; not on docker-splunk docs pages.
