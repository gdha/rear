# This file is part of Relax-and-Recover,
# licensed under the GNU General Public License.
# Refer to the included COPYING for full text of license.

# Save the current disk usage (in POSIX output format) in the rescue image
# excluding possibly mounted ReaR target USB data and USB ESP partitions:
local original_disk_space_usage_file="$VAR_DIR/layout/config/df.txt"
# USB_DEVICE_FILESYSTEM_LABEL must not be empty (otherwise 'readlink -f "/dev/disk/by-label/"' would result '/dev/disk/by-label'):
contains_visible_char "$USB_DEVICE_FILESYSTEM_LABEL" || USB_DEVICE_FILESYSTEM_LABEL="REAR-000"
local rear_USB_data_partition="$( readlink -f "/dev/disk/by-label/$USB_DEVICE_FILESYSTEM_LABEL" )"
local rear_USB_ESP_partition="$( readlink -f /dev/disk/by-label/REAR-EFI )"
# Careful with "grep -Ev" patterns because with an empty pattern grep -Ev '' discards all lines:
local egrep_pattern=""
test "$rear_USB_data_partition" && egrep_pattern="^$rear_USB_data_partition"
if test "$rear_USB_ESP_partition" ; then
    test "$egrep_pattern" && egrep_pattern+="|^$rear_USB_ESP_partition" || egrep_pattern="^$rear_USB_ESP_partition"
fi
# The disk usage must be in MiB units '-BM' (and not in arbitrary human readable units via '-h')
# because the values are used in 420_autoresize_last_partitions.sh to calculate whether or not
# the current disk usage still fits on a smaller disk when the last partition must shrink:
if test "$egrep_pattern" ; then
    df -Pl -BM -x encfs -x tmpfs -x devtmpfs | grep -Ev "$egrep_pattern" >$original_disk_space_usage_file
else
    df -Pl -BM -x encfs -x tmpfs -x devtmpfs >$original_disk_space_usage_file
fi

