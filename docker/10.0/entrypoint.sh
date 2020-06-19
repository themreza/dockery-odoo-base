#!/bin/bash

set -Eeuo pipefail

# -----------------------------------------------------------------------------
# This general entrypoint script provides the control structure for dealing
# with all possible odoo commands supplied to this container.
#
# entrypoint.appenv.sh provides a general app environment and entrypoint.d
# folder scripts are executed in their alphabetical where needed.
#
# It is meant to be adapted or extended in downstream containers.
# -----------------------------------------------------------------------------

# set +x

function sourceScriptsInFolder {
	echo -e "\n\n"
	for file in $(find "$1" -maxdepth 1 -mindepth 1 -xtype f -exec realpath {} + | sort); do
	    echo -e "==>  Sourcing ${file}"

		# shellcheck disable=SC1091
		# shellcheck source=entrypoint.d/
	    source "$file"
	done
	echo -e "\n\n"
}

# If no command supllied, set `run`
if [ "$#" -eq 0 ] || [ "${1:0:1}" = '-' ]; then
	set -- run "$@"
fi

CMD=( "$@" )

# Hint: you also can extend the entrypoint with new creative commands by placing
# scripts in this folder within the container.
# Just catch the $1 argument and set `CMD` array - it's sourced, not called.
sourceScriptsInFolder "/entrypoint.d" "$@"


# Standard commands
if [ "$1" = 'run' ]; then
	sourceScriptsInFolder "/entrypoint.db.d"
	CMD=(
			"${ODOO_CMD}"
			"--addons-path"
			"${ODOO_ADDONS_PATH}"
			"--data-dir"
			"${ODOO_PRST_DIR}"
			"--config"
			"${ODOO_RC}"
			"--pg_path"
			"$(which psql)"
			"${CMD[@]:1}"
		)
fi

if [ "$1" = 'gevent' ]; then
	sourceScriptsInFolder "/entrypoint.db.d"
	CMD=(
			"${ODOO_CMD}"
			"gevent"
			"--addons-path"
			"${ODOO_ADDONS_PATH}"
			"--data-dir"
			"${ODOO_PRST_DIR}"
			"--config"
			"${ODOO_RC}"
			"--pg_path"
			"$(which psql)"
			"${CMD[@]:1}"
		)
fi

if [ "$1" = 'shell' ]; then
	sourceScriptsInFolder "/entrypoint.db.d"
	CMD=(
			"${ODOO_CMD}"
			"shell"
			"--addons-path"
			"${ODOO_ADDONS_PATH}"
			"--data-dir"
			"${ODOO_PRST_DIR}"
			"--config"
			"${ODOO_RC}"
			"--pg_path"
			"$(which psql)"
			"--no-http"
			"${CMD[@]:1}"
		)
fi

if [ "$1" = 'scaffold' ]; then
	CMD=(
			"${ODOO_CMD}"
			"${CMD[@]}"
		)
fi

# set -x
exec "${CMD[@]}"
