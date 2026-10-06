FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:imx8mq-ecu150a1 = " \
    file://imx8mq_ecu150a1_defconfig \
    file://0001-Add-ECU150A1-board-support.patch \
"

DELTA_KERNEL_DEFCONFIG:imx8mq-ecu150a1 = "imx8mq_ecu150a1_defconfig"

# ---------------------------------------------------------------------------
# Security backports for fs/eventpoll.c
# ---------------------------------------------------------------------------

# CVE-2026-43074 -- eventpoll: defer struct eventpoll free to RCU grace
# period. UAF on struct eventpoll. Fixed upstream in 6.6.136.
SRC_URI:append:imx8mq-ecu150a1 = " \
    file://cve-2026-43074/0001-eventpoll-defer-struct-eventpoll-free-to-RCU-grace-p.patch \
"

# CVE-2026-46242 ("Bad Epoll") -- UAF between ep_remove() and __fput().
# Locally exploitable to root. Fixed upstream in 6.6.144.
#
# 0001 is a prerequisite: the fix uses "struct file *file __free(fput)",
# which needs DEFINE_FREE(fput) in include/linux/file.h.
# 0002-0007 are the refactor the fix is built on (Stable-dep-of).
# 0008 is the actual fix.
SRC_URI:append:imx8mq-ecu150a1 = " \
    file://cve-2026-46242/0001-file-add-fput-cleanup-helper.patch \
    file://cve-2026-46242/0002-eventpoll-use-hlist_is_singular_node-in-__ep_remove.patch \
    file://cve-2026-46242/0003-eventpoll-split-__ep_remove.patch \
    file://cve-2026-46242/0004-eventpoll-kill-__ep_remove.patch \
    file://cve-2026-46242/0005-eventpoll-drop-vestigial-__-prefix-from-ep_remove_-f.patch \
    file://cve-2026-46242/0006-eventpoll-rename-ep_remove_safe-back-to-ep_remove.patch \
    file://cve-2026-46242/0007-eventpoll-move-epi_fget-up.patch \
    file://cve-2026-46242/0008-eventpoll-fix-ep_remove-struct-eventpoll-struct-file.patch \
"
