target "docker-metadata-action" {}

variable "APP" {
  default = "photoprism"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=photoprism/photoprism versioning=loose
  default = "261029-963b58c50"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports NOASSERTION; Docker Hub description says AGPL-3.0. Confirm against the repo LICENSE file.
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/photoprism/photoprism"
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
