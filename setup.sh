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

function configure_parallel_builds() {
  cfg=${ROOT_DIR}/build/conf/local.conf
  bj=$[$(nproc)*2]
  mj=$((bj < 20 ? bj : 20))
  sed -i "/BB_NUMBER_THREADS/s/[0-9]\+/${bj}/" ${cfg}
  sed -i "/PARALLEL_MAKE/s/[0-9]\+/${mj}/" ${cfg}
}

source ${ROOT_DIR}/poky/oe-init-build-env

update_local_config
update_layer_config
configure_parallel_builds
