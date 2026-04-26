target "docker-metadata-action" {}

variable "APP" {
  default = "whisparr-eros"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Whisparr/whisparr-eros versioning=loose extractVersion=^v(?<version>.+-release\..+)$
  default = "3.3.3-release.683"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/Whisparr/whisparr-eros"
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
