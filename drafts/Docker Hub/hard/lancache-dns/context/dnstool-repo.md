# lancachenet/dnstool

Source URL(s): https://github.com/lancachenet/dnstool. Fetched 2026-11-26.

- Go CLI (go.mod, main.go, cmd/), Apache-2.0. Built in lancache-dns Dockerfile builder stage.
- Purpose: replaces bash `10_generate_config.sh` config generator for lancache containers.
- Invocation: `dnstool [command]`; commands: `completion`, `generate` (only `lancache-dns` subcommand), `help`. Flag: `-h/--help`.
- Example: `dnstool generate lancache-dns`.
- No releases/packages. Has .renovaterc. No build instructions on page.
