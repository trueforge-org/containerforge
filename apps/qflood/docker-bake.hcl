target "docker-metadata-action" {}

variable "APP" {
  default = "qflood"
}

variable "VERSION" {
  // renovate: datasource=custom.qbittorrent depName=qbittorrent
  default = "5.3.0"
}

variable "FLOOD_VERSION" {
  // renovate: datasource=github-releases depName=jesec/flood
  default = "4.16.4"
}

variable "LICENSE" {
  default = "GPL-2.0-or-later AND GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/qbittorrent/qBittorrent"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    FLOOD_VERSION = "${FLOOD_VERSION}"
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
    "linux/amd64",
    "linux/arm64"
  ]
}
