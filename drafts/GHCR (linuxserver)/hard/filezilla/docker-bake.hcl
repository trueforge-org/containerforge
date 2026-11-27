target "docker-metadata-action" {}

variable "APP" {
  default = "filezilla"
}

variable "VERSION" {
  // UNVERIFIED: no renovate datasource yet for an Ubuntu archive pin; must match the apt pin in the Dockerfile (3.69.6-1)
  default = "3.69.6"
}

variable "LICENSE" {
  default = "GPL-2.0-or-later" // UNVERIFIED: confirm from the package copyright file before merge
}

variable "SOURCE" {
  default = "https://filezilla-project.org"
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

// UNVERIFIED: arm64 is listed by Ubuntu for the package, but not built or run yet
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
