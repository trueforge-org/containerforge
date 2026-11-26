# Context: anki-sync-server

Fetched 2026-11-26. Summaries of every web source referenced by `draft.md` and `plan.md`.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/ankicommunity/anki-sync-server-rs (repo, releases, LICENSE) | github-ankicommunity-anki-sync-server-rs.md |
| https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/master/README.md | github-ankicommunity-anki-sync-server-rs.md |
| https://github.com/ankicommunity/anki-sync-server-rs/blob/1.1.4/Dockerfile | github-ankicommunity-anki-sync-server-rs.md |
| https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/1.1.4/scripts/entrypoint.sh | github-ankicommunity-anki-sync-server-rs.md |
| https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/1.1.4/scripts/ankisyncd.toml | github-ankicommunity-anki-sync-server-rs.md |
| https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/master/docs/CONTAINER.md | github-ankicommunity-anki-sync-server-rs.md |
| https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/1.1.4/LICENSE | github-ankicommunity-anki-sync-server-rs.md |
| https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/1.1.4/src/main.rs | github-ankicommunity-anki-sync-server-rs.md |
| https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/1.1.4/src/app_config.rs | github-ankicommunity-anki-sync-server-rs.md |
| https://docs.ankiweb.net/sync-server.html | docs-docs-ankiweb-net-sync-server.md |
| https://hub.docker.com/r/ankicommunity/anki-sync-server-rs | dockerhub-ankicommunity-anki-sync-server-rs.md |
| https://github.com/ankicommunity/anki-devops-services | github-ankicommunity-anki-devops-services.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/anki-sync-server | truecharts-anki-sync-server.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/anki-sync-server/values.yaml | truecharts-anki-sync-server.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge `apps/<base>` link.
- ghcr.io/trueforge-org/ubuntu (and the `:26.04@sha256` ref): image reference, not a web page.
- docker.io/ankicommunity/anki-sync-server-rs:1.1.4: image reference (the Docker Hub page above was fetched instead).
- https://github.com/ankicommunity/anki-sync-server-rs/releases/download/1.1.4/ankisyncd_1.1.4_linux_x64.tar.gz and `..._linux_arm64.tar.gz`: direct binary downloads, not fetched. Asset pattern noted in the repo summary.
- https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/${VERSION}/LICENSE: templated URL (`${`). The concrete 1.1.4 LICENSE was fetched instead.
- http://anki-sync-server-probe:27701/, http://host:27701/: placeholder/example hosts from the draft and plan.

## Fetch failures / partial

- https://github.com/ankicommunity/anki-sync-server-rs/releases: page loaded, but the asset list did not render ("Assets 6" only). Asset names taken from plan.md, not confirmed.
- https://hub.docker.com/r/ankicommunity/anki-sync-server-rs: no architectures, ports, volumes or env vars on the page.
- Note: the upstream `ankisyncd.toml` in the tarball was not fetched (only `scripts/ankisyncd.toml`).

## plan.md corrections

No in-place edits made. Items checked and left as unverified:

- unverified: plan.md section 1 says the bundled `ankisyncd.toml` uses `root_dir = "."`. Source `scripts/ankisyncd.toml` at 1.1.4 uses `root_dir = "/app"` (github-ankicommunity-anki-sync-server-rs.md). The tarball copy was not fetched, so the claim was not changed.
- unverified: `user --list` in start.sh (plan.md section 7). No `user --list` appears in the fetched `main.rs`/README. The `parse_args` module was not fetched.
- unverified: whether `fetch_users` returns `None` or `Some(vec![])` for an empty auth DB (app_config.rs). The panic chain (`new_server` Err -> `main` unwrap) was confirmed.
- confirmed (no edit): env vars `ANKISYNCD_USERNAME`, `ANKISYNCD_PASSWORD`, `MAX_SYNC_PAYLOAD_MEGS` (default 1000); port 27701; archived status; upstream `VOLUME /app`; `EXPOSE 27701`.
