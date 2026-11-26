# context: cyberchef

## Sources (URL -> file)
| Source URL | File | Fetched |
| --- | --- | --- |
| https://github.com/gchq/CyberChef (README via raw master) | github-gchq-cyberchef.md | 2026-11-26 |
| https://github.com/gchq/CyberChef/releases/latest | github-gchq-cyberchef.md | 2026-11-26 |
| https://github.com/gchq/CyberChef/releases/expanded_assets/${VERSION} (fetched as v11.6.0) | github-gchq-cyberchef.md | 2026-11-26 |
| https://gchq.github.io/CyberChef | docs-gchq-github-io-cyberchef.md | 2026-11-26 |
| https://github.com/mpepping/docker-cyberchef/blob/master/Dockerfile | github-mpepping-docker-cyberchef-dockerfile.md | 2026-11-26 |
| https://hub.docker.com/r/mpepping/cyberchef | dockerhub-mpepping-cyberchef.md | 2026-11-26 |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cyberchef (read via raw values.yaml) | truecharts-cyberchef.md | 2026-11-26 |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/... (both schema URLs): forgetool schema.
- https://github.com/trueforge-org/containerforge/tree/main/apps/nginx and .../apps/ubuntu: containerforge base app links.
- https://github.com/gchq/CyberChef/releases/download/${VERSION}/CyberChef_${commit}.zip and .../download/v11.5.0/CyberChef_8cd426dd4f40f1423912d5fad91b578a86a65112.zip: direct archive downloads. Naming recorded in github-gchq-cyberchef.md.
- https://raw.githubusercontent.com/gchq/CyberChef/${VERSION}/LICENSE: template with variable.
- http://localhost:8080/ and http://$(docker ...): localhost / shell expression.

## Fetch failures
- releases/latest page: asset list did not load ("Uh oh!"). Asset list taken from expanded_assets/v11.6.0 instead (not a failure of the source as a whole).

## plan.md corrections
- Section 1, "Version" row: the draft/chart claim was wrong. The chart uses `mpepping/cyberchef:v11.6.0` (truecharts-cyberchef.md), not v11.5.0. Changed to: "The draft uses `v11.5.0`, which is one release behind; the TrueCharts chart already uses `mpepping/cyberchef:v11.6.0`."
- Confirmed (no edit): v11.6.0 is latest, zip name `CyberChef_f464d62c...zip`, zip sha256 `6b6518c6...` (expanded_assets page), Apache-2.0, port 8000 upstream.
- Unverified (left as-is): plan.md's claim that the zip's `index.html.gz` is byte-identical to `CyberChef_v11.6.0.html`, and the `/assets/fonts/...` test path; not checked in this pass.
- Note: gchq.github.io shows a dev build hash, not a release; not a plan error.
