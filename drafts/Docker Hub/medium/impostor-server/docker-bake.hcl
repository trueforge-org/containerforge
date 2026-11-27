target "docker-metadata-action" {}

variable "APP" {
  default = "impostor-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=AeonLucid/Impostor versioning=semver
  default = "1.10.10"
}

variable "LICENSE" {
  // UNVERIFIED: -only or -or-later; check the LICENSE header.
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/AeonLucid/Impostor"
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
