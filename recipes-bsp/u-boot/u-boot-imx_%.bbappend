FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:imx8mq-ecu150a1 = " file://0001-Add-ECU150A1-U-Boot-support.patch \
                                   file://0002-Use-Image-dtb-in-rootfs.patch \
                                 "

# RAUC-specific patches (conditionally applied)
SRC_URI:append:imx8mq-ecu150a1 = "${@' file://0003-Support-RAUC-AB-boot.patch' if d.getVar('RAUC_ENABLED') == '1' else ''}"

