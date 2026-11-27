target "docker-metadata-action" {}

variable "APP" {
  default = "deconz"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=dresden-elektronik/deconz-rest-plugin versioning=semver
  default = "2.33.2"
}

// UNVERIFIED: BSD-3-Clause is the REST plugin license; the vendor .deb license is not confirmed. Confirm before merge.
variable "LICENSE" {
  default = "BSD-3-Clause"
}

variable "SOURCE" {
  default = "https://github.com/dresden-elektronik/deconz-rest-plugin"
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
