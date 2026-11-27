target "docker-metadata-action" {}

variable "APP" {
  default = "calendarr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=jordanlambrecht/calendarr versioning=semver
  // UNVERIFIED: renovate may need a tag-prefix setting for the "v" tags
  default = "1.5.2"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/jordanlambrecht/calendarr"
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
