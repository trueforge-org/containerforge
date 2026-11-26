# Context for fileshelter

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://github.com/epoupon/fileshelter | github-epoupon-fileshelter.md |
| https://github.com/epoupon/fileshelter/blob/bcdddfab893b2cba8aa455261b36c88160e843e7/Dockerfile-release | github-epoupon-fileshelter.md (raw file at the same commit) |
| https://github.com/epoupon/fileshelter/archive/refs/tags/v${VERSION}.tar.gz | not fetched (binary archive); pattern recorded in github-epoupon-fileshelter.md |
| https://github.com/emweb/wt/archive/${WT_VERSION}.tar.gz | not fetched (binary archive); see github-emweb-wt.md |
| https://github.com/emweb/wt | github-emweb-wt.md |
| https://hub.docker.com/r/epoupon/fileshelter | dockerhub-epoupon-fileshelter.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fileshelter | truecharts-fileshelter.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| http://127.0.0.1:5091/ | localhost / loopback |
| ghcr.io/trueforge-org/ubuntu, ghcr.io/trueforge-org/ubuntu:26.04@sha256:... | ghcr image refs, not web pages |

## Fetch failures

- None.

## Notes

- Repo README at v6.4.0 holds no install/config detail (points to INSTALL.md, not fetched). Install facts come from the upstream Dockerfile-release and the sample config.

## plan.md corrections

- None made. Checked and consistent: port 5091 (draft 8080 was wrong and plan already says so), working dir `/var/fileshelter`, upstream build/runtime package lists, Wt 4.12.3 pin, and Wt's GPL-2.0-with-OpenSSL-exception license.
- Unverified (not changed): `LICENSE` value `GPL-3.0-only` vs `GPL-3.0-or-later` (COPYING is GPLv3 text without a per-file notice); Wt CMake flags in plan omit upstream `-DWT_CPP20_DATE_TZ_IMPLEMENTATIO`, `CMAKE_INTERPROCEDURAL_OPTIMIZATION`, and `-DDEBUG` (design choice, not a factual error).
