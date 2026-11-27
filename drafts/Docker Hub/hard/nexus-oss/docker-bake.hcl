target "docker-metadata-action" {}

variable "APP" {
  default = "nexus-oss"
}

variable "VERSION" {
  // renovate: datasource=docker depName=sonatype/nexus3 versioning=loose
  default = "3.98.3"
}

// Sonatype build suffix of the download archive (3.98.3-01). Not in the Docker tag, so renovate does not track it.
variable "BUILD" {
  default = "01"
}

variable "LICENSE" {
  default = "EPL-1.0"
}

variable "SOURCE" {
  default = "https://github.com/sonatype/nexus-public"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    BUILD = "${BUILD}"
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
