#!/bin/bash

# Constructs the app's runtime environment.
# Besides app consumed env variables, it also creates
# the environment for entrypoint and startup scripts (eg. ODOO_ADDONS_PATH)

set -Eeuo pipefail


# Runtime Env shadowing
export ODOO_PASSFILE="${ODOO_PASSFILE:=/run/secrets/adminpwd}"  # Odoo Passfile (Patch tools/0002)

export              ODOO_RC="${ODOO_BASEPATH}/cfg.d"  # Bind-mount a folder (Patch tools/0001)
export             ODOO_MIG="${ODOO_BASEPATH}/migration.yaml"
export             ODOO_CMD="${ODOO_BASEPATH}/odoo-bin"
export             ODOO_FRM="${ODOO_BASEPATH}/odoo"
export ODOO_ADDONS_BASEPATH="${ODOO_BASEPATH}/addons"

addonspath=""
# Sort reverse alfanumerically first, then do realpath
# so we can freely reorder loading by symlinking for
# exemple in a CI environment directly from a git clone.
for dir in $(find "${ODOO_ADDONS_BASEPATH}" -maxdepth 1 -mindepth 1 -xtype d | sort -r | xargs realpath); do

	# Prevent loading enterprise addons folder if switched on
	if [[ $ODOO_ENTERPRISE != 'yes' ]] && [[ $dir == "${ODOO_ADDONS_BASEPATH}"/001 ]]; then
		continue
	fi

    echo "==>  Adding $dir to addons path"
    if [ -z "$addonspath" ]; then
        addonspath=$dir
    else
        addonspath=$addonspath,$dir
    fi;
done;
export ODOO_ADDONS_PATH=$addonspath
