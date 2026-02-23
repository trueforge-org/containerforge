# Sweep Status

- Timestamp (UTC): 2026-02-23T21:15:42Z
- Build: ok
- Runtime test: fail
- Check type: tcp
- Checked port: 80
- Timeout for run check: 120 seconds
- Forgetool path: /tmp/forgetool-bin/forgetool
- Blocker: backend waits for external MongoDB (`mongodb://mongo:27017/your_spotify`) and never reaches ready state in standalone test runtime.
