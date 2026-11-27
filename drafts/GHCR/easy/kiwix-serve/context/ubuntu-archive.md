# Ubuntu archive and packages search

## Source URL(s) + fetch date

- https://archive.ubuntu.com/ubuntu (Apache directory listing)
- https://packages.ubuntu.com (package search site)
- Fetched 2026-11-26

## What it is

- `archive.ubuntu.com/ubuntu`: Ubuntu's package archive. Apt fetches packages from here.
- `packages.ubuntu.com`: web search for packages and files in the archive.

## archive.ubuntu.com layout (seen in listing, plus general Ubuntu archive structure)

Top-level entries seen: `dists/`, `indices/`, `ls-lR.gz`, `pool/`, `project/`, `ubuntu/`.

- `dists/<suite>/<component>/binary-<arch>/` holds package indices and Release files per suite.
- `pool/<component>/<prefix>/<source>/` holds the `.deb` and source files. Stored once even if several suites use it.
- Suites: release names (e.g. noble, jammy) plus `-updates`, `-security`, `-backports`, `-proposed`.
- Components: `main` (supported free), `restricted` (supported proprietary, e.g. drivers), `universe` (community free), `multiverse` (licensing-restricted).

## apt sources usage

Entry format: `deb http://archive.ubuntu.com/ubuntu <suite> <components...>`
Example: `deb http://archive.ubuntu.com/ubuntu noble main universe`
Apt then reads `dists/<suite>/<component>/binary-<arch>/` indices and downloads from `pool/`.

## packages.ubuntu.com usage (lookup only, not for apt)

- By package name: `https://packages.ubuntu.com/<pkg>`
- By source package: `https://packages.ubuntu.com/src:<name>`
- Suite browse: `https://packages.ubuntu.com/<suite>/` (e.g. `jammy/`, `noble-updates/`). The `/<suite>/<pkg>` form is implied by suite-prefixed paths; the page did not spell it out explicitly.
- Filters: suite/distribution (jammy, noble, resolute, plus -updates and -backports), section (main, multiverse, restricted, universe), and for file search an architecture (i386, amd64, arm64, ppc64el, riscv64, s390x).
- Two searches: package directory (name/description) and package-contents file search (exact name, suffix, substring).
- Older releases: old-releases.ubuntu.com.

## Dockerfile notes

- Use the archive in `sources.list` / `ubuntu.sources` or rely on the base image's default mirrors.
- Use packages.ubuntu.com to check which suite/component provides a package before adding it to `apt-get install`.
- Gotcha: the archive listing is a live directory; do not hardcode the `ls-lR.gz` index in builds.
