SUMMARY = "Sandbox Service"
DESCRIPTION = "A sandbox package to fiddle out things"

LICENSE = "CLOSED"

SRC_URI = "file://sandbox.service"

inherit systemd

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "sandbox.service"

FILES:${PN} += "${systemd_unitdir}"

do_install() {
	install -d ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/sandbox.service ${D}${systemd_system_unitdir}
}
