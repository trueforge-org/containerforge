target "docker-metadata-action" {}

variable "APP" {
  default = "calibre"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=kovidgoyal/calibre versioning=loose
  default = "9.19.0"
}

variable "LICENSE" {
  // UNVERIFIED in this fetch: taken from the GitHub API in the plan
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/kovidgoyal/calibre"
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
