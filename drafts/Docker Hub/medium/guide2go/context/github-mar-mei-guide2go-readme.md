# mar-mei/guide2go: README (master)
Source URL: https://raw.githubusercontent.com/mar-mei/guide2go/master/README.md (fetched 2026-11-26, 407 lines; fork-level changelog at top)

- Guide2Go: Go program writing XMLTV EPG from Schedules Direct JSON API.
- Requires Schedules Direct account and Go toolchain to build the binary.
- Build: run inside source folder (go build; see README Installation).
- CLI: `guide2go -configure <file>.yaml` (create lineup config), `guide2go -config <file>.yaml` (run with config).
- Features: cache (download only new EPG data), no DB, memory ~1-2 GB.
- Config from v1.0.6 and older is incompatible.
- Recent changes section: image caching/proxy option (images served from guide2go server).
