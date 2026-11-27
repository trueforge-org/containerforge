target "docker-metadata-action" {}

variable "APP" {
  default = "rstudio"
}

// Tag-safe form of the RStudio build version (2026.11.0+203 is not a valid image tag).
// UNVERIFIED: renovate datasource; the build suffix makes the version loose, not strict semver.
variable "VERSION" {
  // renovate: datasource=github-releases depName=rstudio/rstudio versioning=loose
  default = "2026.11.0-203"
}

// UNVERIFIED: confirm the SPDX id (only/or-later) against the upstream COPYING file.
variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/rstudio/rstudio"
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
