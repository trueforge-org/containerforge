target "docker-metadata-action" {}

variable "APP" {
  default = "metatube"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/JVT038/MetaTube currentValue=master
  // UNVERIFIED: short SHA of master at the time of the plan. Replace with the full 40-character SHA.
  default = "879a385"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/JVT038/MetaTube"
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
