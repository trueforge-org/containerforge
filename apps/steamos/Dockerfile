FROM docker.io/library/archlinux:latest

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# title
ENV TITLE=SteamOS \
    HOME=/config \
    XDG_CONFIG_HOME=/config

# Create group and user "apps" with UID and GID 568 (matching repository conventions)
RUN groupadd -g 568 apps && \
    useradd -m -u 568 -g 568 -s /bin/bash apps && \
    mkdir -p /config /app /tmp && \
    chown -R apps:apps /config /app

# Install base-devel for AUR builds and sudo
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm --needed \
      base-devel \
      git \
      sudo \
      tigervnc && \
    echo 'apps ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    ln -s /usr/bin/Xvnc /usr/local/bin/Xvnc

# Install multilib packages
RUN echo "**** install vanilla 32 bit packages from multilib ****" && \
  echo '[multilib]' >> /etc/pacman.conf && \
  echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf && \
  pacman -Sy --noconfirm --needed \
    lib32-glibc \
    lib32-libva-intel-driver \
    lib32-libva-mesa-driver \
    lib32-libvdpau \
    lib32-mesa-utils \
    lib32-mesa \
    lib32-vulkan-intel \
    lib32-vulkan-mesa-layers \
    lib32-vulkan-radeon \
    lib32-vulkan-swrast \
    libva-intel-driver \
    libva-utils \
    vulkan-swrast || echo "Some optional lib32 packages were not found, continuing..."

# Add steam repos and install SteamOS packages
RUN echo "**** add steam repos ****" && \
  echo '[jupiter-staging]' >> /etc/pacman.conf && \
  echo 'Server = https://steamdeck-packages.steamos.cloud/archlinux-mirror/$repo/os/$arch' >> /etc/pacman.conf && \
  echo 'SigLevel = Never' >> /etc/pacman.conf && \
  echo '[holo-staging]' >> /etc/pacman.conf && \
  echo 'Server = https://steamdeck-packages.steamos.cloud/archlinux-mirror/$repo/os/$arch' >> /etc/pacman.conf && \
  echo 'SigLevel = Never' >> /etc/pacman.conf && \
  pacman -Syyu --noconfirm

# Install main packages
RUN echo "**** install packages ****" && \
  pacman -Sy --noconfirm --needed \
    boost-libs \
    dmidecode \
    dolphin \
    firefox \
    fuse2 \
    gperftools \
    kate \
    konsole \
    lib32-gcc-libs \
    lib32-libpulse \
    lib32-libunwind \
    lib32-mesa \
    noto-fonts-cjk \
    plasma-desktop \
    sddm \
    xdg-user-dirs \
    xorg-xwayland \
    zenity || echo "Some optional packages were not found, continuing..."

# Install SteamOS-specific packages (may fail if repos are unavailable)
RUN echo "**** install SteamOS-specific packages ****" && \
  pacman -Sy --noconfirm --needed \
    gamescope \
    lib32-gamescope \
    lib32-opencl-mesa \
    mangohud \
    lib32-mangohud \
    steamdeck-kde-presets \
    steam-jupiter-stable \
    steamos-customizations \
    lib32-renderdoc-minimal || echo "SteamOS-specific packages not available, continuing..."

# Install sunshine from AUR
RUN echo "**** install sunshine ****" && \
  cd /tmp && \
  git clone https://aur.archlinux.org/sunshine.git && \
  chown -R apps:apps sunshine && \
  cd sunshine && \
  sed -i '/CXXFLAGS/i sudo chown -R 568:568 \/config' PKGBUILD && \
  sudo -u apps makepkg -sAci --skipinteg --noconfirm --needed && \
  usermod -aG input apps

# Install fix for games using source engine
RUN echo "**** install fix for games using source engine ****" && \
  cd /tmp && \
  git clone https://aur.archlinux.org/lib32-gperftools.git && \
  chown -R apps:apps lib32-gperftools && \
  cd lib32-gperftools && \
  sudo -u apps makepkg -sAci --skipinteg --noconfirm --needed && \
  usermod -aG input apps

# Steam and KDE tweaks
RUN echo "**** steam tweaks ****" && \
  if [ -f /usr/bin/steam ]; then sed -i 's/-steamdeck//g' /usr/bin/steam; fi && \
  echo "**** kde tweaks ****" && \
  if [ -f /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml ]; then \
    sed -i \
      -e 's/applications:org.kde.discover.desktop,/applications:org.kde.konsole.desktop,/g' \
      -e 's#preferred://browser#applications:firefox.desktop#g' \
      /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml; \
  fi

# Cleanup
RUN echo "**** cleanup ****" && \
  rm -rf \
    /config/.cache \
    /config/.npm \
    /tmp/* \
    /var/cache/pacman/pkg/* \
    /var/lib/pacman/sync/*

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 3000

VOLUME /config

WORKDIR /config
