target "docker-metadata-action" {}

variable "APP" {
  default = "mongo-express"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=mongo-express/mongo-express versioning=loose
  // Loose versioning: the only release is a release candidate (-rc-4), which is not strict semver.
  default = "1.1.0-rc-4"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/mongo-express/mongo-express"
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
