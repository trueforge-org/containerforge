target "docker-metadata-action" {}

variable "APP" {
  default = "apache-webdav"
}

variable "VERSION" {
  // NOTE: Ubuntu version is tied to the version of the base image in the Dockerfile.
  // No renovate rule: a github-tags rule on apache/httpd would pick releases Ubuntu does not package.
  default = "2.4.66"
}

variable "PACKAGE_VERSION" {
  // NOTE: Ubuntu 26.04 package revision, bumped by hand together with VERSION.
  default = "2.4.66-2ubuntu2.7"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/apache/httpd"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
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
