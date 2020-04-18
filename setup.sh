ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

LAYERS=(\
extra-layers/meta-openembedded/meta-oe
meta-sandbox
)

function update_local_config() {
  CFG_LOCAL=${ROOT_DIR}/build/conf/local.conf
  grep BB_NUMBER_THREADS ${CFG_LOCAL} >/dev/null 2>&1 || echo "BB_NUMBER_THREADS = \"$[$(nproc)*2]\"" >>${CFG_LOCAL}
  grep PARALLEL_MAKE ${CFG_LOCAL} >/dev/null 2>&1 || echo "PARALLEL_MAKE = \"-j $[$(nproc)*2]\"" >>${CFG_LOCAL}
}

function update_layer_config() {
  CFG_LAYER=${ROOT_DIR}/build/conf/bblayers.conf
  for layer in ${LAYERS[@]}; do
    abs_layer=$(readlink -f ${ROOT_DIR}/${layer})
    [ ${abs_layer} ] && grep ${abs_layer} ${CFG_LAYER} >/dev/null 2>&1 || sed -i "s,BBLAYERS ?= \" \\\\,&\n  ${abs_layer} \\\\," ${CFG_LAYER}
  done
}

source ${ROOT_DIR}/poky/oe-init-build-env

update_local_config
update_layer_config
