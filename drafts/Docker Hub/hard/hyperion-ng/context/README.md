# hyperion-ng context

| Source URL | File |
| --- | --- |
| https://api.github.com/repos/hyperion-project/hyperion.ng/releases/latest | github-hyperion-releases.md |
| https://raw.githubusercontent.com/hyperion-project/hyperion.ng/master/README.md (repo root) | github-hyperion-readme.md |
| https://docs.hyperion-project.org | docs-hyperion-project-gettingstarted.md (landing, no install facts) |
| https://docs.hyperion-project.org/user/gettingstarted/Overview.html | docs-hyperion-project-gettingstarted.md |
| https://docs.hyperion-project.org/user/advanced/CLI.html (followed from docs links) | docs-hyperion-project-cli.md |
| https://hub.docker.com/r/sirfragalot/hyperion.ng | dockerhub-sirfragalot-hyperion-ng.md |
| https://hyperion-project.org | hyperion-project-org-home.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hyperion-ng | truecharts-hyperion-ng.md (via raw values.yaml; tree page not fetched) |

Skipped: none of the listed categories applied.

Failures: 0.

## plan.md corrections
2 edits (both hyperiond flags, from docs-hyperion-project-cli.md):
- plan.md line 18: `(-u/--userdata, UNVERIFIED, check hyperiond --help)` -> `(--userdata <path> per upstream CLI docs; no -u short form documented)`
- plan.md line 66: `exec hyperiond -u /config --silent` -> `exec hyperiond --userdata /config -s`; upstream documents `--userdata <path>` and `-s` (silent) only.

Unverified notes (no edit):
- plan.md labels 19400 (FlatBuffers) as inferred. docs-hyperion-project-cli.md states flatbuffer port 19400. Port is confirmed by docs.
- Hub and chart tags are 2.0.0-alpha and 2.2.0 respectively. Plan pins 2.2.1 (GitHub latest, 2026-04-06). Chart digest matches Hub latest, not the 2.2.1 release.
