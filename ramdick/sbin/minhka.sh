#!/system/bin/sh

BB=/res/busybox;

# Remount root and system read/write
mount -t rootfs -o remount,rw rootfs
mount -o remount,rw /system
mount -o remount,rw /data

# Check for init.d folder and create it if it doesn't available
if [ ! -e /system/etc/init.d ] ; then
	mkdir /system/etc/init.d
	chown -R root.root /system/etc/init.d
	chmod -R 755 /system/etc/init.d
else
	chown -R root.root /system/etc/init.d
	chmod -R 755 /system/etc/init.d
fi

# Run init.d scripts
export PATH=${PATH}:/system/bin:/system/xbin
$BB run-parts /system/etc/init.d

chmod 777 /sbin/uci;
chmod 777 /res/uci_p/*;
chmod 777 /res/uci_p/actions/*;
chmod 777 /res/uci_p/files/*;
/sbin/uci

mount -o remount,rw -t auto /system;
chmod -R 777 /system/etc/init.d;
mount -o remount,ro -t auto /system;

sync
mount -t rootfs -o remount,ro rootfs
mount -o remount,ro /system

#
# Set correct r/w permissions for LMK parameters
#

chmod 666 /sys/module/lowmemorykiller/parameters/cost;
chmod 666 /sys/module/lowmemorykiller/parameters/adj;
chmod 666 /sys/module/lowmemorykiller/parameters/minfree;

#
# Synapse
#
$BB mount -t rootfs -o remount,rw rootfs
$BB chmod -R 777 /res/*
ln -s /res/uci_p/uci /sbin/uci
/sbin/uci

if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$($BB mount | grep system | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /system;
fi;

reset_uci() {
  /res/uci_p/uci reset;
  /res/uci_p/uci;
}

reset_uci;
$BB sync;
$BB sleep 1;
