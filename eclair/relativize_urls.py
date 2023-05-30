#!/usr/bin/env python3
#
# Copyright (c) 2022-2023 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

# Script to replace absolute paths in ECLAIR HTML reports, pointing to
# "dependency" files like CSS & JS, to relative paths, pointing to
# those files copied alongside the report.

import sys
import re
import os
import glob


os.chdir(sys.argv[1])
for fn in glob.iglob("**/*.html", recursive=True):
    depth = fn.count("/")
    relp = "/".join([".."] * depth)
    if relp:
        relp += "/"
    #print(fn, relp)
    with open(fn) as f:
        txt = f.read()
    txt = txt.replace("/opt/bugseng/eclair-3.12.0/", relp)
    #os.rename(fn, fn + ".bak")
    with open(fn, "w") as f:
        f.write(txt)
