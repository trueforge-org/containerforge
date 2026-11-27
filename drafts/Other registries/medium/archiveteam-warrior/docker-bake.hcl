target "docker-metadata-action" {}

variable "APP" {
  default = "archiveteam-warrior"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/ArchiveTeam/warrior-code2 currentValue=master
  default = "cc602d48fe38ddb9322965ccb813158ab0a80c79"
}

variable "LICENSE" {
  default = "Unlicense"
}

variable "SOURCE" {
  default = "https://github.com/ArchiveTeam/warrior-code2"
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
