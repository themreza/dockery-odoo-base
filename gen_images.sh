#!/bin/bash

# Generates base images per version.
# Walkes folders matching'v*' and builds their respectiv docker context.
# Before that, calls gen_context in order the build contexts

set -Eeuo pipefail


set +u
if [ -z "${1+x}" ]; then
	echo -e "Usage: gen_images IMAGEREPO"
	echo -e ""
	echo -e "Use IMAGEREPO in the form repo/image without tags."
	echo -e "Tags will be created by the scripts as per app version."
fi
set -u


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


source "${DIR}"/gen_contexts.sh

for path in $(find "${DIR}" -maxdepth 1 -type d -name 'v-*') ; do
	name=$(basename "${path}")
	version=${name#"v-"}
	docker build --tag "${1}:${version}" "${name}/out"
done
