# owncast runtime flags (docs)

**Source URL(s) + fetch date**
- https://owncast.online/docs/configuration/runtime-flags/ (fetched 2026-11-26)

**Flags**
| Flag | Value | Default | Persistence |
| --- | --- | --- | --- |
| `--adminpassword` | password | not stated | saved to database (resets admin password at startup) |
| `--backupdir` | directory | not stated | this run only |
| `--database` | file path | `data/owncast.db` | this run only |
| `--enableDebugFeatures` | none | not stated | this run only |
| `--enableVerboseLogging` | none | not stated | this run only |
| `--followervalidationinterval` | seconds | not stated | this run only |
| `--logdir` | directory | not stated | this run only |
| `--restoreDatabase` | backup file | not stated | one-time; exits, restart needed |
| `--rtmpport` | port | `1935` | saved to database |
| `--streamkey` | key | not stated | this session only; hides Stream Keys admin tab |
| `--webserverip` | IP | not stated | saved to database |
| `--webserverport` | port | `8080` | saved to database |

**Notes**
- `--help` lists every flag. Flags saved to the database keep applying after the flag is removed.
- Port changes can also be made in the admin UI; restart needed.
- Example: `owncast --webserverport 9090 --rtmpport 2945`.
- No environment variables mentioned.
