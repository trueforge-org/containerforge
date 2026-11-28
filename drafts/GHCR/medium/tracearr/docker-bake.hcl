target "docker-metadata-action" {}

variable "APP" {
  default = "tracearr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=connorgallopo/Tracearr versioning=semver
  default = "3.3.0"
}

variable "LICENSE" {
  // upstream Dockerfile LABEL says AGPL-3.0. UNVERIFIED whether the LICENSE file says -only or -or-later.
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/connorgallopo/Tracearr"
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
