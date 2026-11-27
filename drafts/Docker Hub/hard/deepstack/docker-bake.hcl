target "docker-metadata-action" {}

variable "APP" {
  default = "deepstack"
}

// UNVERIFIED: renovate docker datasource with the cpu- tag prefix may need an extractVersion.
variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/deepquestai/deepstack versioning=loose
  default = "2022.01.1"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/johnolafenwa/DeepStack"
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

// amd64 only: the cpu-2022.01.1 base image is amd64 only.
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64"
  ]
}
