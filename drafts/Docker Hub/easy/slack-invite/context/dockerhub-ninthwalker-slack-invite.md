# ninthwalker/slack-invite (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/ninthwalker/slack-invite (fetched 2026-11-26)

## What it is
Small web app for inviting users to a Slack team. Page marks it "NOT FOR GENERAL USE"; customised for personal use and unRAID. Derived from outsideris/slack-invite-automation.

## Install/build steps
- `docker pull ninthwalker/slack-invite`
- Example run (page): `docker run -it --rm -e COMMUNITY_NAME="YOUR-TEAM-NAME" -e SLACK_URL="YOUR-TEAM.slack.com" -e SLACK_TOKEN="YOUR-ACCESS-TOKEN" -p 3000:3000 slack-invite-automation` (uses the local build name, and port 3000).

## Env vars
COMMUNITY_NAME, SLACK_URL, SLACK_TOKEN (generate as admin, not owner), INVITE_TOKEN (optional), LOCALE (de, en, es, fr, ja, ko, pl, pt, pt-BR, tr, zh-CN, zh-TW). Also settable through config.js or .env.

## Ports
Page says 3000 (app reached at localhost:3000). Upstream code default is 7879.

## Volumes
None documented.

## Version/release info and asset naming
- Only tag: `latest`. Image about 257 MB. 10K+ pulls. Updated over 9 years ago (no exact date).

## Arch support
Not listed.

## Gotchas
- The Docker Hub example's port 3000 disagrees with the code (7879).
- The image's `latest` is undated; source link points to outsideris/slack-invite-automation rather than ninthwalker/slack-invite.

## Contradictions with plan.md
- plan.md "Docker Hub latest maps to 5f3a5f2": not checkable from this page (only tag `latest`).
