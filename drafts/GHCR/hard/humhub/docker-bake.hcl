target "docker-metadata-action" {}

variable "APP" {
  default = "humhub"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=humhub/humhub versioning=semver
  default = "1.19.5"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports NOASSERTION; the project is described as AGPL-3.0. Confirm against the LICENSE file.
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/humhub/humhub"
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
