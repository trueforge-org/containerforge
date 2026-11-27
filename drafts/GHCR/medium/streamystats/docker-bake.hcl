target "docker-metadata-action" {}

variable "APP" {
  default = "streamystats"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=fredrikburmester/streamystats versioning=semver
  default = "v2.22.3"
}

variable "LICENSE" {
  // UNVERIFIED: repo license is null and there is no root LICENSE; package.json reports MIT for one of the apps
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/fredrikburmester/streamystats"
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
