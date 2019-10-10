#!/bin/bash

# Constructs the app's runtime environment.
# Besides app consumed env variables, it also creates
# the environment for entrypoint and startup scripts (eg. ODOO_ADDONS_PATH)

set -Eeuo pipefail

export ODOO_ADMINPASSWORD_FILE="${ODOO_ADMINPASSWORD_FILE:=/run/secrets/adminpwd}"  # Odoo Passfile (Patch tools/0002)

addonspath=""
# Sort reverse alfanumerically first, then do realpath
# so we can freely reorder loading by symlinking for
# exemple in a CI environment directly from a git clone.

get_addons () {

python 2>&1 >/dev/null - <<END
#!/usr/bin/env python
import os
import sys


MANIFEST_NAMES = ["__manifest__.py", "__odoo__.py", "__openerp__.py", "__terp__.py"]
SKIP_PATHS = ["point_of_sale/tools", "base_import_module/tests"]

def main():
    # Input in the form of an array of folders (layered image)
    inputs = sorted("$@".split())
    res = []
    for input in inputs:
        paths = set()
        for root, _, files in os.walk(input):
            if any(S in root for S in SKIP_PATHS):
                continue
            if not any(M in files for M in MANIFEST_NAMES):
                continue
            paths |= set([os.path.dirname(root)])
        paths = sorted(list(paths))  # We promise alphabetical order
        res.extend(paths)
    return ' '.join(res)


if __name__ == "__main__":
    sys.exit(main())
END
}


for dir in $(get_addons ${ODOO_SRC}); do
    echo "==>  Adding $dir to addons path"
    if [ -z "$addonspath" ]; then
        addonspath=$dir
    else
        addonspath=$addonspath,$dir
    fi;
done;

for dir in $(get_addons ${ODOO_VENDOR}); do

    echo "==>  Adding $dir to addons path"
    if [ -z "$addonspath" ]; then
        addonspath=$dir
    else
        addonspath=$addonspath,$dir
    fi;
done;
export ODOO_ADDONS_PATH=$addonspath
