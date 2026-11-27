target "docker-metadata-action" {}

variable "APP" {
  default = "monero-node"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=monero-project/monero versioning=loose
  default = "0.18.5.4"
}

// UNVERIFIED: computed locally, not yet checked against the signed hashes.txt at getmonero.org. Do not merge until confirmed.
variable "MONERO_SHA256_AMD64" {
  default = "ba2928962c101b609434bf8c1b43ad59ebe96c5525977284ca599d8bf0f02d10"
}

// UNVERIFIED: computed locally, not yet checked against the signed hashes.txt at getmonero.org. Do not merge until confirmed.
variable "MONERO_SHA256_ARM64" {
  default = "d20d71e6522b41eb8e549c3425f7f4622c9c9a448fc7147525393fd0a6b59703"
}

variable "LICENSE" {
  default = "BSD-3-Clause"
}

variable "SOURCE" {
  default = "https://github.com/monero-project/monero"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    MONERO_SHA256_AMD64 = "${MONERO_SHA256_AMD64}"
    MONERO_SHA256_ARM64 = "${MONERO_SHA256_ARM64}"
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
