FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://modules-blacklist.conf"

do_install:append() {
	install -m 0755 -d ${D}${sysconfdir}/modprobe.d
	install -m 0644 ${UNPACKDIR}/modules-blacklist.conf ${D}${sysconfdir}/modprobe.d
}

