target "docker-metadata-action" {}

variable "APP" {
  default = "mongosh"
}

variable "VERSION" {
  // renovate: datasource=npm depName=mongosh
  default = "1.2.0"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}


variable "SOURCE" {
  default = "https://truecharts.org"
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
    "linux/arm64"
  ]
}
