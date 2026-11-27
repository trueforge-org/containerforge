target "docker-metadata-action" {}

variable "APP" {
  default = "joplin-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=laurent22/joplin versioning=semver
  // Pinned to 3.7.6 to match the chart and Docker Hub; upstream latest is 3.7.24 (separate bump).
  default = "3.7.6"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/laurent22/joplin"
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
