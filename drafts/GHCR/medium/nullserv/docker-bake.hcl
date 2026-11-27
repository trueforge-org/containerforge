target "docker-metadata-action" {}

variable "APP" {
  default = "nullserv"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/bmrzycki/nullserv currentValue=master
  default = "ed88d9708f99f4e6368eec89a31f9410db1055fb"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/bmrzycki/nullserv"
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
