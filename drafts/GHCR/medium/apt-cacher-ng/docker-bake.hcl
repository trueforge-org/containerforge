target "docker-metadata-action" {}

variable "APP" {
  default = "apt-cacher-ng"
}

variable "VERSION" {
  // NOTE: Ubuntu version is tied to the version of the base image in the Dockerfile (valkey pattern, no renovate datasource).
  // TODO: repology is disabled for now. Re-enable when it works: repologyDepName=ubuntu_26_04/apt-cacher-ng versioning=loose
  default = "3.7.5"
}

variable "PACKAGE_VERSION" {
  // UNVERIFIED: taken from packages.ubuntu.com for resolute. Confirm the exact pocket and string at build time.
  default = "3.7.5-1.1"
}

variable "LICENSE" {
  // UNVERIFIED: confirm from /usr/share/doc/apt-cacher-ng/copyright once the package is installed.
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://www.unix-ag.uni-kl.de/~bloch/acng/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
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
