target "docker-metadata-action" {}

variable "APP" {
  default = "plex-playlist-sync"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=rnagabhyrava/plex-playlist-sync extractVersion=^v(?<version>.+)$ versioning=semver
  default = "1.0.2"
}

variable "LICENSE" {
  // UNVERIFIED: the GitHub API reports GPL-3.0; the LICENSE.md file does not state "or later".
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/rnagabhyrava/plex-playlist-sync"
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
