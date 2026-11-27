# dashdot package.json (root, v6.3.4)

Source URL: https://raw.githubusercontent.com/MauriceNino/dashdot/v6.3.4/package.json (fetched 2026-11-27)

## Facts
- name: `dashdot`, private monorepo root, version field `0.0.0` (release version is the git tag, not this field)
- license: MIT
- scripts.start: `cross-env NODE_ENV=production yarn workspace @dashdot/server start`
- Package manager: yarn (Yarn 4 release vendored in `.yarn/releases`, per Dockerfile)

## Gotchas
- Do not rely on the `version` field for the image version; use the tag `v6.3.4`.
