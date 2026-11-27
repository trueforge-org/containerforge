target "docker-metadata-action" {}

variable "APP" {
  default = "docker-hub-rss"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/TheConnMan/docker-hub-rss currentValue=master
  // UNVERIFIED: this commit is the master HEAD from the plan; the commit behind the chart digest is not confirmed
  default = "23c6d2db08ac4fb44f7204cadd56faa24bf5b51a"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/TheConnMan/docker-hub-rss"
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
