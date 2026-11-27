# kittizz/bedrock-server-downloads JSON (fallback mirror)

Source URL(s) + date:
- https://raw.githubusercontent.com/kittizz/bedrock-server-downloads/refs/heads/main/bedrock-server-downloads.json (2026-11-27; 24 KB)

## Structure
- Top-level keys: `release`, `preview`.
- Each is a map: version -> `{ "windows": {"url": ...}, "linux": {"url": ...} }`.
- Example entry: `1.21.100` -> linux url `https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-1.21.100.7.zip`.
- Note the key version (`1.21.100`) can differ from the zip version (`1.21.100.7`).

## Gotchas
- Used only as fallback by itzg bedrock-entry.sh.
