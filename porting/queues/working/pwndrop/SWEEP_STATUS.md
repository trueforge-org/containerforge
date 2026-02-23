# Sweep Status

- Timestamp (UTC): 2026-02-23T20:15:50Z
- Build: ok
- Forgetool test: unavailable (installed forgetool binary has no container test subcommand)
- Run status: running (manual tcp check)
- Timeout for build/test: 120 seconds
- Manual test: `docker run -d -p 8080:8080 pwndrop:1.0.1` + `nc -z 127.0.0.1 8080`

## Last run log tail
```
Welcome to a TrueForge ContainerForge container!

If you are running into any issues, please file a support request on discord.

Container Info:
  * Running as: apps (UID: 568, GID: 568)
  * Additional Groups: apps (GIDs: 568)
  * Number of CPUs available: 4
  * Memory limits (if cgroup available):
        Total: 15994.9 MB

Important Directories:
  * /customscripts exists: no
  * /customoverlay exists: no

Useful Links:
  * Repository: https://github.com/trueforge-org/containerforge
  * Docs: https://trueforge.org
  * Discord: https://discord.gg/tVsPTHWTtr
  * Bugs or feature requests: open a GH issue
  * Questions: discuss in Discord
[entrypoint] No files found in /docker-entrypoint.d/, skipping
[Entrypoint] Checking Device permissions for video devices...
```
