#!/usr/bin/env bash



# nginx Path
NGINX_CONFIG=/etc/nginx/sites-available/default

# user passed env vars
CPORT="${CUSTOM_PORT:-3000}"
CHPORT="${CUSTOM_HTTPS_PORT:-3001}"
CWS="${CUSTOM_WS_PORT:-8082}"
CUSER="${CUSTOM_USER:-apps}"
SFOLDER="${SUBFOLDER:-/}"
FILE_MANAGER_PATH="${FILE_MANAGER_PATH:-$HOME/Desktop}"
DASHBOARD="${DASHBOARD:-selkies-dashboard}"
SELKIES_FILE_TRANSFERS="${SELKIES_FILE_TRANSFERS:-upload,download}"
HARDEN_DESKTOP="${HARDEN_DESKTOP:-false}"

# create self signed cert
if [ ! -f "/config/ssl/cert.pem" ]; then
  mkdir -p /config/ssl
  openssl req -new -x509 \
    -days 3650 -nodes \
    -out /config/ssl/cert.pem \
    -keyout /config/ssl/cert.key \
    -subj "/C=US/ST=CA/L=Carlsbad/O=Linuxserver.io/OU=LSIO Server/CN=*"
  chmod 600 /config/ssl/cert.key
  chown -R apps:apps /config/ssl
fi

# modify nginx config
cp /defaults/default.conf ${NGINX_CONFIG}
sed -i "s/3000/$CPORT/g" ${NGINX_CONFIG}
sed -i "s/3001/$CHPORT/g" ${NGINX_CONFIG}
sed -i "s/CWS/$CWS/g" ${NGINX_CONFIG}
sed -i "s|SUBFOLDER|$SFOLDER|g" ${NGINX_CONFIG}
sed -i "s|REPLACE_DOWNLOADS_PATH|$FILE_MANAGER_PATH|g" ${NGINX_CONFIG}
 mkdir -p ${FILE_MANAGER_PATH}
if [[ $SELKIES_FILE_TRANSFERS != *"download"* ]] || [[ ${HARDEN_DESKTOP,,} == "true" ]]; then
  sed -i '/files {/,/^  }/d' ${NGINX_CONFIG}
fi
if [ ! -z ${DISABLE_IPV6+x} ]; then
  sed -i '/listen \[::\]/d' ${NGINX_CONFIG}
fi
if [ ! -z ${PASSWORD+x} ]; then
  printf "${CUSER}:$(openssl passwd -apr1 ${PASSWORD})\n" > /etc/nginx/.htpasswd
  sed -i 's/#//g' ${NGINX_CONFIG}
fi
if [ ! -z ${DEV_MODE+x} ]; then
  sed -i \
    -e 's:location / {:location /null {:g' \
    -e 's:location /devmode:location /:g' \
    ${NGINX_CONFIG}
fi

# set dashboard and icon
rm -Rf \
  /usr/share/selkies/web
cp -a \
  /usr/share/selkies/$DASHBOARD \
  /usr/share/selkies/web
sed -i "s|REPLACE_DOWNLOADS_PATH|$FILE_MANAGER_PATH|g" /usr/share/selkies/web/nginx/footer.html
cp \
  /usr/share/selkies/www/icon.png \
  /usr/share/selkies/web/favicon.ico
cp \
  /usr/share/selkies/www/icon.png \
  /usr/share/selkies/web/icon.png
# manifest creation
echo "{
  \"name\": \"${TITLE}\",
  \"short_name\": \"${TITLE}\",
  \"manifest_version\": 2,
  \"version\": \"1.0.0\",
  \"display\": \"fullscreen\",
  \"background_color\": \"#000000\",
  \"theme_color\": \"#000000\",
  \"icons\": [
    {
      \"src\": \"icon.png\",
      \"type\": \"image/png\",
      \"sizes\": \"180x180\"
    }
  ],
  \"start_url\": \"/\"
}" > /usr/share/selkies/web/manifest.json




# default file copies first run
mkdir -p "$HOME/.config"
chown apps:apps "$HOME/.config"
if [[ ! -f "$HOME/.config/openbox/autostart" ]]; then
  mkdir -p "$HOME/.config/openbox"
  cp /defaults/autostart "$HOME/.config/openbox/autostart"
  chown apps:apps "$HOME/.config/openbox" "$HOME/.config/openbox/autostart"
