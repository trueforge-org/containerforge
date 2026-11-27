#!/usr/bin/env bash
set -euo pipefail

# Seed the OBS autostart only when missing. The base only seeds its own default when this file is absent.
mkdir -p /config/.config/openbox /config/.config/obs-studio /tmp/.cache
if [[ ! -f /config/.config/openbox/autostart ]]; then
  cp /defaults/obs-autostart /config/.config/openbox/autostart
fi

# NDI runtime: downloaded on first start only after the user accepts the NDI SDK license.
# UNVERIFIED: the libdir name inside the SDK archive, the archive marker and NDI_RUNTIME_DIR_V6 (check by running it).
if [[ "${NDI_ACCEPT_EULA:-}" == "yes" ]] && ! ls /config/ndi/libndi.so.6* >/dev/null 2>&1; then
  mkdir -p /config/ndi /tmp/ndi
  curl -fsSL -o /tmp/ndi/sdk.tar.gz "https://downloads.ndi.tv/SDK/NDI_SDK_Linux/Install_NDI_SDK_v6_Linux.tar.gz"
  tar -xzf /tmp/ndi/sdk.tar.gz -C /tmp/ndi
  # Extract the embedded archive without running the interactive installer
  start_line="$(awk '/^__NDI_ARCHIVE_BEGIN__/ { print NR+1; exit }' /tmp/ndi/Install_NDI_SDK_v6_Linux.sh)"
  tail -n +"${start_line}" /tmp/ndi/Install_NDI_SDK_v6_Linux.sh | tar -xz -C /tmp/ndi
  case "$(uname -m)" in
    x86_64) libdir=x86_64-linux-gnu ;;
    aarch64) libdir=aarch64-newtek-linux-gnu ;;
  esac
  find /tmp/ndi -path "*${libdir}*" -name 'libndi.so*' -exec cp -a {} /config/ndi/ \;
  rm -rf /tmp/ndi
fi

if ls /config/ndi/libndi.so.6* >/dev/null 2>&1; then
  export NDI_RUNTIME_DIR_V6=/config/ndi
  export LD_LIBRARY_PATH="/config/ndi:${LD_LIBRARY_PATH:-}"
else
  echo "NDI runtime not installed: set NDI_ACCEPT_EULA=yes to download it, or mount it at /config/ndi"
fi

# Hand off to the kasmvnc base script, which binds Xvnc and nginx on all interfaces
exec /kasmvnc-start.sh "$@"
