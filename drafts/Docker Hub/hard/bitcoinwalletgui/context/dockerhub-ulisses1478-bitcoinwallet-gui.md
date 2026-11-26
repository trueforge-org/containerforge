# Docker Hub: ulisses1478/bitcoinwallet-gui

**Source URL(s) + fetch date:** https://hub.docker.com/r/ulisses1478/bitcoinwallet-gui · fetched 2026-11-26

## What it is
Ubuntu container with an XFCE desktop over VNC and a Bitcoin wallet installed. Built so the 120+ GB blockchain can live on a server. Based on `consol/ubuntu-xfce-vnc`.

## Run commands (as shown)
- VNC only: `docker run -d -p 5901:5901 ulisses1478/bitcoinwallet-gui`
- noVNC (browser): `docker run -d -p 6901:6901 ulisses1478/bitcoinwallet-gui`
- Both: `docker run -d -p 5901:5901 -p 6901:6901 ulisses1478/bitcoinwallet-gui`

## Ports
VNC `5901`, noVNC `6901` (per run examples). Plan.md's `6080`/`5900` were the draft's guesses; these are the image's shown ports.

## Volumes
Page says files can be kept outside the container, but the command given has no volume mount.

## Env vars
None listed on the page. (Chart sets `VNC_PW`, `VNC_RESOLUTION`, `VNC_VIEW_ONLY`; see truecharts summary.)

## Privileged
Not mentioned.

## Customisation
Background image `src/common/xfce/.config/bg_sakuli.png`; build from the Dockerfile directory.

## Version/release info
Only `latest` tag. Digest `sha256:b118585c…` (per chart). Size 342.9 MB. 100K+ pulls. "Updated over 7 years ago".

## Arch support
Not stated.

## Licence
Not stated.

## Gotchas
- Image not updated for years; Bitcoin Core inside it is not stated (version unknown).
- Default VNC password in the chart is `vncpassword`; chart stores it in a secret.
- Blockchain data path: `/headless/.bitcoin/` (chart mount).

## Contradictions with plan.md
- plan.md section 1 Ports `6080 noVNC, 5900 VNC`: contradicted by the Hub run examples and the chart (6901 noVNC, 5901 VNC). Corrected in plan.md.
- plan.md Data `/headless/.bitcoin` datadir in the draft image: confirmed by chart mount.
