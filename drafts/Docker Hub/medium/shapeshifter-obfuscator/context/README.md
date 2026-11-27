# context: shapeshifter-obfuscator

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shapeshifter-obfuscator/values.yaml | truecharts-shapeshifter-obfuscator.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shapeshifter-obfuscator/Chart.yaml | truecharts-shapeshifter-obfuscator.md |
| https://hub.docker.com/v2/repositories/juchong/shapeshifter-docker/ (+ tags?page_size=10) | dockerhub-shapeshifter-docker.md |
| https://raw.githubusercontent.com/juchong/shapeshifter-docker/d2857ae/Dockerfile | github-shapeshifter-obfuscator-dockerfile.md |
| https://api.github.com/repos/OperatorFoundation/shapeshifter-dispatcher/license | github-shapeshifter-obfuscator-dockerfile.md |
| https://api.github.com/repos/OperatorFoundation/shapeshifter-dispatcher/releases (fetched as releases/latest) | github-shapeshifter-obfuscator-dockerfile.md |
| https://github.com/OperatorFoundation/shapeshifter-dispatcher, https://github.com/juchong/shapeshifter-docker, /blob/d2857ae/Dockerfile | skipped: HTML/blob variants, raw/api used |

Skipped categories: GitHub HTML/blob pages (raw or api variants used).

Failures: none.

## plan.md corrections
- No edits made.
- Confirmed: upstream Dockerfile is `FROM alpine`, EXPOSE 2222/tcp, VOLUME /config; dispatcher license MIT (plan line 11); latest release v3.0.1 (plan line 8).
- Conflict (not edited, needs author decision): the chart mounts persistence at `/state` and passes `-state state` in ARGS, while plan line ~45 sets `ENV HOME=/config` and `VOLUME /config`. Chart expects `/state`.
- Not fetched (not in URL list): upstream run.sh; plan's statements about its ARGS mapping stay UNVERIFIED.
