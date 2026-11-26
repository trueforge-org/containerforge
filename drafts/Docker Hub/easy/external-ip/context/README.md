# Context index: external-ip

Fetched 2026-11-26.

## Sources summarised

| Source URL | Summary file |
| --- | --- |
| https://github.com/xavier-hernandez/docker-external-ip | github-xavier-hernandez-docker-external-ip.md |
| https://github.com/xavier-hernandez/docker-external-ip/blob/3be417fe91ba6ab1be2eeb1c2ee218d01470a185/Dockerfile | github-xavier-hernandez-docker-external-ip.md |
| https://raw.githubusercontent.com/xavier-hernandez/docker-external-ip/3be417fe91ba6ab1be2eeb1c2ee218d01470a185/README.md | github-xavier-hernandez-docker-external-ip.md |
| https://raw.githubusercontent.com/xavier-hernandez/docker-external-ip/3be417fe91ba6ab1be2eeb1c2ee218d01470a185/Dockerfile | github-xavier-hernandez-docker-external-ip.md |
| https://raw.githubusercontent.com/xavier-hernandez/docker-external-ip/3be417fe91ba6ab1be2eeb1c2ee218d01470a185/scripts/start.sh | github-xavier-hernandez-docker-external-ip.md |
| https://raw.githubusercontent.com/xavier-hernandez/docker-external-ip/3be417fe91ba6ab1be2eeb1c2ee218d01470a185/scripts/lib/notify.sh | github-xavier-hernandez-docker-external-ip.md |
| https://raw.githubusercontent.com/xavier-hernandez/docker-external-ip/3be417fe91ba6ab1be2eeb1c2ee218d01470a185/scripts/lib/ipv4.sh | github-xavier-hernandez-docker-external-ip.md |
| https://github.com/xavier-hernandez/docker-external-ip/releases | github-xavier-hernandez-docker-external-ip.md |
| https://hub.docker.com/r/xavierh/external-ip | dockerhub-xavierh-external-ip.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/external-ip | truecharts-external-ip.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/external-ip/values.yaml | truecharts-external-ip.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page (only the user can sign) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge apps/<base> link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/xavier-hernandez/docker-external-ip/archive/<commit>.tar.gz | direct archive download; pattern recorded in the repo summary |
| https://github.com/xavier-hernandez/docker-external-ip/archive/${VERSION}.tar.gz | direct archive download with template variable |
| ghcr.io/trueforge-org/python, ghcr.io/trueforge-org/ubuntu | ghcr image refs, not web pages |

Named references without a URL, not fetched: Apprise (PyPI package `apprise`), Pushover API (`api.pushover.net`, referenced only in the script), bind9-dnsutils / packages.ubuntu.com (plan.md only).

## Fetch failures

None.

## Notes
- Upstream has no GitHub release assets; releases page says "There aren't any releases here." Tags were not listed, so plan.md's claim of tag `v0.0.1` is unverified here.
- The fetched Dockerfile and scripts were returned by a summarizing fetch, so content is faithful to the summary but not byte-verified.

## plan.md corrections

No factual corrections were needed. Items left as unverified (not edited):
- plan.md section 1 says the chart image is built from `main` HEAD commit `3be417fe...`. The chart pins `latest@sha256:eae953...` instead, and no source here maps that digest to a commit. Unverified.
- plan.md section 1 says tag `v0.0.1` exists (commit `b249ecf`). Tags were not listed by the fetch. Unverified.
- plan.md section 1 says the upstream repo is MIT licensed. The LICENSE file was not fetched. Unverified.
