target "docker-metadata-action" {}

variable "APP" {
  default = "plex-utills"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=jkirkcaldy/plex-utills versioning=loose
  default = "23.02.02"
}

// Upstream commit that the image is built from (master at the 23.02.02 version file).
variable "COMMIT" {
  default = "e945c0cb113b8ec3bb0b0f15c544f600e6e16d3f"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/jkirkcaldy/plex-utills"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    COMMIT = "${COMMIT}"
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
