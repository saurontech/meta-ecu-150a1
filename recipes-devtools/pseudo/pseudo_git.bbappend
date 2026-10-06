# Fix: pseudo <-> GNU tar >= 1.35 openat2() incompatibility in do_package.
#
# Symptom (seen here on linux-imx:do_package, and on any recipe whose
# do_package is re-run and creates new nested dirs, e.g. rauc-conf):
#     got *at() syscall for unknown directory, fd 4
#     couldn't allocate absolute path for 'lib'.
#     tar: ./usr/lib: Cannot mkdir: Bad address
#
# Cause: poky scarthgap (yocto-5.0.4) pins pseudo at SRCREV 374089f2
# (2024-07-25, PV 1.9.0+git), which has NO openat2() wrapper at all.
# GNU tar 1.35 (Ubuntu 24.04 host) opens directories with openat2()
# and then issues mkdirat()/openat() relative to those fds. Old pseudo
# never sees the openat2() call, so the fd is missing from its
# "fd -> absolute path" table and every later *at() call on it fails
# with EFAULT.
#
# Fix: bump to upstream pseudo-1.9.8, which has the openat2 wrapper.
#
# This mirrors, exactly, what upstream poky scarthgap already did in
# commit 3f378fc245 "pseudo: Update to version 1.9.8". We only carry it
# as a bbappend because this tree's poky is pinned by the NXP i.MX BSP
# and cannot simply be fast-forwarded to the scarthgap tip.
#
# ---> When poky is next updated to a scarthgap point release that
#      contains 3f378fc245, DELETE this whole directory. <---

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRCREV = "823895ba708c63f6ae4dcbfc266210f26c02c698"
PV = "1.9.8"

# Two of poky-scarthgap's three pseudo patches are obsolete at 1.9.8 and
# upstream dropped both in the same commit:
#
#  * 0001-configure-Prune-PIE-flags.patch
#      Upstream merged the equivalent into configure itself; its tail now
#      runs  sed Makefile -e 's/\-[f]*pie//g' > Makefile.tmp && mv ...
#      Re-applying it fails ("Hunk #1 FAILED at 339").
#
#  * glibc238.patch
#      Upstream moved the __isoc23_strtol / _GNU_SOURCE workaround into
#      dedicated strtol.c and pseudo_client_scanf.c. The patch still
#      *applies*, but it is redundant duplication of an upstream fix, so
#      we drop it just as upstream did.
SRC_URI:remove = "file://0001-configure-Prune-PIE-flags.patch file://glibc238.patch"

# older-glibc-symbols.patch (native/nativesdk only) is STILL required --
# it makes libpseudo.so link against older glibc symbols so it can be
# LD_PRELOADed on hosts with an older libc. It stays in SRC_URI, but
# poky-scarthgap's copy no longer applies at 1.9.8: upstream added
# pseudo_client_scanf.o to the $(LIBPSEUDO) link rule, shifting the
# Makefile.in hunk context.
#
# files/older-glibc-symbols.patch in this layer is upstream scarthgap's
# own rebased version (verified byte-identical to poky scarthgap tip);
# FILESEXTRAPATHS above makes it win over poky's stale copy. Only the
# two Makefile.in context lines differ.
