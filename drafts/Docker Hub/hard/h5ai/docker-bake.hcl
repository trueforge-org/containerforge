target "docker-metadata-action" {}

variable "APP" {
  default = "h5ai"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=lrsjng/h5ai versioning=loose
  default = "0.30.0"
}

// Manually maintained: sha256 of h5ai-${VERSION}.zip. Renovate cannot update it.
// UNVERIFIED: empty until the value is computed from the release asset.
variable "H5AI_SHA256" {
  default = ""
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/lrsjng/h5ai"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    H5AI_SHA256 = "${H5AI_SHA256}"
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
