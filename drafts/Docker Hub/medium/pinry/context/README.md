# Context README: pinry

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pinry/values.yaml | truecharts-pinry.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pinry/Chart.yaml | truecharts-pinry.md |
| https://hub.docker.com/v2/repositories/getpinry/pinry/ | dockerhub-pinry.md |
| https://hub.docker.com/v2/repositories/getpinry/pinry/tags?page_size=10 | dockerhub-pinry.md |
| https://api.github.com/repos/pinry/pinry/releases/latest | github-pinry.md |
| https://raw.githubusercontent.com/pinry/pinry/a21b1e73c2f889499286339b8cc59c411e40b9b1/Dockerfile.autobuild | github-pinry.md |
| https://pypi.org/pypi/pinry/json | pypi-pinry.md |

Skipped: CLA/none; forgetool schemas/none; containerforge apps links/none; templated URLs/none; binary downloads/none; image refs/none; GitHub repo HTML and blob view, GitHub repo API (budget); pinry.readthedocs.io and getpinry.com (not fetched, budget).

Failures: none.

## plan.md corrections
- Edit 1 (plan.md line 8): `Latest GitHub release v2.1.14, published 2026-11-23` -> `Latest GitHub release v2.1.15, published 2026-11-26` (source: https://api.github.com/repos/pinry/pinry/releases/latest, tag v2.1.15 "v2.1.15 security release", published 2026-11-26T13:46:12Z).
- Unverified conflict (not edited): plan still sets build target `2.1.14` (bake `default = "2.1.14"` at line 74, test refs at lines 202-208). Latest tag is now 2.1.15 and Docker Hub `2.1.15` exists. Needs a decision by the author; not changed here.
- Other plan facts re-checked and consistent: Docker Hub `2.1.13` last updated 2024-10-03, amd64 only; PyPI `pinry` 1.3.2, Simplified BSD; upstream `EXPOSE 80`, `VOLUME ["/data"]`, no USER.
