target "docker-metadata-action" {}

variable "APP" {
  default = "mediagoblin"
}

variable "VERSION" {
  // renovate: datasource=git-tags depName=mediagoblin packageName=https://git.sr.ht/~mediagoblin/mediagoblin extractVersion=^v(?<version>\d+\.\d+\.\d+)$ versioning=semver
  // UNVERIFIED: Renovate can list sr.ht tags. Release candidates are excluded by the regex.
  default = "0.15.0"
}

variable "SRC_SHA256" {
  // sha256 of https://git.sr.ht/~mediagoblin/mediagoblin/archive/v0.15.0.tar.gz, fetched 2026-11-26.
  // UNVERIFIED: sr.ht archives are byte-stable over time. Bump together with VERSION.
  default = "8290079a9f0010bebb45c5e303e99dd153ba416c4178e18a9eb2abcd106f3549"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://git.sr.ht/~mediagoblin/mediagoblin"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SRC_SHA256 = "${SRC_SHA256}"
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
