target "docker-metadata-action" {}

variable "APP" {
  default = "rustpad"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/ekzhang/rustpad currentValue=main
  default = "54e4a9383c84d7317af42a7ddb177ce8bcba058d"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/ekzhang/rustpad"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    GITHUB_SHA = "${VERSION}"
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
