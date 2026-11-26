# Context sources: xmrig

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/xmrig/xmrig | github-xmrig-xmrig.md |
| https://github.com/xmrig/xmrig/releases | github-xmrig-xmrig.md (release and asset naming) |
| https://github.com/xmrig/xmrig/releases/download/... (see skipped) | skipped; names recorded in github-xmrig-xmrig.md |
| https://xmrig.com/docs | docs-xmrig-com.md |
| https://xmrig.com/docs/miner/command-line-options (followed) | docs-xmrig-com.md |
| https://hub.docker.com/r/cooleye72/xmrig | dockerhub-cooleye72-xmrig.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/xmrig | truecharts-xmrig.md |

Also fetched: upstream v6.27.0 `src/version.h` and `src/config.json`, recorded in github-xmrig-xmrig.md.

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/xmrig/xmrig/releases/download/... (linux-static-x64 tarball, SHA256SUMS) | direct binary/archive downloads; naming recorded |
| ghcr.io/trueforge-org/ubuntu (with digest) | ghcr image ref, not a web page |
| docker.io/cooleye72/xmrig:6.21 | image ref, covered by the Docker Hub page |

## Fetch failures

- https://raw.githubusercontent.com/xmrig/xmrig/v6.27.0/src/config/config.json: HTTP 404 (wrong path guess). Alternative `src/config.json` succeeded.
- Ubuntu package claims (xmrig 6.25.0+dfsg-1 in resolute, arm64) were not fetched: no packages.ubuntu.com URL is in the draft for this app.
- plan.md says `linux-static-arm64` and `linux-arm64` return 404: not re-tested here; the release listing shows no arm64 Linux assets.

## plan.md corrections

Edited: none.

Notes (not edited):
- confirmed: upstream latest v6.27.0 (version.h; release dated 23 Nov). Chart pins 6.21 (values).
- confirmed: `config.json` defaults: `autosave` true; `http.enabled` false, `host` 127.0.0.1, `port` 0, `restricted` true; `randomx.rdmsr`/`wrmsr` true; `donate-level` 1.
- confirmed: CLI options in plan.md section 1 (`--userpass`, `--rig-id`, `--tls`, `--tls-fingerprint`, `--keepalive`, `--donate-level`, `--threads`, `--no-huge-pages`, `--http-host`, `--http-port`, `--http-access-token`, `--http-no-restricted`, `--config`, `--no-color`, `--print-time`, `--user-agent`, `--cpu-max-threads-hint`).
- confirmed: plan.md's `XMRIG_DONATE_LEVEL` default 1 matches the upstream default of 1%, so the "UNVERIFIED upstream default" wording in plan.md section 6 is now resolved; left as-is.
- confirmed: no Linux arm64 asset in the release list (plan.md section 1). plan.md's apt route for arm64 is therefore still the only arm64 route.
- unverified: plan.md section 1 license (GPL-3.0) and "or later" wording: the README names no license.
- unverified: plan.md section 1 Ubuntu package `xmrig 6.25.0+dfsg-1` in resolute and the packages.ubuntu.com search; not fetched.
- unverified: plan.md section 1 `randomx.rdmsr/wrmsr` and sample key names used in plan section 7 (pools[].url/user/pass/rig-id/tls, http.*): confirmed for the sample file's `pools` and `http` keys; `huge-pages` sits under `cpu` in the sample.
- note: plan.md's policy blocker (section 10) is untouched by these facts.
