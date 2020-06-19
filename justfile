# use with https://github.com/casey/just


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
		echo -e "Regenerating output files for verion ${version}..."
		rm -rf "${target}"
		mkdir -p "${target}"

		echo -e "    Generating dockerfiles for variant..."
		cp -rp ${commonfolder}/*          "${target}"
		cp -rp "${path}"/*                "${target}"

		for tmpl in $(find "${target}" -name "Dockerfile.*.tmpl" -xtype f | sort | xargs realpath --no-symlinks); do
			cat ${tmpl} >> "${target}/Dockerfile"
			rm -f "${tmpl}"
		done

		echo -e "\033[00;32mFiles for verion ${version} generated.\033[0m\n"
	done



# generate dockerfile & build images
build IMAGE="odooops/dockery-odoo-base": generate
	#!/bin/bash

	# Generates base images per version.
	# Walkes folders matching 'v*' and builds their respective docker context.

	set -Eeuo pipefail

	for path in $(find docker -maxdepth 1 -mindepth 1 -type d | sort) ; do
		version=$(basename "${path}")
		docker build --tag "{{ IMAGE }}:${version}" "docker/${version}"
	done


# generate dockeriles, build & push images
push IMAGE="odooops/dockery-odoo-base": build
	#!/bin/bash

	# Pushes base images per version.
	# Walkes folders matching 'v*' and pushes the respective verion.

	set -Eeuo pipefail

	for path in $(find docker -maxdepth 1 -mindepth 1 -type d | sort) ; do
		version=$(basename "${path}")
		docker push "{{ IMAGE }}:${version}"
	done
