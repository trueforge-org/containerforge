target "docker-metadata-action" {}

variable "APP" {
  default = "grafana"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=grafana/grafana versioning=semver
  default = "13.3.2"
}

variable "BUILD" {
  // UNVERIFIED: build number is part of the .deb file name. Update together with VERSION.
  default = "44555861735"
}

variable "LICENSE" {
  // AGPL-3.0 for the OSS build (LICENSE on main). Confirm -only or -or-later against the LICENSE text.
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/grafana/grafana"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    BUILD = "${BUILD}"
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
