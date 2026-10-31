target "docker-metadata-action" {}

variable "APP" {
  default = "netshoot"
}

variable "VERSION" {
  default = "1.0.0"
}

variable "GRPCURL_VERSION" {
  // renovate: datasource=github-releases depName=fullstorydev/grpcurl
  default = "1.9.4"
}

variable "FORTIO_VERSION" {
  // renovate: datasource=github-releases depName=fortio/fortio
  default = "1.76.0"
}

variable "CALICOCTL_VERSION" {
  // renovate: datasource=github-releases depName=projectcalico/calico
  default = "v3.33.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/nicolaka/netshoot"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    GRPCURL_VERSION = "${GRPCURL_VERSION}"
    FORTIO_VERSION = "${FORTIO_VERSION}"
    CALICOCTL_VERSION = "${CALICOCTL_VERSION}"
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
