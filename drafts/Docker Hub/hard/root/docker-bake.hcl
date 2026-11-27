target "docker-metadata-action" {}

variable "APP" {
  default = "root"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=root-project/root versioning=regex:^v(?<major>\d+)-(?<minor>\d+)-(?<patch>\d+)$
  default = "v6-40-04"
}

// UNVERIFIED: sha256 of root_v6.40.04.Linux-ubuntu26.04-x86_64-gcc15.2.tar.gz.
// Take it from the GitHub release asset "digest" field. Renovate does not update it, so a version bump needs a new digest.
variable "ROOT_SHA256" {
  default = ""
}

variable "LICENSE" {
  default = "LGPL-2.1-or-later"
}

variable "SOURCE" {
  default = "https://github.com/root-project/root"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    ROOT_SHA256 = "${ROOT_SHA256}"
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

// amd64 only: upstream publishes no linux/arm64 Linux binary
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64"
  ]
}
