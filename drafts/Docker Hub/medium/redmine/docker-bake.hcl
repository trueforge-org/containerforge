target "docker-metadata-action" {}

variable "APP" {
  default = "redmine"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=redmine/redmine versioning=semver
  // Tag naming on the GitHub mirror is UNVERIFIED. If tags do not match, use a custom regex datasource on https://www.redmine.org/releases/.
  default = "6.1.6"
}

variable "LICENSE" {
  // LICENSE.txt says version 2 (plan section 1). Confirm at the 6.1.6 tag.
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/redmine/redmine"
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
