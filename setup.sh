ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

function update_local_config() {
  cfg=${ROOT_DIR}/build/conf/local.conf
  while IFS="" read -r line || [ "$line" ]; do
    key=${line%% *}
    grep ${key} ${cfg} >/dev/null 2>&1 || echo ${line} >>${cfg}
  done < ${ROOT_DIR}/conf/local.conf.tpl
}

function update_layer_config() {
  cfg=${ROOT_DIR}/build/conf/bblayers.conf
  while IFS="" read -r line || [ "$line" ]; do
    layer=$(readlink -f ${ROOT_DIR}/${line})
    [ ${layer} ] && grep ${layer} ${cfg} >/dev/null 2>&1 || sed -i "s,BBLAYERS ?= \" \\\\,&\n  ${layer} \\\\," ${cfg}
  done < ${ROOT_DIR}/conf/bblayers.conf.tpl
}

source ${ROOT_DIR}/poky/oe-init-build-env

update_local_config
update_layer_config
