target "docker-metadata-action" {}

variable "APP" {
  default = "shelfmark"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=calibrain/shelfmark versioning=semver
  // UNVERIFIED: chart appVersion is 1.7.2; confirm the target release before merging
  default = "v1.7.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/calibrain/shelfmark"
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
