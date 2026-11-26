# dockovpn context index

Fetched 2026-11-26. Summaries of every web source referenced by draft.md and plan.md.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/dockovpn/dockovpn | github-dockovpn-dockovpn.md |
| https://github.com/dockovpn/dockovpn/blob/v1.14.0/Dockerfile (fetched as raw v1.14.0/Dockerfile) | github-dockovpn-dockovpn.md (Dockerfile section) |
| https://github.com/dockovpn/dockovpn/releases/tag/v1.14.0 | github-dockovpn-dockovpn.md (release section) |
| raw v1.14.0/scripts/start.sh (plan's start.sh behavior) | github-dockovpn-dockovpn.md (launch sequence section) |
| https://hub.docker.com/r/alekslitvinenk/openvpn | dockerhub-alekslitvinenk-openvpn.md |
| https://dockovpn.io | docs-dockovpn-io.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dockovpn | truecharts-dockovpn.md (directory not fetched; values.yaml fetched via raw URL) |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dockovpn/values.yaml | truecharts-dockovpn.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (not a source) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/dockovpn/dockovpn/archive/refs/tags/v${VERSION}.tar.gz | contains `${` (template) |
| https://github.com/dockovpn/dockovpn/archive/refs/tags/v1.14.0.tar.gz | direct archive download (naming pattern recorded in repo summary) |

## Fetch failures

- https://raw.githubusercontent.com/dockovpn/dockovpn/v1.14.0/start.sh: HTTP 404 (script lives in `scripts/`). One alternative tried: `scripts/start.sh` at v1.14.0, which succeeded.
- https://github.com/dockovpn/dockovpn/releases/tag/v1.14.0: fetched, but the asset list did not load (page reports 2 assets, names not shown).
- Not fetched: `functions.sh` (sourced by start.sh; holds `generateClientConfig`). Not on the draft/plan URL list; the one-level follow rule was not applied because it is a shell helper, not a doc page.

## plan.md corrections

- None applied. Every checked plan claim (version, Dockerfile ENV and ports, EXPOSE, VOLUME, ENTRYPOINT, start.sh behaviour, iptables rules, flags -r/-n/-q/-s, license GPL-2.0) matches the fetched sources.

## plan.md unverified (not edited)

- Section 1, Downloads row: "The release has no binary assets (expanded assets list is empty)". The release page says "2 assets" but the names did not load, so the empty-list claim could not be confirmed here. Source: github-dockovpn-dockovpn.md (release section).
- Section 10: "The upstream config serves the client .ovpn via netcat on the conf port". start.sh has no nc server; delivery is in functions.sh (not fetched). The README describes an HTTP server on 8080 that shuts down after the download. Source: github-dockovpn-dockovpn.md.
- Section 6 settings: the env list omits `HOST_TUN_PROTOCOL` (README default udp; TrueCharts sets it; only UDP supported per chart comment). Not an error, a possible addition. Source: github-dockovpn-dockovpn.md, truecharts-dockovpn.md.
