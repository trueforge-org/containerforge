target "docker-metadata-action" {}

variable "APP" {
  default = "vocechat-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Privoce/vocechat-server-rust versioning=semver
  default = "0.5.41"
}

// UNVERIFIED: digests from the plan. Bump them together with VERSION. Renovate does not update them.
variable "SHA256_AMD64" {
  default = "a5ec5106a2eb2433aed60777cd2a53b23236f28974d16264161c00e28845e049"
}

variable "SHA256_ARM64" {
  default = "04f51c9656f0c040892c73562ef63794752e7d0fa610683052e10a0b3e4e73ac"
}

// UNVERIFIED: upstream publishes no SPDX id (Big Time Public License). Confirm before merging.
variable "LICENSE" {
  default = "LicenseRef-Big-Time-Public-License"
}

variable "SOURCE" {
  default = "https://github.com/Privoce/vocechat-server-rust"
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
