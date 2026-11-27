# FiveM server download (Cfx docs) and runtime artifact URLs

Source URL(s): https://docs.fivem.net/docs/server-download/?platform=legacy&os=linux (fetched 2026-11-27); https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master (fetched 2026-11-27)

## What it is
- Cfx docs "Server Download" page: lists server artifacts for Windows and Linux.
- Page "Latest" block: Windows `server.7z`, build 38435.
- Linux artifacts are listed as `build_proot_linux/master/<build>-<commit>/fx.tar.xz`. Highest build number in the page's Linux links: 38781 (about 37 Linux links in total).
- Windows links also appear up to build 38781 in the page HTML.

## Artifact URL pattern (Linux)
- `https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/<build>-<40-hex-commit>/fx.tar.xz`
- Windows: `https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/<build>-<commit>/...`

## Gotchas
- The runtime directory URL `.../build_proot_linux/master/` returns the Cfx docs HTML page (same size as the docs page), NOT a directory listing or a LATEST file. No machine-readable index was found.
- A bare `master` tree therefore has no LATEST file that can be fetched. Pinning requires a specific `<build>-<commit>` path.
- Page is Next.js; the artifact links are in the server-rendered HTML.
