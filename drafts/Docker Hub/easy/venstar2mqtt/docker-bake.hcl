target "docker-metadata-action" {}

variable "APP" {
  default = "venstar2mqtt"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/terafin/mqtt-venstar-bridge currentValue=master
  default = "423f9bd613619e92e4799135cf080c1de05d13dc"
}

variable "HAJL_COMMIT" {
  // renovate: datasource=git-refs depName=https://github.com/terafin/homeautomation-js-lib currentValue=master
  default = "f506c726e4b1faaee52291498be9ba9ff8ff1199"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/terafin/mqtt-venstar-bridge"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    HAJL_COMMIT = "${HAJL_COMMIT}"
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
