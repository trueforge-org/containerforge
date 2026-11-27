target "docker-metadata-action" {}

variable "APP" {
  default = "haste-server"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/nzzane/haste-server currentValue=master
  default = "8c45a370a79cc5caaf446ba0088574dfcb489694"
}

variable "LICENSE" {
  // UNVERIFIED: the repo page reports MIT, but package.json has no license field. Confirm before merge.
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/nzzane/haste-server"
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
