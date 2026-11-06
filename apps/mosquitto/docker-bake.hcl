target "docker-metadata-action" {}

variable "APP" {
  default = "mosquitto"
}

variable "VERSION" {
  // NOTE: Ubuntu version is tied to the version of the base image in the Dockerfile
  // renovate: datasource=repology depName=ubuntu_26_04/mosquitto versioning=loose
  default = "2.0.22"
}

variable "PACKAGE_VERSION" {
  default = "2.0.22-5build1"
}

variable "LICENSE" {
  default = "EPL-2.0 OR EDL-1.0"
}

variable "SOURCE" {
  default = "https://github.com/eclipse-mosquitto/mosquitto"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
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
