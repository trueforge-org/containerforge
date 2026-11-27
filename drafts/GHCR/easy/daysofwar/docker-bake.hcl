target "docker-metadata-action" {}

variable "APP" {
  default = "daysofwar"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  // The game is downloaded at start, so no game version is pinned here.
  default = "20180105-5build1"
}

variable "LICENSE" {
  // UNVERIFIED: game server license. Set to the confirmed license before merge.
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  // UNVERIFIED: store app page, not fetched yet
  default = "https://store.steampowered.com/app/541790"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  // amd64 only: the SteamCMD bootstrap is x86 (linux32) only
  platforms = [
    "linux/amd64"
  ]
}