fi
if [[ ! -f "$HOME/.config/openbox/menu.xml" ]]; then
  mkdir -p "$HOME/.config/openbox" && \
  cp /defaults/menu.xml "$HOME/.config/openbox/menu.xml"
  chown apps:apps "$HOME/.config/openbox" "$HOME/.config/openbox/menu.xml"
fi

# XDG Home
if [ ! -d "$HOME/.XDG" ]; then
  mkdir -p "$HOME/.XDG"
  chown apps:apps "$HOME/.XDG"
fi
printf "$HOME/.XDG" > /run/s6/container_environment/XDG_RUNTIME_DIR

# locale Support
if [ ! -z ${LC_ALL+x} ]; then
  printf "${LC_ALL%.UTF-8}" > /run/s6/container_environment/LANGUAGE
  printf "${LC_ALL}" > /run/s6/container_environment/LANG
fi

# hardening flags
if [[ ${HARDEN_DESKTOP,,} == "true" ]]; then
  export DISABLE_OPEN_TOOLS="true"
  export DISABLE_SUDO="true"
  export DISABLE_TERMINALS="true"
  # application hardening if unset
  if [ -z ${SELKIES_FILE_TRANSFERS+x} ]; then
    printf "" > /run/s6/container_environment/SELKIES_FILE_TRANSFERS
  fi
  if [ -z ${SELKIES_COMMAND_ENABLED+x} ]; then
    printf "false" > /run/s6/container_environment/SELKIES_COMMAND_ENABLED
  fi
  if [ -z ${SELKIES_UI_SIDEBAR_SHOW_FILES+x} ]; then
    printf "false" > /run/s6/container_environment/SELKIES_UI_SIDEBAR_SHOW_FILES
  fi
  if [ -z ${SELKIES_UI_SIDEBAR_SHOW_APPS+x} ]; then
    printf "false" > /run/s6/container_environment/SELKIES_UI_SIDEBAR_SHOW_APPS
  fi
fi
if [[ ${HARDEN_OPENBOX,,} == "true" ]]; then
  export DISABLE_CLOSE_BUTTON="true"
  export DISABLE_MOUSE_BUTTONS="true"
  export HARDEN_KEYBINDS="true"
  if [ -z ${RESTART_APP+x} ]; then
    export RESTART_APP=true
    printf "true" > /run/s6/container_environment/RESTART_APP
  fi
fi

# disable open tools
xdg_open_path=$(which xdg-open 2>/dev/null)
exo_open_path=$(which exo-open 2>/dev/null)
if [[ ${DISABLE_OPEN_TOOLS,,} == "true" ]]; then
  echo "[ls.io-init] Disabling xdg-open and exo-open"
  [ -n "$xdg_open_path" ] && chmod 0000 "$xdg_open_path"
  [ -n "$exo_open_path" ] && chmod 0000 "$exo_open_path"
else
  [ -n "$xdg_open_path" ] && chmod 755 "$xdg_open_path"
  [ -n "$exo_open_path" ] && chmod 755 "$exo_open_path"
fi

# disable sudo
sudo_path=$(which sudo 2>/dev/null)
if [[ ${DISABLE_SUDO,,} == "true" ]]; then
  echo "[ls.io-init] Disabling sudo binary and corrupting sudoers config"
  [ -n "$sudo_path" ] && chmod 0000 "$sudo_path"
  sed -i "s/NOPASSWD/CORRUPT_FILE/g" /etc/sudoers
else
  [ -n "$sudo_path" ] && chmod 4755 "$sudo_path"
  sed -i "s/CORRUPT_FILE/NOPASSWD/g" /etc/sudoers
fi

# disable terminals and menu entries
USER_MENU_DIR="$HOME/.config/openbox"
USER_MENU_XML="$USER_MENU_DIR/menu.xml"
USER_MENU_BAK="$USER_MENU_DIR/menu.xml.bak"
TERMINAL_NAMES=("xterm" "st" "stterm" "uxterm" "lxterminal" "gnome-terminal" "konsole" "xfce4-terminal" "terminator")
if [ -f "$USER_MENU_XML" ] && [ ! -f "$USER_MENU_BAK" ]; then
  echo "[ls.io-init] Creating initial backup of menu.xml"
  cp "$USER_MENU_XML" "$USER_MENU_BAK"
  chown apps:apps "$USER_MENU_BAK"
