# Context: kerio-connect

| Source URL | File |
| --- | --- |
| https://github.com/chvb/docker-kerio-connect/blob/eb6b9083dd9e9a68e4a67b73c178a0450cecd8ca/Dockerfile | chvb-dockerfile.md |
| (follow-up) https://github.com/chvb/docker-kerio-connect (README at same commit) | chvb-readme.md |
| (follow-up) https://github.com/chvb/docker-kerio-connect/blob/eb6b9083dd9e9a68e4a67b73c178a0450cecd8ca/etc/init.d/kerio-connect.sh | chvb-init-script.md |
| (follow-up) https://github.com/chvb/docker-kerio-connect/blob/eb6b9083dd9e9a68e4a67b73c178a0450cecd8ca/etc/supervisor/conf.d/supervisord.conf | chvb-supervisord-conf.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/kerio-connect | truecharts-kerio-connect-chart.md |
| https://hub.docker.com/r/chvb/docker-kerio-connect | hub-docker-chvb-kerio-connect.md |
| https://www.gfi.com/products-and-solutions/network-security-solutions/kerio/kerio-connect | FAILED (301 to gfi.ai, then 404) |
| https://www.kerio.com | kerio-com-redirect-gfi-home.md (301 to gfi.ai home, fetched) |

Skipped categories: none in urls.txt.

## Failures
- https://www.gfi.com/products-and-solutions/network-security-solutions/kerio/kerio-connect: 301 to https://gfi.ai/products-and-solutions/network-security-solutions/kerio/kerio-connect, which returned 404. Not retried further.

## plan.md corrections
- No edits made.
- Unverified conflict: plan Source URL points at the gfi.com product page (marked "use the one that resolves"). That page redirects to gfi.ai and returns 404. The kerio.com home redirects to gfi.ai home (200). Pick a resolving URL at implementation.
- Unverified: plan's ports and Dockerfile facts match the chvb pinned commit (EXPOSE list and volumes confirmed). Plan's 10.0.9 p2 version and CDN URL were not re-verified here (chvb Docker Hub page shows 9.2.9 Patch 1 for `latest`, which is the unversioned upstream image, not the plan's pin).
