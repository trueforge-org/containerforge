target "docker-metadata-action" {}

variable "APP" {
  default = "dropbox-by-otherguy"
}

variable "VERSION" {
  // UNVERIFIED: the Dropbox daemon has no version pin. This is a date placeholder for the image tag.
  // No renovate datasource is set because no versioned upstream release exists (ask maintainers).
  default = "2026-11-23"
}

variable "LICENSE" {
  // UNVERIFIED: no SPDX id for the proprietary Dropbox daemon. The image ships only our scripts.
  default = "LicenseRef-Dropbox-Proprietary"
}

variable "SOURCE" {
  default = "https://www.dropbox.com/install"
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
  // The Dropbox Linux daemon is only downloaded for x86_64, so no arm64 build.
  platforms = [
    "linux/amd64"
  ]
}
