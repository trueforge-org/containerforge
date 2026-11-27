target "docker-metadata-action" {}

variable "APP" {
  default = "radarrsync"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/dairefinn/RadarrSync versioning=loose
  default = "7546e59b7c6ca50f42460e919ebd86eb254a2c57"
}

// sha256 of the GitHub archive for VERSION (computed, GitHub publishes no archive checksum).
variable "SHA256" {
  default = "c156d253d0b4b89d5a60ae42f1b094f1f2a101835c0557f44502001f32127d97"
}

// UNVERIFIED: the upstream fork has no license. NOASSERTION until the maintainer confirms one.
variable "LICENSE" {
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/dairefinn/RadarrSync"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SHA256 = "${SHA256}"
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
