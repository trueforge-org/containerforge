target "docker-metadata-action" {}

variable "APP" {
  default = "fileflows"
}

variable "VERSION" {
  // renovate: datasource=docker depName=revenz/fileflows versioning=loose
  // UNVERIFIED: restrict to stable tags (e.g. allowedVersions=/^[0-9]+\.[0-9]+$/) in the renovate config
  default = "26.11"
}

variable "FILEFLOWS_SHA256" {
  // bump together with VERSION: the vendor download URL is not versioned
  default = "44d76c2da29d6705b35953a46109deaca74d615b036deea1afdc5ad898134f42"
}

variable "LICENSE" {
  // UNVERIFIED: proprietary, redistribution rights not confirmed. Do not publish before the user confirms.
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://fileflows.com/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    FILEFLOWS_SHA256 = "${FILEFLOWS_SHA256}"
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
