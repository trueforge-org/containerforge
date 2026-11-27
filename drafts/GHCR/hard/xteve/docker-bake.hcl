target "docker-metadata-action" {}

variable "APP" {
  default = "xteve"
}

variable "VERSION" {
  // UNVERIFIED renovate: xteve-project/xTeVe-Downloads has no GitHub releases or tags, so a github-releases annotation cannot track it.
  // Version source is info.json (2.2.0.0200); a custom renovate datasource is needed.
  default = "2.2.0.200"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/xteve-project/xTeVe"
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
