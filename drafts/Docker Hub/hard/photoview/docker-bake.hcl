target "docker-metadata-action" {}

variable "APP" {
  default = "photoview"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=photoview/photoview versioning=semver
  default = "2.4.0"
}

variable "LICENSE" {
  // UNVERIFIED: AGPL-3.0-only is stated from memory; the LICENSE fetch returned 404 at planning time.
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/photoview/photoview/"
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
