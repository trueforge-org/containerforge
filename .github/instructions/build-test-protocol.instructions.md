---
description: "Standardised build, run, and test protocol for all ContainerForge agents and AI runners. Per-container loop: build → fix → run → parse logs → fix → test → fix. Defines log-success criteria and the narrow exception for database-dependent apps. Applies to any work touching apps/<app>/."
applyTo: "apps/**"
---

# Build, Run & Test Protocol (apps/**)

This is the **single source of truth** for how every agent, subagent, and AI runner builds, runs, and tests a container in this repo. All agents listed in `.github/agents/` and any ad-hoc AI workflow MUST follow this protocol exactly. If another instruction or agent file conflicts with this one on the build/run/test loop, this file wins.

It is intentionally orchestration-only. File-shape rules still live in the matching files in `.github/instructions/`.

## Universal rules

- **Per-container only.** Always operate on exactly one `apps/<app>/` at a time. Never batch builds or tests across apps. Never parallelise across apps.
- **Strict order.** Always: bake-print → build → run+log-check → test. Do not skip a step. Do not advance until the current step is clean.
- **Smallest correct fix.** When a step fails, diagnose the real cause and apply the minimum change inside `apps/<app>/`. No drive-by refactors, no formatting-only edits, no dependency bumps unrelated to the failure.
- **Never weaken real assertions.** Do not delete, comment out, loosen, or stub an existing assertion in `container-test.yaml` to make CI green. Fix the defect.
- **Round limit.** Per app, cap the build↔run↔test loop at **10 rounds**. If still failing, stop and record as `unfixable` with the last error. Do not loop indefinitely.
- **Clean up.** Always `docker rm -f` and `docker volume rm` your scratch container/volume between rounds and before moving on.
- **Commit cadence on PRs.** When operating on an existing PR branch, commit and push after **every successful fix that turns a step green** (one Conventional Commit per app per fix wave). Do not stack uncommitted fixes across apps. Never `--force` push, never amend pushed commits.

## The loop (per app)

Run these in order. Each step has a pass criterion and a fail action. Do not move on until the pass criterion is met.

### 0. Read instructions
Before editing anything in `apps/<app>/`, load every instruction file in `.github/instructions/` matching the file types you will touch (Dockerfile, docker-bake, settings.yaml, container-test, start-script, plus python-runtime / go-runtime when relevant). Read them; don't paraphrase from memory.

### 1. Bake print
```sh
cd apps/<app>
docker buildx bake --print
```
- **Pass:** exits 0 with a valid plan.
- **Fail:** fix `docker-bake.hcl` and/or `Dockerfile` (version alignment, target wiring, renovate annotations) per the bake/Dockerfile instructions, then retry.

### 2. Build
```sh
docker buildx bake --set image-local.platform=linux/amd64 image-local
```
- **Pass:** image built, no errors.
- **Fail:** fix the real cause (missing dep, broken upstream URL, base-image API change, version mismatch, read-only-rootfs regression at build time). Retry from step 1.
- Only attempt arm64 if the failure is arm64-specific.

### 3. Run and parse logs
```sh
docker run --rm -d --name <app>-probe --read-only --tmpfs /tmp \
  -v <app>-probe-config:/config <image>:<version>
docker logs -f <app>-probe   # tail until idle / startup complete
```
- **Pass criterion ("indicates success"):** ALL of:
  1. Container is still running after a reasonable startup window (process did not exit).
  2. Logs contain at least one positive readiness signal — e.g. `listening on`, `ready`, `started`, `serving HTTP`, `database connection established`, app's documented "ready" line, or the declared port is open (`ss -ltn` / TCP probe).
  3. Logs contain **no** fatal/critical errors, no repeated stack traces, no "exiting" / "shutting down" lines that aren't part of normal idle behavior.
