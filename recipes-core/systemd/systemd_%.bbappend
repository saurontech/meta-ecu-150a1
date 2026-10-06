FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

PACKAGECONFIG:append = " networkd resolved"
SRC_URI:append:imx-generic-bsp = " file://imx.conf \
"

do_install:append:imx-generic-bsp() {
    install -Dm 0644 ${WORKDIR}/imx.conf ${D}${sysconfdir}/systemd/logind.conf.d/imx.conf
}

