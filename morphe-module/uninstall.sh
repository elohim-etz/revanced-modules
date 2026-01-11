#!/system/bin/sh
{

	until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
	until [ -d "/sdcard/Android" ]; do sleep 1; done

	MODDIR=${0%/*}
	. "$MODDIR/config"

	rm "/data/adb/rvelo/${MODDIR##*/}.apk"
	rmdir "/data/adb/rvelo"
	rm "/data/adb/post-fs-data.d/$PKG_NAME-uninstall.sh"
} &
