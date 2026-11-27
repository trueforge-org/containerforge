target "docker-metadata-action" {}

variable "APP" {
  default = "halflife2deathmatch"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  // Tracks the steamcmd base image (apps/steamcmd). No game version is pinned: SteamCMD serves the latest build.
  default = "20180105-5build1"
}

variable "LICENSE" {
  // UNVERIFIED: Valve proprietary software. Confirm the license value before this file is committed.
  default = "LicenseRef-Valve-Proprietary"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/320/"
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
  platforms = [
    "linux/amd64"
  ]
}
