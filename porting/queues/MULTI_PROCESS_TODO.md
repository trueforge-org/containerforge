# Multi-Process Container Issues

## kasmvnc and oscam

These containers require running multiple processes simultaneously:

### kasmvnc
Needs to run:
- Xvnc server
- nginx
- pulseaudio
- Node.js kclient
- startwm.sh

The current start.sh has multiple `exec` commands, but only the first one will ever run since `exec` replaces the current process.

### oscam
Needs to run:
- oscam binary
- pcscd daemon

Similar issue - has two `exec` commands but only the first will run.

## Solution Needed

These containers need a process supervisor like:
- supervisord
- s6-overlay
- tini with a wrapper script

Or they could be refactored to use a single entrypoint that forks the necessary processes in the background before exec'ing the main process.

## For Now

These containers remain in the `failing` queue until they can be properly refactored to support multi-process execution.
