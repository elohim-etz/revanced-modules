#!/system/bin/sh
MODDIR=${0%/*}
RVPATH=/data/adb/rvhc/${MODDIR##*/}.apk
. "$MODDIR/config"
. "$MODDIR/common.sh"

# Define the path of root manager applet bin directories using find and set it to $PATH then export it
if ! command -v busybox >/dev/null 2>&1; then
	TOYS_PATH=$(find "/data/adb" -maxdepth 3 \( -name busybox -o -name ksu_susfs \) -exec dirname {} \; | sort -u | tr '\n' ':')
	export PATH="${PATH:+${PATH}:}${TOYS_PATH%:}"
fi

HAS_SUSFS="$(command -v ksu_susfs)"

err() {
	[ ! -f "$MODDIR/err" ] && cp "$MODDIR/module.prop" "$MODDIR/err"
	sed -i "s/^des.*/description=⚠️ Needs reflash: '${1}'/g" "$MODDIR/module.prop"
}

until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
until [ -d "/sdcard/Android" ]; do sleep 1; done
while
	BASEPATH=$(pmex path "$PKG_NAME")
	SVCL=$?
	[ $SVCL = 20 ]
do sleep 2; done

run() {
	if [ $SVCL != 0 ]; then
		err "app not installed"
		return
	fi
	sleep 4

	BASEPATH=${BASEPATH##*:} BASEPATH=${BASEPATH%/*}
	if [ ! -d "$BASEPATH/lib" ]; then
		err "mount failed (ROM issue)"
		return
	fi
	VERSION=$(dumpsys package "$PKG_NAME" | grep -m1 versionName) VERSION="${VERSION#*=}"
	if [ "$VERSION" != "$PKG_VER" ] && [ "$VERSION" ]; then
		err "version mismatch (installed:${VERSION}, module:$PKG_VER)"
		return
	fi
	mz grep "$PKG_NAME" /proc/mounts | while read -r line; do
		mp=${line#* } mp=${mp%% *}
		mz umount -l "${mp%%\\*}"
	done
	if ! chcon u:object_r:apk_data_file:s0 "$RVPATH"; then
		err "apk not found"
		return
	fi
	$HAS_SUSFS && ksu_susfs add_sus_kstat "$BASEPATH"
	[ -n "$BASEPATH" ] && mz mount "$RVPATH" "$BASEPATH/base.apk"
	$HAS_SUSFS && ksu_susfs update_sus_kstat "$BASEPATH"
	$HAS_SUSFS && ksu_susfs add_sus_mount "$BASEPATH"
	am force-stop "$PKG_NAME"
	[ -f "$MODDIR/err" ] && mv -f "$MODDIR/err" "$MODDIR/module.prop"
}

run
