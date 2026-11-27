target "docker-metadata-action" {}

variable "APP" {
  default = "mosdns"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=IrineSistiana/mosdns versioning=semver
  default = "5.3.4"
}

variable "LICENSE" {
  default = "GPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/IrineSistiana/mosdns"
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
