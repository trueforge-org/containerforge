target "docker-metadata-action" {}

variable "APP" {
  default = "game-server-watcher"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=a-sync/game-server-watcher versioning=semver
  default = "3.1.26"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/a-sync/game-server-watcher"
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
