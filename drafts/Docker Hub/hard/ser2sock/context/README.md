# context: ser2sock

| Source URL | File |
| --- | --- |
| https://github.com/tenstartups/ser2sock/blob/9553300/Dockerfile.x64 | tenstartups-dockerfile-x64.md |
| https://github.com/tenstartups/ser2sock (+ raw entrypoint.sh) | tenstartups-entrypoint-and-repo.md |
| https://github.com/nutechsoftware/ser2sock | nutech-ser2sock-readme.md |
| https://hub.docker.com/r/tenstartups/ser2sock | dockerhub-tenstartups-ser2sock.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ser2sock | truecharts-ser2sock.md |

Skipped categories: none present in urls.txt (no CLA, forgetool, containerforge, templated, binary, or image-ref URLs).

## Failures
- none

## plan.md corrections
- none applied (plan not read; no proven factual error fixed in place).
- Notes for plan author: upstream source build uses unpinned `alpine:latest` and unpinned nutech HEAD; TrueCharts uses BAUD_RATE 115200 vs Dockerfile default 9600; entrypoint `-f` flag quirk (unverified).
