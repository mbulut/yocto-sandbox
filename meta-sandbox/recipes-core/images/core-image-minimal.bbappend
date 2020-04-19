inherit populate_sdk_qt5

TOOLCHAIN_HOST_TASK_append += "\
  nativesdk-cmake \
"

IMAGE_INSTALL_append += "\
  boost \
"
