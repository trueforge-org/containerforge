target "docker-metadata-action" {}

variable "APP" {
  default = "website-shot"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Flowko/website-shot versioning=semver
  // Upstream repo is archived (2024-03-10), so renovate will not find newer releases.
  default = "0.10.2"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports AGPL-3.0; confirm the exact clause against the LICENSE header.
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/Flowko/website-shot/"
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
