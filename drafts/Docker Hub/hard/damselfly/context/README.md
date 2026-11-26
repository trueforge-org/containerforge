# damselfly: source context (fetched 2026-11-26)

## Sources fetched

| Source URL | Summary file |
| --- | --- |
| https://github.com/Webreaper/Damselfly (README via raw) | github-webreaper-damselfly.md |
| https://github.com/Webreaper/Damselfly/releases | github-webreaper-damselfly.md |
| https://raw.githubusercontent.com/Webreaper/Damselfly/master/docs/Installation.md | github-webreaper-damselfly.md |
| https://raw.githubusercontent.com/Webreaper/Damselfly/master/scripts/makeserver.sh | github-webreaper-damselfly.md |
| https://raw.githubusercontent.com/Webreaper/Damselfly/e110926104cc93d3c87a9617ba7ab4ae70dbb216/Dockerfile | github-webreaper-damselfly.md |
| https://raw.githubusercontent.com/Webreaper/Damselfly/e110926104cc93d3c87a9617ba7ab4ae70dbb216/damselfly-entrypoint.sh | github-webreaper-damselfly.md |
| https://hub.docker.com/r/webreaper/damselfly | dockerhub-webreaper-damselfly.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/damselfly (values.yaml) | truecharts-damselfly.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (never fetched) |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base app link |
| https://github.com/Webreaper/Damselfly/releases/download/4.5.3/Server-Dist-linux.zip | direct binary (zip) download; asset name conflict noted in github-webreaper-damselfly.md |
| https://github.com/Webreaper/Damselfly/releases/download/${VERSION}/Server-Dist-linux.zip | direct binary download; same |
| https://github.com/Webreaper/Damselfly/archive/refs/tags/${VERSION}.tar.gz | direct source archive; not fetched |
| https://github.com/Webreaper/Damselfly (repo root) | covered by the README and releases fetches |

## Fetch failures

- First attempt at the releases page failed with a DNS error (getaddrinfo EAI_AGAIN github.com); retry succeeded. No fetch failures remain.
- 4.5.3 asset list did not show asset names (page says "4 assets").
- Not fetched: the base image `webreaper/damselfly-base` (not in the repo; plan says so too).

## plan.md corrections

None required on the facts fetched. Consistent with plan.md: entrypoint behaviour, build command (net10.0, linux-x64 only, self-contained, no trim), Dockerfile base and COPY list, port 6363, volumes `/config`, `/pictures`, `/thumbs`, the 4.5.3 release date.

## Unverified / conflicts (plan.md left as-is, except the note added in section 10)

- **Asset name conflict:** plan.md uses `Server-Dist-linux.zip` (4.5.3). makeserver.sh on master produces `damselfly-server-linux-<version>.zip`; the docs cite `damselfly-server-linux-2.9.0.zip` for older releases. Confirm the 4.5.3 asset name before writing the URL.
- .NET version: README says ".Net 7 / EFCore 7"; build script targets net10.0. plan.md uses .NET 10 (build script wins).
- Database: SQLite per plan (migrations project); the docs say only that the DB lives in `/config`.
- `Damselfly.Web` (DAMSELFLY_BLAZORSERVER) exists in the entrypoint script at this commit; whether the 4.5.3 zip contains it is UNVERIFIED.
- arm64: no linux-arm64 target in makeserver.sh (plan's compile path is therefore a custom publish); ML native libraries on linux-arm64 remain UNVERIFIED.
- Licence: README says "free, open-source"; no licence name fetched (plan's GPL-3.0-only unverified).
- Entrypoint ordering nuance: ONDEMAND_THUMBS overrides SYNO_THUMBS's cmdlineargs when both are set (script behaviour).
