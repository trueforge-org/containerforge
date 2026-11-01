# AGENTS.md

Instructions for AI coding agents working in ContainerForge, including OpenAI Codex/ChatGPT, GitHub Copilot, Claude Code and any other tool that reads `AGENTS.md`.

**Before editing or creating any file under `apps/<app>/`, read [`.github/copilot-instructions.md`](.github/copilot-instructions.md) and the matching files in [`.github/instructions/`](.github/instructions/), and follow them.** Despite its name, `copilot-instructions.md` applies to every agent. These files are the source of truth, so change the rules there and not here.

For any build, run or test work, follow [`.github/instructions/build-test-protocol.instructions.md`](.github/instructions/build-test-protocol.instructions.md).

## Repository

| Path | Contents |
| --- | --- |
| `apps/<app>/` | One image per folder: `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml` and usually `start.sh`. |
| `include/` | Copied into each app's folder during the build: the shared `.dockerignore` and `healthcheck.sh`. |
| `.github/agents/` | Task-specific agents for porting a container and fixing failing CI. |
| `templates/` | Templates for generated docs. |
| `porting/` | Legacy tooling. Ignore it. |

## Commits and pull requests

These apply to every PR an AI agent writes or prepares:

- **Tell the user about the CLA.** Contributions need a signed Contributor License Agreement. Tell the user when you open a PR or prepare one for them. They can sign it at <https://cla-assistant.io/trueforge-org/containerforge>, and the `license/cla` check on the PR shows the status. Only the user can sign it, so never sign it for them.
- **Add the AI notice.** Put `🤖 This PR is AI generated.` in the Notes section of the PR description. Use it instead of a "Generated with ..." line or similar tool attribution, which should not be added.
- **Use the PR template** in [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md), keeping its sections and checkboxes. Tools that create PRs from a body do not pick it up, so fill it in yourself, and only check the boxes that apply.
- **Say what was not tested.** If you could not build or run the image, say so in the PR. Do not check "Built container locally" otherwise.
- Use Conventional Commits for commits and PR titles, with the app as the scope, such as `fix(mariadb): ...` or `feat(mongodb): add mongodb image`. Target `main`.
