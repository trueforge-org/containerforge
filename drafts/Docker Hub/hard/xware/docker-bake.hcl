target "docker-metadata-action" {}

variable "APP" {
  default = "xware"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/caiguai/docker-xware versioning=loose
  // No upstream release exists. VERSION is a short commit sha and must prefix XWARE_REF (checked in the Dockerfile).
  // UNVERIFIED: the final version string needs maintainer approval.
  default = "2ea1f2f"
}

variable "XWARE_REF" {
  default = "2ea1f2f62c173d44beaef2a44005cc2696d2710c"
}

variable "XWARE_SHA256" {
  // sha256 of xware.tar.bz at XWARE_REF, observed locally. Upstream publishes no checksum.
  default = "2142d2f80cd1f657a5be51b8d1191c4a21eb96b19644887965e47685222ec201"
}

variable "LICENSE" {
  // Proprietary Xunlei binary, no SPDX license. Publishing this image is a licensing decision for maintainers.
  default = "LicenseRef-Proprietary-Xunlei"
}

variable "SOURCE" {
  default = "https://github.com/caiguai/docker-xware/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    XWARE_REF = "${XWARE_REF}"
    XWARE_SHA256 = "${XWARE_SHA256}"
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
  // amd64 only: the binaries are i386 and there is no arm64 build.
  platforms = [
    "linux/amd64"
  ]
}
