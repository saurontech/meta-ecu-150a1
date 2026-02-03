FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:imx8mq-ecu150a1 = " \
    file://imx8mq_ecu150a1_defconfig \
    file://0001-Add-ECU150A1-board-support.patch \
"

DELTA_KERNEL_DEFCONFIG:imx8mq-ecu150a1 = "imx8mq_ecu150a1_defconfig"

