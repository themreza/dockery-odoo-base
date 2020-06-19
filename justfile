# use with https://github.com/casey/just

IMAGE := "odooops/dockery-odoo-base"

# generate dockerfiles
generate:
	#!/bin/bash

	# Generates base images docker contexts.
	# Recursively copies (merges) files from ./common and
	# curls the newest version of the "official" requirements.txt

	set -Eeuo pipefail

	commonfolder="_spec-common"

	for path in $(find . -maxdepth 1 -type d -name '_spec-v-*' | grep 'v-....$\|v-master$' | sort) ; do
		name=$(basename "${path}")
		version=${name#"_spec-v-"}
		target="docker/${version}"
		shopt -s extglob
		echo -e "Regenerating version ${version}..."
		rm -rf "${target}"
		mkdir -p "${target}"

		echo -e "    Generating dockerfiles..."
		cp -rp ${commonfolder}/*          "${target}"
		cp -rp "${path}"/*                "${target}"

		for tmpl in $(find "${target}" -name "Dockerfile.*.tmpl" -xtype f | sort | xargs realpath --no-symlinks); do
			cat ${tmpl} >> "${target}/Dockerfile"
			rm -f "${tmpl}"
		done

		echo -e "    Fetch latest requirements.txt...\n"
		curl "https://raw.githubusercontent.com/odoo/odoo/${version}/requirements.txt" -o "${target}/requirements.txt"
		echo -e "\n"

		echo -e "\033[00;32mFiles for verion ${version} generated.\033[0m\n"
	done



# generate dockerfiles & build images
build: generate
	#!/bin/bash

	# Generates base images per version.
	# Walkes `docker` folder and builds respective docker context.

	set -Eeuo pipefail

	for path in $(find docker -maxdepth 1 -mindepth 1 -type d | sort) ; do
		version=$(basename "${path}")
		docker build --tag "{{ IMAGE }}:${version}" "docker/${version}"
	done


# generate dockeriles, build & push images
push: build
	#!/bin/bash

	# Pushes base images per version.
	# Detects versions from `docker` folder and pushes.

	set -Eeuo pipefail

	for path in $(find docker -maxdepth 1 -mindepth 1 -type d | sort) ; do
		version=$(basename "${path}")
		docker push "{{ IMAGE }}:${version}"
	done
