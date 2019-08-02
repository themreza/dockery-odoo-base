#!/bin/bash

# Generates base images docker contexts.
# Recursively copies (merges) files from ./common and
# curls the newest version of the "official" requirements.txt

set -Eeuo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


for path in $(find "${DIR}" -maxdepth 1 -type d -name 'v-*') ; do
	name=$(basename "${path}")
	version=${name#"v-"}
	shopt -s extglob
	echo -e "Cleanup ${version} target..."
	rm -rf "${path}/out/"
	mkdir -p "${path}/out/"
	echo -e "Copy to ${version} target..."
	cp -rp "${DIR}"/common/* "${path}/out/"
	cp -rp "${path}"/spec/*  "${path}/out/"
	echo -e "Build ${version} Dockerfile from templates..."
	for tmpl in $(find "${path}/out/" -name "Dockerfile.*.tmpl" -xtype f | sort | xargs realpath --no-symlinks); do
		cat ${tmpl} >> "${path}/out/Dockerfile"
		rm -f "${tmpl}"
	done
	echo -e "Fetch ${version} latest requirements.txt..."
	curl "https://raw.githubusercontent.com/odoo/odoo/${version}/requirements.txt" -o "${DIR}/${name}/out/requirements.txt"
	echo -e "\n"
done
