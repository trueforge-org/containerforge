target "docker-metadata-action" {}

variable "APP" {
  default = "redisinsight"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=redis/RedisInsight versioning=semver
  default = "3.10.2"
}

variable "LICENSE" {
  default = "SSPL-1.0"
}

variable "SOURCE" {
  default = "https://github.com/redis/RedisInsight"
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
