target "docker-metadata-action" {}

variable "APP" {
  default = "zilean"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=iPromKnight/zilean versioning=semver
  default = "3.5.0"
}

variable "LICENSE" {
  // UNVERIFIED: the upstream repository has no LICENSE file and the GitHub API reports none. Placeholder until the maintainer answers.
  default = "LicenseRef-Unknown"
}

variable "SOURCE" {
  default = "https://github.com/iPromKnight/zilean/"
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
