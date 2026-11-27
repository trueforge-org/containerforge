# TasmoCompiler README (master)
Source URL: https://raw.githubusercontent.com/benzino77/tasmocompiler/master/README.md (fetched 2026-11-27)

- Web GUI to compile Tasmota firmware: board, features/sensors, WiFi credentials, Tasmota version (development or latest stable), GUI language, custom #defines
- Docker run: `docker run --rm --name tasmocompiler -p 3000:3000 benzino77/tasmocompiler` -> http://localhost:3000
- Debug env: `-e DEBUG=server,git,compile` (server, git, compile categories)
- Dev tag: `benzino77/tasmocompiler:development` tracks Tasmota development branch
- Non-Docker: `node server/app.js` (port 3000)
