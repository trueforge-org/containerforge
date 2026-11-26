# vstavrinov/acestream_search (search library used by the wrapper)

**Source URL(s) + fetch date:** https://raw.githubusercontent.com/vstavrinov/acestream_search/master/README.md · fetched 2026-11-26 (named as `git+https://github.com/vstavrinov/acestream_search.git` in the wrapper Dockerfile)

## What it is
Tool that generates an acestream m3u playlist, an XML EPG, or JSON data. Default output is a "long m3u playlist".

## Install/build steps and build deps
`pip install acestream-search` (PyPI package name, per README). The wrapper Dockerfile instead installs from git HEAD, which is a different install path.

## Runtime deps
An Ace Stream engine must be installed separately in client mode. The README points users who do not want to install the engine to `vstavrinov/acestream-service`.

## Binaries/entrypoint/CLI flags
CLI command `acestream_search` (`-h` for options). README does not mention a `search:app` WSGI entry point; the wrapper's `search.py` provides the gunicorn app.

## Env vars
None mentioned.

## Ports / Volumes / User / Config
Not mentioned.

## Healthcheck/readiness endpoints
None listed.

## Version/release info and asset naming
Not stated in the fetched README.

## Arch support
Not stated.

## Gotchas
- README (PyPI install) and wrapper Dockerfile (git install) use different installation sources; the wrapper pins nothing.
- Requires a running engine; the wrapper bundles it.

## Contradictions with plan.md
- plan.md section 4 says to pin `acestream_search` to a commit. The README points to PyPI (`pip install acestream-search`). Pinning a PyPI version is an option the plan does not mention.
