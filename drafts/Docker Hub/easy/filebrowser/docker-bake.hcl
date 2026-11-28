target "docker-metadata-action" {}

variable "APP" {
  default = "filebrowser"
}

variable "VERSION" {
  // Upstream is archived (2026-09-01) and gets no further releases; Renovate will not find updates.
  // renovate: datasource=github-releases depName=filebrowser/filebrowser extractVersion=^v(?<version>.+)$ versioning=semver
  default = "2.63.23"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/filebrowser/filebrowser"
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