fi
if [[ ${DISABLE_TERMINALS,,} == "true" ]]; then
  echo "[ls.io-init] Disabling terminal binaries and removing from menu"
  [ -f "$USER_MENU_BAK" ] && cp "$USER_MENU_BAK" "$USER_MENU_XML"
  for term_name in "${TERMINAL_NAMES[@]}"; do
    term_path=$(which "$term_name" 2>/dev/null)
    if [ -n "$term_path" ]; then
      chmod 0000 "$term_path"
      escaped_path=$(echo "$term_path" | sed 's/[&/\]/\\&/g')
      sed -i "/<command>${escaped_path}<\/command>/d" "$USER_MENU_XML"
    fi
  done
  chown apps:apps "$USER_MENU_XML"
else
  if [ -f "$USER_MENU_BAK" ]; then
    cp "$USER_MENU_BAK" "$USER_MENU_XML"
    chown apps:apps "$USER_MENU_XML"
  fi
  for term_name in "${TERMINAL_NAMES[@]}"; do
    term_path=$(which "$term_name" 2>/dev/null)
    if [ -n "$term_path" ] && [ ! -x "$term_path" ]; then
      chmod 755 "$term_path"
    fi
  done
fi

# lock down autostart file if auto restart is enabled
AUTOSTART_SCRIPT="$HOME/.config/openbox/autostart"
if [ -f "$AUTOSTART_SCRIPT" ]; then
  if [[ ${RESTART_APP,,} == "true" ]]; then
    echo "[ls.io-init] RESTART_APP is set. Setting autostart owner to root and making read-only for user"
    chown root:apps "$AUTOSTART_SCRIPT"
    chmod 550 "$AUTOSTART_SCRIPT"
  else
    chown apps:apps "$AUTOSTART_SCRIPT"
    chmod 644 "$AUTOSTART_SCRIPT"
  fi
fi

# openbox tweaks
SYS_RC_XML="/etc/xdg/openbox/rc.xml"
SYS_RC_BAK="/etc/xdg/openbox/rc.xml.bak"
if [ ! -f "$SYS_RC_BAK" ]; then
  echo "[ls.io-init] Creating initial backup of system rc.xml"
  cp "$SYS_RC_XML" "$SYS_RC_BAK"
fi
cp "$SYS_RC_BAK" "$SYS_RC_XML"
if [[ -n "${DISABLE_CLOSE_BUTTON}" ]]; then
  echo "[ls.io-init] Disabling close button"
  sed -i '/<titleLayout>/s/C//' "$SYS_RC_XML"
fi
if [[ ${DISABLE_MOUSE_BUTTONS,,} == "true" ]]; then
  echo "[ls.io-init] Disabling right and middle mouse clicks"
  sed -i -e '/<mousebind button="Right"/,/<\/mousebind>/d' \
         -e '/<mousebind button="Middle"/,/<\/mousebind>/d' "$SYS_RC_XML"
fi
if [[ ! -z ${NO_DECOR+x} ]]; then
  echo "[ls.io-init] Removing window decorations"
  sed -i 's/<application class="\*">/&<decor>no<\/decor>/' "$SYS_RC_XML"
fi
if [[ ! -z ${NO_FULL+x} ]]; then
  echo "[ls.io-init] Disabling maximization"
  sed -i '/<maximized>yes<\/maximized>/d' "$SYS_RC_XML"
fi
if [[ ${HARDEN_KEYBINDS,,} == "true" ]]; then
    echo "[ls.io-init] Disabling dangerous keybinds"
    KEYS_TO_DISABLE=(
        "A-F4"
        "A-Escape"
        "A-space"
        "W-e"
    )
    for key in "${KEYS_TO_DISABLE[@]}"; do
        sed -i "/<keybind key=\"${key}\"/,/<\/keybind>/{s/^/    <!-- /;s/$/ -->/}" "$SYS_RC_XML"
    done
fi

# disable user rc path if config is hardened
USER_RC_XML="$HOME/.config/openbox/rc.xml"
if [[ ${DISABLE_MOUSE_BUTTONS,,} == "true" || ${HARDEN_KEYBINDS,,} == "true" ]]; then
  echo "[ls.io-init] Locking user rc.xml to prevent security overrides"
  mkdir -p "$(dirname $USER_RC_XML)"
  chown apps:apps "$(dirname $USER_RC_XML)"
  cp "$SYS_RC_XML" "$USER_RC_XML"
  chown root:apps "$USER_RC_XML"
  chmod 444 "$USER_RC_XML"
else
  if [ -f "$USER_RC_XML" ] && [ "$(stat -c '%U' $USER_RC_XML)" == "root" ]; then
    echo "[ls.io-init] Hardening disabled, removing locked user rc.xml"
    rm -f "$USER_RC_XML"
  fi
fi

