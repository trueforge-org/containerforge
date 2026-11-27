target "docker-metadata-action" {}

variable "APP" {
  default = "odoo"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/library/odoo
  // UNVERIFIED: placeholder. The upstream tag 20.0 is not a release pin, and this datasource is not confirmed.
  default = "20.0"
}

variable "ODOO_RELEASE" {
  // Pinned nightly build date. No Renovate datasource: bump by hand together with ODOO_SHA.
  default = "20261112"
}

variable "ODOO_SHA" {
  // sha1 of odoo_20.0.${ODOO_RELEASE}_all.deb, as published by upstream odoo/docker
  default = "9b69ffe4ebf8a4412b312d1f71494112d8410e12"
}

variable "LICENSE" {
  // UNVERIFIED: Odoo community is LGPL-3.0; confirm against https://github.com/odoo/odoo before merge.
  default = "LGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/odoo/odoo"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    ODOO_RELEASE = "${ODOO_RELEASE}"
    ODOO_SHA = "${ODOO_SHA}"
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
