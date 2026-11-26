# Docker Hub: guhu007/auto-yt-dl

**Source URL(s) + fetch date:** https://hub.docker.com/r/guhu007/auto-yt-dl · fetched 2026-11-26

## What it is
"auto-yt-dl": Docker image that fetches new videos from chosen YouTube channels. Web GUI to manage the channel list. Built and tested for unRaid (the author says it is their first Docker image). Relies on pytube.
- When a channel is added, existing video URLs are stored; only videos published after that are downloaded (no back catalogue).
- Roughly every 15 minutes it checks for new uploads; detection typically under 30 minutes.

## Install/build steps
- `docker pull guhu007/auto-yt-dl`
- Example run: detached, container name `auto-yt-dl`, bridge networking, non-privileged, `-p 5000:5000` (GUI), host `/test` mounted to `/app/Downloads` read-write, image `xxguhuxx/yt-channel-dl:latest`. The page notes the example uses a different image name from the pull command and that it is not tested on all systems. Full command exceeds quote limit; summarised, not verbatim.

## Ports
`5000/tcp` (GUI at `<host>:5000`).

## Volumes/paths
`/app/Downloads` (downloads). Chart also mounts `/app/data`.

## Env vars
None listed.

## Version/release info
- Only `latest` tag shown. Digest `sha256:eb3e4e838…`, 66.8 MB.
- Last updated almost 3 years ago (page relative date). 50K+ pulls, 2 stars.
- No version or tag numbers published.

## Arch support
Not stated.

## License
Not stated.

## Source link
None given on the page. Page's example names a different image (`xxguhuxx/yt-channel-dl`). Repo `github.com/xXGuhuXx/auto-yt-dl` returns 404 (see README.md).

## Gotchas
- Name mismatch between the repo/image (`guhu007/auto-yt-dl`) and the example (`xxguhuxx/yt-channel-dl`).
- No Dockerfile or source is public from what was fetched.

## Contradictions with plan.md
- None. plan.md states 50K+ pulls, 66.8 MB, last updated almost 3 years ago, port 5000/tcp, `/app/Downloads`: all confirmed.
