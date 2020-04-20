BB_NUMBER_THREADS = "${@bb.utils.cpu_count()*2}"
PARALLEL_MAKE = "-j ${@int(bb.utils.cpu_count()*1.5)}"
BUILD_CFLAGS_append = '${@bb.utils.contains("BUILD_ARCH", "i686", " -march=i686 ", "", d)}'
INHERIT += "rm_work"
