target "docker-metadata-action" {}

variable "APP" {
  default = "mattermost"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=mattermost/mattermost versioning=semver
  // UNVERIFIED: renovate config not checked; upstream tags may not be plain semver
  default = "12.1.0"
}

variable "LICENSE" {
  // BLOCKED: GitHub reports NOASSERTION; set the confirmed SPDX value of the tarball edition before merge
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/mattermost/mattermost"
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
