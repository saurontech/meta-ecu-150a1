# Only process this recipe if RAUC is enabled
python () {
    if d.getVar('RAUC_ENABLED') != '1':
        raise bb.parse.SkipRecipe("RAUC is disabled (RAUC_ENABLED != '1')")
}

inherit bundle

# Bundle version (will be displayed in rauc status version field)
PV = "1.0.5"
RAUC_BUNDLE_VERSION = "${PV}"

# Compatibility string (must match system.conf)
RAUC_BUNDLE_COMPATIBLE = "Advantech"

RAUC_BUNDLE_FORMAT = "plain"

# Signing key and certificate
RAUC_KEY_FILE = "${THISDIR}/files/development-1.key.pem"
RAUC_CERT_FILE = "${THISDIR}/files/development-1.cert.pem"

# Slots to include in bundle
RAUC_BUNDLE_SLOTS = "rootfs"

# rootfs slot content (replace "core-image-minimal" with your image name)
RAUC_SLOT_rootfs = "core-image-minimal"
RAUC_SLOT_rootfs[fstype] = "tar.gz"