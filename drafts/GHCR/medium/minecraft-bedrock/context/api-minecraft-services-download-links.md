# Minecraft Services download links API (net.web.minecraft-services.net)

Source URL(s) + date:
- https://net.web.minecraft-services.net/api/v1.0/download/links (2026-11-27)

## Response shape
- `result.links[]` with `downloadType` and `downloadUrl`.
- Types seen: serverBedrockWindows, serverBedrockLinux, serverBedrockPreviewWindows, serverBedrockPreviewLinux, serverJar (Java).
- Current values at fetch time:
  - serverBedrockLinux: https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-1.26.66.1.zip
  - serverBedrockPreviewLinux: https://www.minecraft.net/bedrockdedicatedserver/bin-linux-preview/bedrock-server-1.26.70.26.zip
  - serverJar: https://piston-data.mojang.com/v1/objects/33680f5f2ac32864d6d7cf5e56a705fdb3e05f4c/server.jar

## Gotchas
- Values change over time; the entry script selects by `downloadType`. Do not hardcode.
