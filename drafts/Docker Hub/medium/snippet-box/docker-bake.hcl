target "docker-metadata-action" {}

variable "APP" {
  default = "snippet-box"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/pawelmalak/snippet-box currentValue=master
  default = "f501941a22ead0fccd196d109098e9b065205d98"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/pawelmalak/snippet-box"
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
