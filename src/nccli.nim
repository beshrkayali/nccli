## Nextcloud CLI and file sync

import os
import tables
import options
import streams
import parsetoml
import chronicles
import asyncdispatch

import loki
import webdavclient


proc getFirstExistingPath(paths: seq[string]): Option[string] =
  for path in paths:
    if fileExists(path):
      return some(path)

  return none(string)


proc getConfig(conf_path: string = ""): TomlValueRef =
  ## Find and parses toml config file.
  ##
  ## Lookup order is:
  ## - `./.nccli.toml`
  ## - `~/.config/nccli/config`
  ## - `/etc/nccli/nccli.toml`

  var path = conf_path

  if conf_path == "":
    let found_path = getFirstExistingPath(
      @[".nccli.toml",
        "~/.config/nccli/config",
        "/etc/nccli/nccli.toml"]
    )

    if isNone(found_path):
      fatal "No conf file found and one wasn't provided."
      quit(QuitFailure)

    path = get found_path

  debug "Config found", path

  # Read it
  var fs = newFileStream(path, fmRead)
  let conf_content = fs.readAll()

  # Parse it
  try:
    let parsed = parsetoml.parseString(conf_content)
    return parsed
  except TomlError as e:
    fatal "Toml syntax error", line = e.location.line,
        column = e.location.column


proc nccli(conf: string = ""): int =
  let config = getConfig(conf_path = conf)

  let wd = newAsyncWebDAV(
    address = config["nextcloud"]["url"].getStr,
    username = config["nextcloud"]["username"].getStr,
    password = config["nextcloud"]["password"].getStr,
    path = "/remote.php/dav"
  )

  loki(ncHandler, line):
    do_ls name, age:
      echo("Ok...")
    do_EOF:
      quit()
    default:
      write(stdout, "*** Unknown syntax: ", line.text, " ***\n")

  let lokiShell = newLoki(
    handler = ncHandler,
    prompt = "(nextcloud) ",
    intro = "Welcome to NextCloud CLI!\n",
  )

  lokiShell.cmdloop()


when isMainModule:
  import cligen; dispatch(nccli, help = {"conf": "Path to config file"})
