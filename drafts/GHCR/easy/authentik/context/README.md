# Context: authentik

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/authentik/values.yaml + Chart.yaml | truecharts-authentik.md |
| https://raw.githubusercontent.com/goauthentik/authentik/98ec4a7684fcb0cccfe78888a12df1df1ad938be/lifecycle/container/{ldap,proxy,radius}.Dockerfile (+ blob variants) | github-authentik-outpost-dockerfiles.md |
| https://api.github.com/repos/goauthentik/authentik/license, .../releases/latest, .../contents/LICENSE, https://github.com/goauthentik/authentik, https://raw.githubusercontent.com/goauthentik/authentik/main/README.md | github-authentik.md |
| https://docs.goauthentik.io, https://goauthentik.io/docs | docs-goauthentik-io.md |
| https://github.com/kiwigrid/k8s-sidecar, https://github.com/kiwigrid/k8s-sidecar/blob/2.14.3/Dockerfile | github-kiwigrid-k8s-sidecar.md |
| https://github.com/maxmind/geoipupdate, https://github.com/maxmind/geoipupdate/blob/v8.0.0/docker/Dockerfile | github-maxmind-geoipupdate.md |

Skipped categories: none beyond the filtering already applied to urls.txt. Docker Hub not applicable (GHCR images).

Failures: none.

## plan.md corrections
None edited. Checked: Radius EXPOSE 1812/udp and proxy EXPOSE 9000/9300/9443 (plan marks these UNVERIFIED; now confirmed by lifecycle Dockerfiles). Latest release 2026.8.7 matches plan note.
