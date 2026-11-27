# npm: n8n package (registry metadata)

Source URL(s) + date:
- https://registry.npmjs.org/n8n/latest (2026-11-27)

What it is: npm package `n8n`, latest version seen **2.49.8**.

Key fields:
- bin: `n8n -> ./bin/n8n`
- main: `dist/index`, types `dist/index.d.ts`
- engines: `node >=24.0.0`
- license: `SEE LICENSE IN LICENSE.md` (Sustainable Use License, see github-n8n-license.md)
- unpackedSize 34,993,468 bytes; fileCount 7630
- dist.tarball: `https://registry.npmjs.org/n8n/-/n8n-2.49.8.tgz`
- dist.integrity: `sha512-DniqtxaOkMAuuvtkEUZefiqQg+nSN6ZGoBB1Vu0+wFvJY4xinyW9KVxcqY/Nq+dCcVPBudjzPLksHQHHHpTPuQ==`
- dist.shasum (sha1): `0cb5235a09a0c0c5f83bf1c2b02b13a3cc3a68f8`
- Provenance attestation available (SLSA v1 predicate).

Scripts relevant to build: `build` = tsc + tsc-alias + build:data + build:agent-library; `start` = `node ../../scripts/os-normalize.mjs --dir bin n8n` (monorepo path, not meaningful in the published package).

Gotchas:
- Registry `latest` is 2.49.8 on 2026-11-27, not 2.49.6 as the draft plan states (see README plan.md corrections).
- Native modules (isolated-vm, sqlite3, confluent kafka) are arch-specific builds.
