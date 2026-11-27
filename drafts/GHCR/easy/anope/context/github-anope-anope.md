# anope/anope (upstream project)
Source URL(s): https://raw.githubusercontent.com/anope/anope/master/README.md (fetched 2026-11-27); https://github.com/anope/anope/releases/tag/2.0.21 (HTML alt, fetched); https://api.github.com/repos/anope/anope/releases/latest (403, see README failures); https://api.github.com/repos/anope/anope/license (403)

## What it is
Open source set of IRC services. Modular. Runs on Linux, BSD, Windows. Supports InspIRCd, UnrealIRCd, ircd-hybrid. Connects OUT to an IRC server (no listening port).

## Release
- Latest release tag on GitHub release page: `2.0.21` (title "Anope 2.0.21")
- Release page shows "Assets" section; the HTML fetch did not list asset names (plan says only a Windows .exe, not re-verified here)

## Build (README, Linux/BSD)
```
./Config
cd build
make
make install
```
- Afterwards: `cp conf/anope.example.conf conf/anope.conf`, edit uplink/serverinfo/protocol module blocks
- Run: `./bin/anope` (`--support` flag for logs)
- Extra modules: `./extras` from source dir, then re-run Config/make/make install; third-party modules go in `modules/third`
- Included example confs (modules.example.conf, etc.) are referenced by `include` in anope.conf

## Runtime
- Config in `conf/` (anope.conf copied from example)
- Binary `bin/anope`

## Gotchas
- README does not state build deps (compiler, OpenSSL, cmake); not verified here
- Windows installer exists (not relevant to Linux container)