- **Fail action:** capture the first ~100 log lines, diagnose, fix the real cause inside `apps/<app>/` (commonly `start.sh` seeding, env defaults, `/config` first-run logic, read-only-rootfs writes), then retry from step 1.
- **Always test empty-`/config` startup.** Use a fresh named volume per round; remove it between rounds.
- **Cleanup:** `docker rm -f <app>-probe; docker volume rm <app>-probe-config`.

### 4. Test suite
Mirror what CI does in `.github/actions/app-tests/action.yaml` (forgetool):
```sh
forgetool containers test \
  --image <image>:<version> \
  --config ./apps/<app>/container-test.yaml
```
If `forgetool` is unavailable locally, run the container per step 3 and validate the assertions from `container-test.yaml` by hand (TCP/HTTP/file/process checks). Do not invent your own loose assertions.

- **Pass:** all assertions pass.
- **Fail:** fix the real cause. Never weaken an existing assertion. Retry from step 1 if the fix touched build artifacts, otherwise retry from step 3.

## Database-dependent apps (narrow exception)

Some apps cannot fully self-test in a single container because they require an external database (postgresql, mariadb, valkey, etc.) declared under `dependencies:` / `opt_dependencies:` in `settings.yaml`. The exception below applies **only** to apps that meet ALL of:
- Have a hard `dependencies:` entry on a database service, AND
- Will not start (or will fail health) without that DB in the same network, AND
- Are not feasible to wire up to a sidecar DB inside `container-test.yaml` with the available primitives.

For these apps:

1. **Step 3 (run + log parse) is mandatory and must indicate success** as defined above. The container is allowed to log "waiting for database" / connection-retry messages — that counts as a positive readiness signal **only** when paired with the process staying alive and no fatal exit.
2. `container-test.yaml` MAY use minimal smoke assertions instead of full functional probes — for example: process is running, declared port is open, expected binary/file exists, startup-banner line appears in logs. These are still **real** assertions, just narrower in scope.
3. You MUST NOT:
   - Replace assertions with no-op / always-true checks.
   - Disable test execution.
   - Mark a test as skipped without an assertion the schema accepts.
4. Add a brief comment in `container-test.yaml` near the narrowed assertions noting the DB dependency, e.g. `# narrowed: requires external <dep>; full functional test not feasible in single-container suite`.

If the app does not meet all three criteria above, this exception does not apply — write proper functional tests.

## Failure classification (when triggered by CI)

When invoked by an agent that consumes CI failures (e.g. PR Fix, Release Autofix), classify each failed check **before** entering the loop:

- **Real failure → run the loop.** Build errors, container test failures with correct assertions, runtime errors in logs, schema/lint failures on `settings.yaml` / `container-test.yaml` / `docker-bake.hcl` / `start.sh`.
- **Infra noise → skip and record.** Attestation/provenance/cosign, manifest-list merge, registry rate-limits / 5xx / TLS handshake timeouts, runner died/cancelled, cache restore/save failures.

When in doubt, fetch `gh run view <run-id> --log-failed --job <job-id>` and read the last ~200 lines.

## PR-mode commit cadence

When working on an existing PR branch:
- After each app turns green locally end-to-end (steps 1–4 all pass), immediately:
  ```sh
  git add apps/<app>/
  git commit -m "fix(<app>): <short root cause>"
  git push origin <pr-head-ref>
  ```
- One Conventional Commit per app per fix wave. Do NOT bundle multiple apps into one commit. Do NOT wait for CI to re-run before moving to the next app.
- WIP commits (`fix(<app>): wip <reason>`) are allowed only when handing off mid-loop is safer than holding uncommitted state.

## Pre-completion checklist (per app)

1. `docker buildx bake --print` exits 0.
2. `image-local` build succeeds.
3. Container starts on `--read-only --tmpfs /tmp` with an **empty** `/config` volume, and logs indicate success per step 3.
4. `container-test.yaml` assertions all pass via the same mechanism CI uses.
5. No assertion was weakened; any DB-dep narrowing is annotated and justified.
6. Scratch containers/volumes were cleaned up.
7. (PR mode) The fix is committed and pushed in its own per-app commit.
