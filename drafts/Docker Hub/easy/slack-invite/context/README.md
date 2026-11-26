# slack-invite context

Fetched 2026-11-26.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/ninthwalker/slack-invite (Dockerfile, package.json, config.js, bin/www, routes/index.js, app.js, README.md, LICENSE.md at 5f3a5f2; releases page) | github-ninthwalker-slack-invite.md |
| https://github.com/ninthwalker/slack-invite/releases | github-ninthwalker-slack-invite.md |
| https://hub.docker.com/r/ninthwalker/slack-invite | dockerhub-ninthwalker-slack-invite.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/slack-invite (values.yaml) | truecharts-slack-invite.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema (skip rule).
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base app link (skip rule).
- httpss://github.com/ninthwalker/slack-invite (draft.md, malformed scheme): same repo as above; not fetched as typed.
- https://github.com/ninthwalker/slack-invite/ (trailing slash) and .../blob/master/Dockerfile: covered by the pinned raw Dockerfile.
- https://github.com/ninthwalker/slack-invite/archive/${VERSION}.tar.gz: source archive download (skip rule). The pinned SHA is recorded in the repo summary.
- https://<SLACK_URL>/api/users.admin.invite (plan.md): placeholder host (skip rule); the endpoint is described from routes/index.js.
- ghcr.io/trueforge-org/python-node (named in plan.md and draft.md): image ref, not a web page (skip rule).

## Fetch failures

- None. Releases page loaded: no releases. Tags tab not readable.

## plan.md corrections

None made. Checked and matching the context:
- Dockerfile (node:onbuild, EXPOSE 7879, COPY, npm install, CMD ./bin/www), port 7879 from bin/www and the draft's 3000 being wrong, env defaults in config.js, the Slack invite call (`users.admin.invite` form fields), MIT license (LICENSE.md, Copyright 2015 Outsider Jeonghoon Byun), and package.json dependency list.

## Unverified (not changed in plan.md)

- Section 1 LOCALE list includes `ru`; the README locale list omits it. Left as is (could be a locales/ file not fetched).
- Section 1 "latest and only relevant commit 5f3a5f2 (2017-03-10)" and "no tags": commit date and tags not checked.
- Section 1 "GitHub also reports MIT": not checked.
- Section 1 "outsideris/slack-invite-automation is archived": not checked.
- Section 7/9 i18n `updateFiles` default and rewrite behaviour: i18n package docs not fetched. The build-time sed in plan.md section 4 is consistent with app.js (`autoReload: true` present, no updateFiles option).
- Section 10 "Slack retired users.admin.invite for legacy tokens": no fetched source says this (README does not mention deprecation). Left as is.
