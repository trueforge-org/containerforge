# Context: zerotier

| Source URL | File |
| --- | --- |
| http://download.zerotier.com/debian/resolute | zerotier-readme-and-docs.md |
| https://docs.zerotier.com | zerotier-readme-and-docs.md |
| https://download.zerotier.com/contact%40zerotier.com.gpg | not fetched (binary GPG key, skipped by rule) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/zerotier | dockerhub-and-truecharts-chart.md |
| https://github.com/zerotier/ZeroTierOne | zerotier-readme-and-docs.md |
| https://github.com/zerotier/ZeroTierOne/blob/185a3a2c76e6bf1b1c0415871f43076638eb007c/Dockerfile.release | zerotier-dockerfile-entrypoint.md |
| https://hub.docker.com/r/zerotier/zerotier | dockerhub-and-truecharts-chart.md |

Skipped categories:
- Binary: `contact%40zerotier.com.gpg` (GPG key blob, not fetched; the fingerprint is open in plan.md section 1).

Failures:
- `https://raw.githubusercontent.com/zerotier/ZeroTierOne/185a3a2.../healthcheck.sh` (guessed path, not in repo): 404. Upstream generates `/healthcheck.sh` at runtime in entrypoint, so no repo file exists.

## plan.md corrections
- L17 "Entrypoint env vars": removed `metricstoken.secret` from `ZEROTIER_API_SECRET` and `ZEROTIER_LOCAL_CONF` from the upstream list (upstream `entrypoint.sh.release` reads only ZEROTIER_API_SECRET, ZEROTIER_IDENTITY_PUBLIC, ZEROTIER_IDENTITY_SECRET, ZEROTIER_JOIN_NETWORKS). Source: entrypoint.sh.release at 185a3a2.
- Unverified conflicts (not edited):
  - plan L16 says upstream Dockerfile is `debian:bookworm`; confirmed. The apt suite upstream is `bookworm`; plan uses `resolute` (Ubuntu 26.04). Not a plan error; noted only.
