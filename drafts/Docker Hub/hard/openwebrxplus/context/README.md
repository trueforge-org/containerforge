# openwebrxplus context

| Source URL | File |
| --- | --- |
| https://github.com/0xAF/openwebrxplus-docker-builder/blob/3ead881/buildfiles/Dockerfile-softmbe | 0xaf-dockerfile-softmbe.md |
| https://github.com/0xAF/openwebrxplus-docker-builder (raw README) | 0xaf-builder-readme.md |
| https://github.com/luarvique/openwebrx (raw README) | luarvique-openwebrx-readme.md |
| https://luarvique.github.io/ppa/noble/Packages | ppa-noble-packages.md |
| https://hub.docker.com/r/slechev/openwebrxplus-softmbe | dockerhub-slechev-openwebrxplus-softmbe.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/openwebrxplus (values.yaml) | truecharts-openwebrxplus-values.md |

Skipped:
- https://luarvique.github.io/ppa/openwebrx-plus.gpg: binary signing key; not fetched (apt verifies it at build time).

Failures:
- https://luarvique.github.io/ppa/noble (directory index): 404; not retried. Package data came from the Packages file.

## plan.md corrections
- None made. Plan's version 1.2.131, amd64 deb SHA256 16f0d07f…, python3-csdr/python3-digiham `<< 3.13` constraint, Docker Hub tag 1.2.131 and port 8073 agree with fetched sources.
- Note (no edit): truecharts chart uses `/status.json` for HTTP probes; plan uses `/metrics` from upstream healthcheck.sh (not contradicted).
