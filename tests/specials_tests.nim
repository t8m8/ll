# source is included since we're not exporting
# anything to be used by other libs/packages
include ll

import future
import unittest

import tempfile

import util


var
  tmpdir: string = nil


proc setUpSetUIDListing() =
  tmpdir = mkdtemp()
  if tmpdir != nil:
    echo "  [su] Created tmpdir: $#".format(tmpdir).fgDarkGray()

  for i in 1..3:
    writeFile(tmpdir / $i, $i)
    discard execShellCmd("chmod u+s $#".format(tmpdir / $i))


proc setUpSetGIDListing() =
  tmpdir = mkdtemp()
  if tmpdir != nil:
    echo "  [su] Created tmpdir: $#".format(tmpdir).fgDarkGray()

  for i in 1..3:
    writeFile(tmpdir / $i, $i)
    discard execShellCmd("chmod g+s $#".format(tmpdir / $i))


proc tearDownSuite() =
  if tmpdir != nil:
    removeDir(tmpdir)
    if not existsDir(tmpdir):
      echo "  [td] Removed tmpdir: $#".format(
        tmpdir,
      ).fgDarkGray()


proc getExampleOutput() =
  echo "\nExample output:"
  echo ll(tmpdir)
  echo ""


suite "setuid file listing tests":

  setUpSetUIDListing()
  
  test "it identifies the setuid bit":
    var
      lines = ll(tmpdir).splitLines()
      entries: seq[string]

    lines = filter(lines, (l) => not l.isSummaryLine)

    entries = @[]
    
    for line in lines:
      entries.add(line)
      check "S" in line

    check entries.len == 3

  getExampleOutput()
  
  tearDownSuite()
