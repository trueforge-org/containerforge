# josegonzalez/python-github-backup (GitHub, the PyPI `github-backup` project)

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/josegonzalez/python-github-backup/master/README.rst (the `main` branch path returned 404; `master` worked)
- https://raw.githubusercontent.com/josegonzalez/python-github-backup/master/LICENSE.txt
- Fetched 2026-11-26

**What it is**
Python CLI that backs up a GitHub user's or organisation's data (repositories, issues, wikis and more) to a local directory. This is the project the PyPI package `github-backup` comes from (`pip install github-backup`). Note: this is a different project from the lnxd image.

**Install/build steps and build deps**
`pip install github-backup` (PyPI). Requires Python 3.11 or newer (per PyPI metadata) and Git 1.9 or newer at runtime. Git LFS is needed only for `--lfs`. `openssl` on PATH is needed only for `--app-id` (GitHub App auth).

**Binaries/entrypoint/CLI flags**
- Command: `github-backup [options] USER`. `-O, --organization` when the target is an organisation.
- Tokens: `-t, --token TOKEN_CLASSIC` (classic, OAuth or JWT), `-f, --token-fine TOKEN_FINE` (fine-grained `github_pat_...`). Both accept `file://<path>`; `-t file:///dev/stdin` pipes a token (Unix only).
- `--token-from-gh` reads the token from `gh auth token`; with `--github-host` it passes `--hostname HOST`.
- GitHub App: `--as-app`, `--app-id`, `--app-private-key`, `--app-installation-id`. `--app-id` implies `--as-app` and cannot be combined with `-t`, `-f`, `--token-from-gh` or keychain options.
- macOS only: `--keychain-name`, `--keychain-account`.
- `-o, --output-directory` sets the output directory.
- `--all` includes issues, comments, events, timeline, pulls, reviews, commits, labels, hooks, milestones, security advisories, discussions, repositories, wikis and more. It excludes `--attachments`, `-P/--private`, `-F/--fork`, `--all-starred`, `--pull-details`, `--lfs`, `--gists`, `--starred-gists`.
- With no data-selecting flag (for example `--all` or `--repositories`) nothing is saved.
- Example from README: `github-backup WhiteHouse --token $ACCESS_TOKEN --organization --output-directory /tmp/white-house --repositories --private`.

**Env vars**
None read by the tool (README examples only use shell variables for their own flags).

**Ports**
None (one-shot CLI).

**Config files and formats**
None.

**Version/release info and asset naming**
PyPI latest: `0.68.0`, `requires_python >=3.11`, license MIT, no `requires_dist` declared (no Python dependencies). Home page `http://github.com/josegonzalez/python-github-backup`.

**Arch support**
Pure Python, no native code; no arch-specific asset.

**License**
MIT, "Copyright (c) 2013 Jose Diaz-Gonzalez" (LICENSE.txt, on master).

**Gotchas**
- Pick `-f` (fine-grained) for cron-style use; the README recommends it.
- Without `--all` or a data-selecting flag nothing is saved.

**Contradictions with plan.md**
- plan.md section 1 says the CLI takes `-t/--token` and `-f/--token-fine` with `file://` paths, `--all` exclusions, `--organization`, `--token-from-gh`. All match. plan.md wrote `--organization`; the short form is `-O`. Not an error.
- plan.md says the PyPI package requires Python >= 3.11 with classifiers for 3.11 to 3.14. PyPI metadata confirms `>=3.11`. Classifier list not checked here.
- plan.md says the tag `0.68.0` has `LICENSE.txt`. Only `master` was read; the tag is unverified.
