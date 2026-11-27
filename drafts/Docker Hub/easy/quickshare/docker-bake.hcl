target "docker-metadata-action" {}

variable "APP" {
  default = "quickshare"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ihexxa/quickshare
  default = "0.11.4"
}

variable "SHA256_AMD64" {
  // UNVERIFIED against a published checksum file: GitHub release asset digest. Bump with VERSION.
  default = "36256309c20e5494bafc499f5b9288c41c3d12ac63c4ffced25aae6754ae4ce0"
}

variable "SHA256_ARM64" {
  // UNVERIFIED against a published checksum file: GitHub release asset digest. Bump with VERSION.
  default = "b8434a01bba52feeed64d462a1d2ce110aa36aa7b020376ad0df37718230e7e7"
}

variable "LICENSE" {
  default = "LGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/ihexxa/quickshare"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SHA256_AMD64 = "${SHA256_AMD64}"
    SHA256_ARM64 = "${SHA256_ARM64}"
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
