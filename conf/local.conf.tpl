BB_NUMBER_THREADS = "${@bb.utils.cpu_count()*2}"
PARALLEL_MAKE = "-j ${@int(bb.utils.cpu_count()*1.5)}"
INHERIT += "rm_work"
