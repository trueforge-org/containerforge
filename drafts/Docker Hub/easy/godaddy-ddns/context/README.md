# Context index: godaddy-ddns

Fetched 2026-11-26.

## Sources summarised

| Source URL | Summary file |
| --- | --- |
| https://github.com/jwater7/docker-godaddy-publicip-updater | github-jwater7-docker-godaddy-publicip-updater.md |
| https://raw.githubusercontent.com/jwater7/docker-godaddy-publicip-updater/ab3b048d7a369d816990ad624f58baf8a4c5b480/Dockerfile | github-jwater7-docker-godaddy-publicip-updater.md |
| https://raw.githubusercontent.com/jwater7/docker-godaddy-publicip-updater/ab3b048d7a369d816990ad624f58baf8a4c5b480/godaddy-publicip-updater.py | github-jwater7-docker-godaddy-publicip-updater.md |
| https://raw.githubusercontent.com/jwater7/docker-godaddy-publicip-updater/master/README.md | github-jwater7-docker-godaddy-publicip-updater.md |
| https://github.com/jwater7/docker-godaddy-publicip-updater/releases/tag/releases/1.0.4 | github-jwater7-docker-godaddy-publicip-updater.md |
| https://raw.githubusercontent.com/jwater7/docker-godaddy-publicip-updater/ab3b048d7a369d816990ad624f58baf8a4c5b480/LICENSE | github-jwater7-docker-godaddy-publicip-updater.md (404, recorded as failure) |
| https://hub.docker.com/r/jwater7/godaddy-publicip-updater | dockerhub-jwater7-godaddy-publicip-updater.md |
| https://pypi.org/pypi/pif/json (pif package, plan.md section 1) | pypi-pif-and-godaddypy.md |
| https://pypi.org/pypi/godaddypy/json (godaddypy package, plan.md section 1) | pypi-pif-and-godaddypy.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/godaddy-ddns | truecharts-godaddy-ddns.md (values.yaml fetched; directory listing not fetched) |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/godaddy-ddns/values.yaml | truecharts-godaddy-ddns.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page (only the user can sign) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge apps/<base> link |
| https://github.com/jwater7/docker-godaddy-publicip-updater/blob/ab3b048/Dockerfile | same file as the raw Dockerfile URL, fetched once |
| https://github.com/trueforge-org/truecharts/... `oci://oci.trueforge.org/...` | OCI reference, not a page |
| ghcr.io/trueforge-org/python, ghcr.io/trueforge-org/ubuntu | ghcr image refs, not web pages |
| https://api.godaddy.com (GoDaddy API) | runtime API used by the script, not a source page; not called |
| `pif` public IP services (default pif sources) | runtime lookups, not fetched |
| docker.io `latest` image pull | covered by the Docker Hub page |

## Fetch failures

- https://raw.githubusercontent.com/jwater7/docker-godaddy-publicip-updater/ab3b048.../LICENSE: HTTP 404 (no LICENSE file at the pinned commit). Recorded as a failure, not a skip.
- https://github.com/jwater7/docker-godaddy-publicip-updater/releases/tag/releases/1.0.4: asset names did not load (error placeholder); the page itself loaded.

## plan.md corrections

None made. No fact in the sources clearly contradicted plan.md. Items left as unverified:
- plan.md section 1: Docker Hub image is "amd64 only, last pushed 2020-04-28". The Hub page lists no architectures and only says "over 6 years ago". Unverified (not edited).
- plan.md section 1: tag `releases/1.0.4` script lacks `int()` around `GET_IP_WAIT_SEC` and `UPDATE_INTERVAL_SEC`. The 1.0.4 script was not fetched. Unverified.
- plan.md section 1: godaddypy "BSD classifier" and 2.5.1 "from 2023-11-12". Classifier list and upload date not read. Unverified.
- plan.md section 1 and 10: GoDaddy production API restricted to accounts with enough domains or a qualifying plan. Not checked against GoDaddy docs; the README only says to create production keys. Unverified.
- plan.md section 10: `pif` license (GPL 2.0/LGPL 2.1) is confirmed; which of the two applies is still open.
