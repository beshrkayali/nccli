# Package

version       = "0.1.0"
author        = "Beshr Kayali"
description   = "Nextcloud CLI"
license       = "Apache-2.0"
srcDir        = "src"
bin           = @["nccli"]



# Dependencies

requires "nim >= 1.0.0"
requires "loki"
requires "webdavclient >= 0.0.1"
requires "parsetoml >= 0.5.0"
requires "chronicles >= 0.7.0"
requires "cligen <= 0.9.42"
