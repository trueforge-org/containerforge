target "docker-metadata-action" {}

variable "APP" {
  default = "twtxt"
}

variable "VERSION" {
  // renovate: datasource=git-tags depName=https://git.mills.io/prologic/twtxt versioning=loose
  // UNVERIFIED: 0.1.1 is the TrueCharts appVersion, not a checked upstream tag. Confirm before the first build.
  default = "0.1.1"
}

// UNVERIFIED: sha256 of the source tarball for VERSION. Fill in once the archive URL is confirmed.
variable "CHECKSUM" {
  default = ""
}

variable "LICENSE" {
  // UNVERIFIED: confirm against the LICENSE file in the tag
  default = "MIT"
}

variable "SOURCE" {
  default = "https://git.mills.io/prologic/twtxt"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    CHECKSUM = "${CHECKSUM}"
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
