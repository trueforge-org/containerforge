# Downstream changes

## Pre-installed VS Code extensions

The image now ships the VS Code extensions from `.devcontainer/devcontainer.json` in `/config/.vscode-server/extensions` (about 450 MB).

| Downstream container | Required change | Base-image version |
| --- | --- | --- |
| `apps/actions-runner` | None. It inherits the extensions, and its `chown -R apps:docker /config` already covers them. Optionally remove `/config/.vscode-server` if the runner does not need them, but that does not shrink the pulled layers. | 4.1.1 |
