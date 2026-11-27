target "docker-metadata-action" {}

variable "APP" {
  default = "webp-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=webp-sh/webp_server_go versioning=loose
  default = "0.16.2"
}

variable "LICENSE" {
  // UNVERIFIED: GPL-3.0-only vs GPL-3.0-or-later. Check the source headers.
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/webp-sh/webp_server_go"
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
