target "docker-metadata-action" {}

variable "APP" {
  default = "garrysmod"
}

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd versioning=loose
  // No game version exists to pin: the server is installed by SteamCMD at start.
  default = "20180105-5build1"
}

variable "LICENSE" {
  // UNVERIFIED: the game is proprietary Valve software. This is the base image license.
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  // UNVERIFIED: store app page for app 4020, not confirmed as the dedicated server app
  default = "https://store.steampowered.com/app/4020/"
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
