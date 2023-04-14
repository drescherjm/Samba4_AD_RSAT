#!/bin/sh

CURRENT_SCRIPT="$(readlink -m $0)"
CURRENT_FOLDER="$(dirname "${CURRENT_SCRIPT}")"

cd ${CURRENT_FOLDER}/databag

for sample_file in *.cfg.sample; do cp -n ${sample_file} ${sample_file/.sample/} ; done

echo ; \
ls *.cfg | xargs -I{} bash -c " \
echo -e '\e[0;33m'; \
echo ---------------------------; \
echo {}; \
echo ---------------------------; \
echo -n -e '\033[00m' ; \
echo -n -e '\e[0;32m'; \
cat {} | grep -v 'plugin_load_databag.sh' | grep -vE '^\s*#' |sed '/^\s*$/d'; \
echo -e '\033[00m' ; \
echo " | less -r


