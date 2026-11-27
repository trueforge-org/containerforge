target "docker-metadata-action" {}

variable "APP" {
  default = "phoronix-test-suite"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=phoronix-test-suite/phoronix-test-suite versioning=semver
  default = "10.8.4"
}

variable "LICENSE" {
  // UNVERIFIED: the GitHub API reports GPL-3.0. Confirm "or later" against the source headers before the PR.
  default = "GPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/phoronix-test-suite/phoronix-test-suite/"
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
