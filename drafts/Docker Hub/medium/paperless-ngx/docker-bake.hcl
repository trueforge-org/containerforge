target "docker-metadata-action" {}

variable "APP" {
  default = "tika"
}

// UNVERIFIED: the renovate datasource below is proposed. There is no GitHub release for Apache Tika.
// Confirm that renovate's maven manager picks up org.apache.tika:tika-server-standard before merge.
variable "VERSION" {
  // renovate: datasource=maven depName=org.apache.tika:tika-server-standard versioning=maven
  default = "3.4.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/apache/tika"
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
