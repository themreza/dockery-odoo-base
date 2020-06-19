# use with https://github.com/casey/just


# regenerate dockerfiles
regenerate:
	#!/bin/bash

	# Generates base images docker contexts.
	# Recursively copies (merges) files from ./common and
	# curls the newest version of the "official" requirements.txt

	set -Eeuo pipefail

	for path in $(find "$(pwd)" -maxdepth 1 -type d -name 'v-*') ; do
		name=$(basename "${path}")
		version=${name#"v-"}
		shopt -s extglob
		echo -e "Cleanup ${version} target..."
		rm -rf "${path}/out/"
		mkdir -p "${path}/out/"
		echo -e "Copy to ${version} target..."
		cp -rp "$(pwd)"/common/* "${path}/out/"
		cp -rp "${path}"/spec/*  "${path}/out/"
		echo -e "Build ${version} Dockerfile from templates..."
		for tmpl in $(find "${path}/out/" -name "Dockerfile.*.tmpl" -xtype f | sort | xargs realpath --no-symlinks); do
			cat ${tmpl} >> "${path}/out/Dockerfile"
			rm -f "${tmpl}"
		done
		echo -e "Fetch ${version} latest requirements.txt..."
		curl "https://raw.githubusercontent.com/odoo/odoo/${version}/requirements.txt" -o "$(pwd)/${name}/out/requirements.txt"
		echo -e "\n"
	done


# regenerate dockerfile & build images
build IMAGE="xoelabs/dockery-odoo-base": regenerate
	#!/bin/bash

	# Generates base images per version.
	# Walkes folders matching 'v*' and builds their respective docker context.

	set -Eeuo pipefail

	for path in $(find "$(pwd)" -maxdepth 1 -type d -name 'v-*') ; do
		name=$(basename "${path}")
		version=${name#"v-"}
		docker build --tag "{{ IMAGE }}:${version}" "${name}/out"
	done


# regenerate dockeriles, build & push images
push IMAGE="xoelabs/dockery-odoo-base": build
	#!/bin/bash

	# Pushes base images per version.
	# Walkes folders matching 'v*' and pushes the respective verion.

	set -Eeuo pipefail

	for path in $(find "$(pwd)" -maxdepth 1 -type d -name 'v-*') ; do
		name=$(basename "${path}")
		version=${name#"v-"}
		docker push "{{ IMAGE }}:${version}"
	done
