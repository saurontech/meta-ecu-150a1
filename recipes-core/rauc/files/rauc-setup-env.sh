#!/bin/sh
set -e

echo "=== RAUC Environment Setup ==="

SYSTEM_CONF="/etc/rauc/system.conf"
FW_ENV_CONF="/etc/fw_env.config"
DATA_MOUNT_POINT="/data"
MARKER_FILE="${DATA_MOUNT_POINT}/.rauc-env-configured"

# Detect boot device from kernel cmdline
ROOT_DEV=$(grep -oP 'root=/dev/\K[^ ]+' /proc/cmdline | sed 's/p[0-9]*$//')

echo "Detected boot device: ${ROOT_DEV}"

# Determine device paths (no boot partition - rootfs_a is p1, rootfs_b is p2, data is p3)
case "${ROOT_DEV}" in
    mmcblk0)
        DEVICE="/dev/mmcblk0"
        SLOT0_DEV="/dev/mmcblk0p1"
        SLOT1_DEV="/dev/mmcblk0p2"
        DATA_DEV="/dev/mmcblk0p3"
        ;;
    mmcblk1)
        DEVICE="/dev/mmcblk1"
        SLOT0_DEV="/dev/mmcblk1p1"
        SLOT1_DEV="/dev/mmcblk1p2"
        DATA_DEV="/dev/mmcblk1p3"
        ;;
    *)
        echo "ERROR: Unknown boot device: ${ROOT_DEV}" >&2
        exit 1
        ;;
esac

# Mount /data partition if not already mounted
if ! mountpoint -q "${DATA_MOUNT_POINT}"; then
    echo "Mounting ${DATA_DEV} to ${DATA_MOUNT_POINT}..."
    mkdir -p "${DATA_MOUNT_POINT}"
    mount -t ext4 -o defaults,noatime "${DATA_DEV}" "${DATA_MOUNT_POINT}"
fi

echo "Generating RAUC configuration..."

# Generate fw_env.config
cat > "${FW_ENV_CONF}" << EOF
# Auto-generated for ${ROOT_DEV}
${DEVICE}    0x400000    0x4000
EOF

# Generate system.conf
cat > "${SYSTEM_CONF}" << EOF
# Auto-generated for ${ROOT_DEV}

[system]
compatible=Advantech
bootloader=uboot
bundle-formats=plain
statusfile=/data/rauc.status

[keyring]
path=/etc/rauc/ca.cert.pem

[slot.rootfs.0]
device=${SLOT0_DEV}
type=ext4
bootname=system0

[slot.rootfs.1]
device=${SLOT1_DEV}
type=ext4
bootname=system1
EOF

# Create marker on /data (shared across slots)
echo "Configured on $(date) for ${ROOT_DEV}" > "${MARKER_FILE}"

echo "=== RAUC Environment Setup Complete ==="
exit 0