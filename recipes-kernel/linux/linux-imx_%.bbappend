FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

ADV_ECU_FOLDER = "adv_ecu"

SRC_URI += "\
    file://imx_v8_adv.cfg \
    file://imx8mq-rom5720-a1.dts \
    file://${ADV_ECU_FOLDER} \
    file://adv_ecu.patch \
"

#DELTA_KERNEL_DEFCONFIG = "imx_v8_adv.cfg"

DELTA_KERNEL_DEFCONFIG = "${ADV_ECU_FOLDER}/imx8mq_ecu150a1_defconfig"

do_configure:append() {
    case "${MACHINE}" in
        *ecu*)
            cp ${WORKDIR}/${ADV_ECU_FOLDER}/*.dts ${S}/arch/arm64/boot/dts/freescale || exit 1
        ;;
        *)
            cp ${WORKDIR}/imx8mq-rom5720-a1.dts ${S}/arch/arm64/boot/dts/freescale || exit 1
        ;;
    esac
    cp ${WORKDIR}/${ADV_ECU_FOLDER}/rtc-ht1382.c ${S}/drivers/rtc/ || exit 1
    cp ${WORKDIR}/${ADV_ECU_FOLDER}/ecu_board.c ${S}/drivers/char/ || exit 1
    cp ${WORKDIR}/${ADV_ECU_FOLDER}/usb/f81604.c ${S}/drivers/net/can/usb/ || exit 1
}

# 	The F81604 is a USB to dual CAN bus controllers for the Controller Area Network (CAN) used for the general industrial environment. F81604 supports the CAN 2.0A
