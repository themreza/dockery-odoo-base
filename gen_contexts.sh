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
	cp -rp "${DIR}"/common/* "${path}/out/"
	cp -rp "${path}"/spec/*  "${path}/out/"
	find "${path}/out/" -name "__*" -type f -exec rm {} \+
	cat "$path/spec/__patches" >> "$path/out/patches"
	cat "${DIR}"/common/__Dockerfile >> "$path/out/Dockerfile"
	curl "https://raw.githubusercontent.com/odoo/odoo/${version}/requirements.txt" -o "${DIR}/${name}/out/requirements.txt"
done
