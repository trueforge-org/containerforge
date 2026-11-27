target "docker-metadata-action" {}

variable "APP" {
  default = "jdownloader2"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=jlesage/docker-jdownloader-2 versioning=loose
  default = "v26.09.1"
}

variable "LICENSE" {
  // UNVERIFIED: JDownloader's license is not confirmed. The MIT license of the upstream wrapper does not cover it. Resolve before merging.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://jdownloader.org/"
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
