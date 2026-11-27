target "docker-metadata-action" {}

variable "APP" {
  default = "onlinecheckyourserver"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/ich777/docker-online-check-pushover currentValue=master
  default = "318fcf88d83106b4d70bd731e7bac03a4b66795c"
}

// UNVERIFIED: upstream declares no license. Confirm with the user before merging.
variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/ich777/docker-online-check-pushover"
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
    "linux/amd64"
  ]
}
