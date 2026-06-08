target "docker-metadata-action" {}

variable "APP" {
  default = "deluge"
}

variable "VERSION" {
  // TODO: temporary disabled due to repology networking issues (it being in russia)
  // renovatex: datasource=repology depName=alpine_edge/deluge
  default = "2.2.0"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/deluge-torrent/deluge"
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
    "linux/amd64",
  ]
}
