target "docker-metadata-action" {}

variable "APP" {
  default = "pvk-ii"
}

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd
  // The game has no upstream version. This tracks the steamcmd base image.
  default = "20180105-5build1"
}

variable "LICENSE" {
  // UNVERIFIED: the game content is proprietary Steam content. The wrapper follows the base steamcmd licence.
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/17575"
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
