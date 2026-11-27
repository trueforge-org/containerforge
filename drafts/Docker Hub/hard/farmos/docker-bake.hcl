target "docker-metadata-action" {}

variable "APP" {
  default = "farmos"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=farmOS/farmOS versioning=semver
  // Tracks the 3.x line on purpose. Docker Hub latest and upstream main are 4.x (Drupal 11), which is not built here.
  default = "3.5.11"
}

// UNVERIFIED: plain GPL-2.0 as reported by GitHub. Confirm -only or -or-later against the LICENSE.txt header.
variable "LICENSE" {
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/farmOS/farmOS"
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
