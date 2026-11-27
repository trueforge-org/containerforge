target "docker-metadata-action" {}

variable "APP" {
  default = "fireflyiii"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=firefly-iii/firefly-iii versioning=semver
  default = "6.7.9"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub API reports AGPL-3.0. Confirm "only" versus "or later" before the PR.
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/firefly-iii/firefly-iii"
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
