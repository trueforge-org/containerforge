target "docker-metadata-action" {}

variable "APP" {
  default = "docuseal"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=docusealco/docuseal versioning=semver
  default = "3.4.0"
}

// UNVERIFIED: README says "AGPLv3 License with Section 7(b) Additional Terms" (LICENSE_ADDITIONAL_TERMS). Confirm the SPDX expression at review.
variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/docusealco/docuseal"
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
