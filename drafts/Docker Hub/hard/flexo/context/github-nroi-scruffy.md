# GitHub: nroi/scruffy

Source URL(s) + fetch date:
- https://github.com/nroi/scruffy (repo page, fetched 2026-11-26)
- https://github.com/nroi/scruffy/tags (fetched 2026-11-26)

## What it is

- Pacman cache cleaning tool with no libalpm dependency. Meant for non-Arch systems without pacman. The repo page says the Flexo Docker image (Debian-based) uses it.
- License: GPL-2.0 (repo page).

## Install/build steps and build deps

- Cargo required: `cargo build --release`. No package or release download method described on the page.
- Binary: `target/release/scruffy` (so installed name `scruffy`).

## Binaries/CLI flags

- `-c <dir>`: cache directory (e.g. `/var/cache/flexo/pkg`).
- `--keep N`: keep the N most recent versions of each package.
- `-d` / `--dryrun`: preview removals without deleting.
- `-v` / `--verbose`: print affected files.
- `-h`: full option list.
- Example from the page: `scruffy -v -d --keep 2 -c /var/cache/flexo/pkg` (dry run). The page's second example uses `-d --keep 3` but is described as removing files, which conflicts with `-d` meaning dry run. Check `-h` before relying on either command.

## Version/release info

- Tags: 0.2.0 (Sep 30 2022), 0.1.0 (Jan 24 2021). The tags page does not confirm whether GitHub release objects exist.
- Cargo.toml version was not visible in the fetched content. Plan's claim "Cargo.toml 0.1.0 vs tag 0.2.0" is NOT confirmed or refuted here (UNVERIFIED).

## Gotchas

- Repo has 15 commits on `main`, no releases shown.
- Dry-run flag ambiguity in README examples (see CLI section).
