#!/system/bin/sh

MM=res/uci_p;
BB=/res/busybox;

#Official

		CONFIG="unified";

if [ -n "$CONFIG" ]; then PATH="$MM/device/$CONFIG.sh"; else PATH=""; fi;

$BB echo "$PATH";
