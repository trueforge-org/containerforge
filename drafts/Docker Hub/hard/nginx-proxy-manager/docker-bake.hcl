target "docker-metadata-action" {}

variable "APP" {
  default = "nginx-proxy-manager"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=NginxProxyManager/nginx-proxy-manager extractVersion=^v(?<version>.+)$ versioning=semver
  default = "2.17.1"
}

variable "OPENRESTY_VERSION" {
  // renovate: datasource=github-tags depName=openresty/openresty extractVersion=^v(?<version>.+)$ versioning=loose
  default = "1.31.9.1"
}

// A renovate bump of OPENRESTY_VERSION also needs a matching OPENRESTY_SHA256.
variable "OPENRESTY_SHA256" {
  default = "71d49935bdc186dafc1f4b0a8ba44dba1bf4abc8ca52d4621f2039ec8fdcc95f"
}

variable "CERTBOT_VERSION" {
  // renovate: datasource=pypi depName=certbot versioning=pep440
  default = "5.10.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/NginxProxyManager/nginx-proxy-manager"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    OPENRESTY_VERSION = "${OPENRESTY_VERSION}"
    OPENRESTY_SHA256 = "${OPENRESTY_SHA256}"
    CERTBOT_VERSION = "${CERTBOT_VERSION}"
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