# add proot-apps
proot_updated=false
if [ ! -f "$HOME/.local/bin/proot-apps" ]; then
  mkdir -p "$HOME/.local/bin/"
  cp /proot-apps/* "$HOME/.local/bin/"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  proot_updated=true
elif ! diff -q /proot-apps/pversion "$HOME/.local/bin/pversion" > /dev/null; then
  cp /proot-apps/* "$HOME/.local/bin/"
  proot_updated=true
fi
if [ "$proot_updated" = true ]; then
    chown -R apps:apps "$HOME/.local"
    [ -f "$HOME/.bashrc" ] && chown apps:apps "$HOME/.bashrc"
fi

# Enable vaapi if device detected
if ! which nvidia-smi && [ -e "/dev/dri/renderD128" ] && [ ! -e "/dev/dri/renderD129" ] && [ -z ${DRI_NODE+x} ]; then
  printf "/dev/dri/renderD128" > /run/s6/container_environment/DRI_NODE
fi

# js setup
mkdir -pm1777 /dev/input
touch /tmp/selkies_js.log
chmod 777 /tmp/selkies*
if [[ -z ${NO_GAMEPAD+x} ]] && mknod /dev/input/js0 c 13 0; then
  printf "/usr/lib/selkies_joystick_interposer.so:/opt/lib/libudev.so.1.0.0-fake" > /run/s6/container_environment/LD_PRELOAD
  mknod /dev/input/js1 c 13 1
  mknod /dev/input/js2 c 13 2
  mknod /dev/input/js3 c 13 3
  mknod /dev/input/event1000 c 13 1064
  mknod /dev/input/event1001 c 13 1065
  mknod /dev/input/event1002 c 13 1066
  mknod /dev/input/event1003 c 13 1067
  chmod 777 /dev/input/js* /dev/input/event*
else
  printf "false" > /run/s6/container_environment/SELKIES_UI_SIDEBAR_SHOW_GAMEPADS
  printf "false" > /run/s6/container_environment/SELKIES_GAMEPAD_ENABLED
  printf "false" > /run/s6/container_environment/SELKIES_ENABLE_PLAYER2
  printf "false" > /run/s6/container_environment/SELKIES_ENABLE_PLAYER3
  printf "false" > /run/s6/container_environment/SELKIES_ENABLE_PLAYER3
fi




FILES=$(find /dev/dri /dev/dvb -type c -print 2>/dev/null)

for i in $FILES
do
    VIDEO_GID=$(stat -c '%g' "${i}")
    VIDEO_UID=$(stat -c '%u' "${i}")
    # check if user matches device
    if id -u apps | grep -qw "${VIDEO_UID}"; then
        echo "**** permissions for ${i} are good ****"
    else
        # check if group matches and that device has group rw
        if id -G apps | grep -qw "${VIDEO_GID}" && [ $(stat -c '%A' "${i}" | cut -b 5,6) = "rw" ]; then
            echo "**** permissions for ${i} are good ****"
        # check if device needs to be added to video group
        elif ! id -G apps | grep -qw "${VIDEO_GID}"; then
            # check if video group needs to be created
            VIDEO_NAME=$(getent group "${VIDEO_GID}" | awk -F: '{print $1}')
            if [ -z "${VIDEO_NAME}" ]; then
                VIDEO_NAME="video$(head /dev/urandom | tr -dc 'a-z0-9' | head -c4)"
                groupadd "${VIDEO_NAME}"
                groupmod -g "${VIDEO_GID}" "${VIDEO_NAME}"
                echo "**** creating video group ${VIDEO_NAME} with id ${VIDEO_GID} ****"
            fi
            echo "**** adding ${i} to video group ${VIDEO_NAME} with id ${VIDEO_GID} ****"
            usermod -a -G "${VIDEO_NAME}" apps
        fi
        # check if device has group rw
        if [ $(stat -c '%A' "${i}" | cut -b 5,6) != "rw" ]; then
            echo -e "**** The device ${i} does not have group read/write permissions, attempting to fix inside the container.If it doesn't work, you can run the following on your docker host: ****\nsudo chmod g+rw ${i}\n"
            chmod g+rw "${i}"
        fi
    fi
done

# check if nvidia gpu is present
if which nvidia-smi > /dev/null 2>&1 && ls -A /dev/dri 2>/dev/null; then
    # nvidia-container-toolkit may not place files correctly, so we set them up here
    echo "**** NVIDIA GPU detected ****"
    OPENCL_ICDS=$(find /etc/OpenCL/vendors -name '*nvidia*.icd' 2>/dev/null)
    # if no opencl icd found
    if [ -z "${OPENCL_ICDS}" ]; then
        echo "**** Setting up OpenCL ICD for NVIDIA ****"
        mkdir -pm755 /etc/OpenCL/vendors/
        echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd
    fi
    # find vulkan icds
    ICDS=$(find /usr/share/vulkan/icd.d /etc/vulkan/icd.d -name '*nvidia*.json' 2>/dev/null)
    # if no icd found
    if [ -z "${ICDS}" ]; then
        echo "**** Setting up Vulkan ICD for NVIDIA ****"
        # get vulkan api version
        VULKAN_API_VERSION=$(ldconfig -p | grep "libvulkan.so" | awk '{print $NF}' | xargs readlink | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")
        # Fallback if pipeline fails
        if [ -z "${VULKAN_API_VERSION}" ]; then
            # version 1.1 or greater allows vulkan-loader to load the driver's dynamic library
            VULKAN_API_VERSION="1.1.0"
        fi
        mkdir -pm755 /etc/vulkan/icd.d/
        cat > /etc/vulkan/icd.d/nvidia_icd.json << EOF
{
    "file_format_version" : "1.0.0",
    "ICD": {
        "library_path": "libGLX_nvidia.so.0",
        "api_version" : "${VULKAN_API_VERSION}"
    }
}
EOF
    fi
    # find glvnd egl_vendor files
    EGLS=$(find /usr/share/glvnd/egl_vendor.d /etc/glvnd/egl_vendor.d -name '*nvidia*.json' 2>/dev/null)
    # if no egl_vendor file found
    if [ -z "${EGLS}" ]; then
        echo "**** Setting up EGL vendor file for NVIDIA ****"
        mkdir -pm755 /etc/glvnd/egl_vendor.d/
        cat > /etc/glvnd/egl_vendor.d/10_nvidia.json << EOF
{
    "file_format_version" : "1.0.0",
    "ICD": {
        "library_path": "libEGL_nvidia.so.0"
    }
}
EOF
    fi
fi




# Folder setup
mkdir -p /run/dbus
chown apps:apps /run/dbus

# Run dbus
exec  \
  dbus-daemon \
    --system \
    --nofork \
    --nosyslog 




# wait for X to be running
while true; do
  if xset q &>/dev/null; then
    break
  fi
  sleep .5
done

# set sane resolution before starting apps
if !  xrandr | grep -q "1024x768"; then
   xrandr --newmode "1024x768" 63.50  1024 1072 1176 1328  768 771 775 798 -hsync +vsync
   xrandr --addmode screen "1024x768"
   xrandr --output screen --mode "1024x768" --dpi 96
fi

# set xresources
if [ -f "${HOME}/.Xresources" ]; then
  xrdb "${HOME}/.Xresources"
else
  echo "Xcursor.theme: breeze" > "${HOME}/.Xresources"
  xrdb "${HOME}/.Xresources"
fi
chown apps:apps "${HOME}/.Xresources"
chmod 777 /tmp/selkies*

# run
cd $HOME
exec  \
  /bin/bash /defaults/startwm.sh &
PID=$!
echo "$PID" > /de-pid
wait "$PID"





# Make sure this is a priv container
if [ -e /dev/cpu_dma_latency ]; then
  if [ "${START_DOCKER}" == "true" ]; then
    mount -t tmpfs none /tmp
    exec /usr/local/bin/dockerd-entrypoint.sh -l error
  else
    sleep infinity
  fi
fi
# if anything goes wrong with Docker don't loop
sleep infinity





if pgrep -f "[n]ginx:" >/dev/null; then
    echo "Zombie nginx processes detected, sending SIGTERM"
    pkill -ef [n]ginx:
    sleep 1
fi

if pgrep -f "[n]ginx:" >/dev/null; then
    echo "Zombie nginx processes still active, sending SIGKILL"
    pkill -9 -ef [n]ginx:
    sleep 1
fi

exec /usr/sbin/nginx -g 'daemon off;'




exec  \
  /usr/bin/pulseaudio \
    --log-level=0 \
    --log-target=stderr \
    --exit-idle-time=-1 > /dev/null 2>&1




# Default sink setup
if [ ! -f '/dev/shm/audio.lock' ]; then
  until [ -f /defaults/pid ]; do
    sleep .5
  done
   with-contenv pactl \
    load-module module-null-sink \
    sink_name="output" \
    sink_properties=device.description="output"
   with-contenv pactl \
    load-module module-null-sink \
    sink_name="input" \
    sink_properties=device.description="input"
  touch /dev/shm/audio.lock
fi

# Setup dev mode if defined
if [ ! -z ${DEV_MODE+x} ]; then
  # Dev deps
  apt-get update
  apt-get install -y \
    nodejs
  npm install -g nodemon
  rm -Rf $HOME/.npm
  # Frontend setup
  if [[ "${DEV_MODE}" == "core" ]]; then
    # Core just runs from directory
    cd $HOME/src/addons/gst-web-core
     npm install
     npm run serve &
  else
    # Build core
    cd $HOME/src/addons/gst-web-core
     npm install
     npm run build
     cp dist/selkies-core.js ../${DEV_MODE}/src/
     nodemon --watch selkies-core.js --exec "npm run build && cp dist/selkies-core.js ../${DEV_MODE}/src/" & 
    # Copy touch gamepad
     cp ../universal-touch-gamepad/universalTouchGamepad.js ../${DEV_MODE}/src/
     nodemon --watch ../universal-touch-gamepad/universalTouchGamepad.js --exec "cp ../universal-touch-gamepad/universalTouchGamepad.js ../${DEV_MODE}/src/" &  
    # Copy themes
     cp -a nginx ../${DEV_MODE}/
    # Run passed frontend
    cd $HOME/src/addons/${DEV_MODE}
     npm install
     npm run serve &
  fi
  # Run backend
  cd $HOME/src/src
   \
    nodemon -V --ext py --exec \
      "python3" -m selkies \
      --addr="localhost" \
      --mode="websockets" \
      --debug="true"
fi

# Start Selkies
exec  \
  selkies \
    --addr="localhost" \
    --mode="websockets"




if [[ ${RESTART_APP,,} != "true" ]]; then
  exec sleep infinity
fi

# monitor loop for autostart
AUTOSTART_CMD="sh $HOME/.config/openbox/autostart"
while true; do
  if pgrep -o -u apps -f "$AUTOSTART_CMD" > /dev/null; then
    echo "SVC Watchdog: Initial process detected. Starting active monitoring."
    break
  fi
  sleep 2
done
last_known_pid=""
while true; do
  current_pid=$(pgrep -o -u apps -f "$AUTOSTART_CMD")
  if [ -z "$current_pid" ]; then
    if [ -n "$last_known_pid" ]; then
      echo "SVC Watchdog: Application process (PID: $last_known_pid) has terminated. Restarting..."
    else
      echo "SVC Watchdog: Application not running. Attempting to start..."
    fi
     $AUTOSTART_CMD &
    last_known_pid=""
  elif [ "$current_pid" != "$last_known_pid" ]; then
    echo "SVC Watchdog: Application process found with PID: $current_pid. Monitoring..."
    last_known_pid="$current_pid"
  fi
  sleep 1
done




# Enable DRI3 support if detected
VFBCOMMAND=""
if ! which nvidia-smi && [ -e "/dev/dri/renderD128" ]; then
  VFBCOMMAND="-vfbdevice /dev/dri/renderD128"
fi
if [ ! -z ${DRINODE+x} ]; then
  VFBCOMMAND="-vfbdevice ${DRINODE}"
fi
if [ "${DISABLE_DRI3}" != "false" ]; then
  VFBCOMMAND=""
fi
DEFAULT_RES="15360x8640"
if [ ! -z ${MAX_RES+x} ]; then
  DEFAULT_RES="${MAX_RES}"
fi

# Run Xvfb server with required extensions
exec  \
  /usr/bin/Xvfb \
    "${DISPLAY}" \
    -screen 0 "${DEFAULT_RES}x24" \
    -dpi "96" \
    +extension "COMPOSITE" \
    +extension "DAMAGE" \
    +extension "GLX" \
    +extension "RANDR" \
    +extension "RENDER" \
    +extension "MIT-SHM" \
    +extension "XFIXES" \
    +extension "XTEST" \
    +iglx \
    +render \
    -nolisten "tcp" \
    -ac \
    -noreset \
    -shmem \
    ${VFBCOMMAND}




# bail early on xfce based systems
if which xfce4-session > /dev/null 2>&1; then
  sleep infinity
fi

# create default xsettings
if [ ! -f "${HOME}/.xsettingsd" ]; then
  echo "Xft/DPI 98304" > "${HOME}/.xsettingsd"
fi
chown apps:apps "${HOME}/.xsettingsd"

# run
exec  \
  xsettingsd

