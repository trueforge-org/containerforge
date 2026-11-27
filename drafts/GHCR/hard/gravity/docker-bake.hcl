target "docker-metadata-action" {}

variable "APP" {
  default = "gravity"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=BeryJu/gravity versioning=semver
  default = "v0.34.0"
}

// UNVERIFIED: GPL-3.0-only vs GPL-3.0-or-later (plan section 1).
variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/BeryJu/gravity"
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
