# Context: answer

Fetched 2026-11-26. Summaries of every web source referenced by `draft.md` and `plan.md`.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/apache/answer | github-apache-answer.md |
| https://github.com/answerdev/answer (draft link; redirect to apache/answer not re-checked) | github-apache-answer.md |
| https://github.com/apache/answer/blob/v2.0.3/Dockerfile (fetched as raw) | github-apache-answer.md |
| https://github.com/answerdev/answer/blob/731e8b3001f2eee57c79e0d942fa078c269b9995/Dockerfile (fetched as raw) | github-apache-answer.md |
| https://github.com/apache/answer/releases | github-apache-answer.md |
| https://raw.githubusercontent.com/apache/answer/main/README.md | github-apache-answer.md |
| https://raw.githubusercontent.com/apache/answer/v2.0.3/script/entrypoint.sh | github-apache-answer.md |
| https://raw.githubusercontent.com/apache/answer/v2.0.3/configs/config.yaml | github-apache-answer.md |
| https://answer.apache.org/docs/installation | docs-answer-apache-org-installation.md |
| https://answer.apache.org/docs/env | docs-answer-apache-org-installation.md |
| https://answer.apache.org | docs-answer-apache-org-home.md |
| https://hub.docker.com/r/answerdev/answer | dockerhub-answerdev-answer.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/answer | truecharts-answer.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/answer/values.yaml | truecharts-answer.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge `apps/<base>` link.
- ghcr.io/trueforge-org/ubuntu (and `:26.04@sha256`): image reference.
- docker.io/answerdev/answer:1.2.0 and docker.io/apache/answer: image references (Docker Hub page fetched instead).
- https://github.com/apache/answer/releases/download/v2.0.3/apache-answer-2.0.3-bin-linux-amd64.tar.gz and `-arm64.tar.gz`: direct archive downloads. Asset pattern recorded in the repo summary.
- https://github.com/apache/answer/releases/download/v2.0.3/checksums.txt and the templated `releases/download/v${V}/...` URLs: release download paths. The plan.md sha256 values were not re-verified here.
- https://github.com/answerdev/answer/releases/download/v1.2.0/apache-answer-1.2.0-incubating-linux-*.tar.gz: old 1.2.0 archive download (retired per plan.md).
- http://<ip>: placeholder.
- http://localhost:8080: localhost address.

## Fetch failures / partial

- https://github.com/apache/answer/releases: loaded, but the asset list did not render ("Assets 9" only). Asset names and checksums.txt presence not confirmed.
- https://hub.docker.com/r/answerdev/answer: no architectures, ports, volumes, env vars or tags beyond `latest`.
- https://github.com/apache/answer (README, via raw main): fetched; no separate doc pages were followed (the docs site was used instead).

## plan.md corrections

No in-place edits made. Items checked and left as unverified:

- unverified: plan.md section 1 and section 6 say `AUTO_INSTALL` enables auto-install for any non-empty value, including `false`. The docs (answer.apache.org/docs/env) say "Set to `true`"; the source file `internal/install/install_from_env.go` was not fetched.
- unverified: plan.md section 1 says the installer rewrites cache, i18n and upload paths to `/config/...` with `-C /config`. Source not fetched.
- unverified: `/healthz` answering 200 on the install server (plan.md section 8). Only the chart's `/healthz` probes were seen.
- unverified: plan.md section 1 `answerdev/answer` redirects to `apache/answer`; not re-checked.
- unverified: arch support (amd64/arm64 tarballs) and checksum values; the release asset list did not render.
- unverified: `SKIP_REPLACE_I18N` env var (plan.md section 1); not in the docs.
- confirmed (no edit): v2.0.3 Dockerfile base `golang:1.25-alpine` and `alpine` runtime, `VOLUME /data`, `EXPOSE 80`, `ENTRYPOINT /entrypoint.sh`; entrypoint `init`/`upgrade`/`run -C /data/`; default config paths under `/data`, `0.0.0.0:80`; the swaggerui default; the apache/answer repo is Apache-2.0.
