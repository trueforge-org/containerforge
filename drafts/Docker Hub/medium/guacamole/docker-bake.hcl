target "docker-metadata-action" {}

variable "APP" {
  default = "guacamole"
}

variable "VERSION" {
  // renovate: datasource=docker depName=guacamole/guacamole versioning=semver
  default = "1.6.0"
}

// sha256 of guacamole-${VERSION}.war from https://dlcdn.apache.org/guacamole/1.6.0/binary/guacamole-1.6.0.war.sha256
// Bump together with VERSION.
variable "GUACAMOLE_SHA256" {
  default = "b41ceb1e2df010b54db563e0b00edb8d5fe9f073c6168462e4c978df0fc6e716"
}

// UNVERIFIED: Apache-2.0 is expected for apache/guacamole-client. Confirm from the LICENSE file.
variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/apache/guacamole-client"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    GUACAMOLE_SHA256 = "${GUACAMOLE_SHA256}"
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
