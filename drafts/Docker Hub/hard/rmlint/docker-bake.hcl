target "docker-metadata-action" {}

variable "APP" {
  default = "rmlint"
}

variable "VERSION" {
  // NOTE: tied to the apt package of the ubuntu base image (PACKAGE_VERSION in the Dockerfile).
  // Upstream is 2.11.0 but apt ships 2.10.2, so the renovate github-releases line is disabled here.
  // renovate (disabled): datasource=github-releases depName=sahib/rmlint versioning=semver
  default = "2.10.2"
}

variable "PACKAGE_VERSION" {
  default = "2.10.2-0.2ubuntu1"
}

variable "LICENSE" {
  // UNVERIFIED: -only or -or-later, not read from the file headers
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/sahib/rmlint"
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
