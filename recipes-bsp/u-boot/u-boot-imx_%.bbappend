FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
	file://ecu-adv-uboot-imx \
"

SRC_URI:append:imx8mq-ecu150a1 = " file://imx8mq_ecu150a1-adv-uboot-imx.patch"

do_configure:prepend() {
	case "${MACHINE}" in
		imx8mq-ecu150a1)
			cp ${WORKDIR}/ecu-adv-uboot-imx/arch/arm/dts/fsl-imx8mq-ecu150a1.dts ${S}/arch/arm/dts/
			cp ${WORKDIR}/ecu-adv-uboot-imx/board/freescale/imx8mq_adv/lpddr4_timing_*.c ${S}/board/freescale/imx8mq_evk/
		;;
		*)
		 	echo "other machine ....do anything"
		;;
	esac
}
