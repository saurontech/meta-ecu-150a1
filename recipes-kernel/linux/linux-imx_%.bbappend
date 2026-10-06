FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

ADV_ECU_FOLDER = "adv_ecu"

SRC_URI += "\
    file://imx_v8_adv.cfg \
    file://imx8mq-rom5720-a1.dts \
    file://${ADV_ECU_FOLDER} \
"

#DELTA_KERNEL_DEFCONFIG = "imx_v8_adv.cfg"

DELTA_KERNEL_DEFCONFIG = "${ADV_ECU_FOLDER}/imx8mq_ecu150a1_defconfig"

do_configure:append() {
    case "${MACHINE}" in
        *ecu*)
            cp ${UNPACKDIR}/${ADV_ECU_FOLDER}/*.dts ${S}/arch/arm64/boot/dts/freescale || exit 1
        ;;
        *)
            cp ${UNPACKDIR}/imx8mq-rom5720-a1.dts ${S}/arch/arm64/boot/dts/freescale || exit 1
        ;;
    esac
    cp ${UNPACKDIR}/${ADV_ECU_FOLDER}/rtc-ht1382.c ${S}/drivers/rtc/ || exit 1
    cp ${UNPACKDIR}/${ADV_ECU_FOLDER}/ecu_board.c ${S}/drivers/char/ || exit 1
}

