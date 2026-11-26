# piratify/invitarr (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/piratify/invitarr
- Fetched 2026-11-26

## Overview
Discord chatbot that sends Plex invitations. Automatic (on role) or manual. Also removes users from Plex on leaving/role loss. Config via a web portal.

## Tags and size
- Only tag shown: `latest`, last updated over 5 years ago. Image size 667.5 MB.
- Architectures: not stated on the page.
- Pulls: 500K+. A star-like count of 3 shown.

## Usage
- `docker pull piratify/invitarr:latest`
- `docker run -d --restart unless-stopped --name invitarr -v /path to config:/app/app/config -e "token=YOUR_DISCORD_TOKEN_HERE" piratify/invitarr:latest`
- Env: `token` (Discord bot token). Volume: `/app/app/config`. Ports: none listed.

## Commands (after start)
- `.plexinvite <email>`, `.plexremove <email>`, `.dbls`, `.dbadd <email> <@user>`, `.dbrm <position>`
- Setup: `.setupplex`, `.roleadd <@role>`, `.setuplibs` (all libraries by default)

## Notes
- Discord privileged intents must be enabled, otherwise DMs to users after role assignment do not work.
- Detailed steps are in a GitHub wiki (Sleepingpirates/Invitarr), not fetched.

## Consistency with chart
TrueCharts `values.yaml` pins `docker.io/piratify/invitarr` `latest@sha256:78a82851aa167e89a5f5d6f025d81ad8b4c08856f166a92f960e4a57a9c264d9`. Digest not checked against Hub.
