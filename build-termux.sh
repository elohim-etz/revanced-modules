#!/usr/bin/env bash

set -e

pr() { echo -e "\033[0;32m[+] ${1}\033[0m"; }
ask() {
	local y
	for ((n = 0; n < 3; n++)); do
		pr "$1 [y/n]"
		if read -r y; then
			if [ "$y" = y ]; then
				return 0
			elif [ "$y" = n ]; then
				return 1
			fi
		fi
		pr "Asking again..."
	done
	return 1
}

pr "Ask for storage permission"
until
	yes | termux-setup-storage >/dev/null 2>&1
	ls /sdcard >/dev/null 2>&1
do sleep 1; done
if [ ! -f ~/.rvmm_"$(date '+%Y%m')" ]; then
	pr "Setting up environment..."
	yes "" | pkg update -y && pkg upgrade -y && pkg install -y git curl jq openjdk-17 zip
	: >~/.rvmm_"$(date '+%Y%m')"
fi
mkdir -p /sdcard/Download/morphe-builder/

if [ -d morphe-builder ] || [ -f config.toml ]; then
	if [ -d morphe-builder ]; then cd morphe-builder; fi
	pr "Checking for morphe-builder updates"
	git fetch
	if git status | grep -q 'is behind\|fatal'; then
		pr "morphe-builder is not synced with upstream."
		pr "Cloning morphe-builder. config.toml will be preserved."
		cd ..
		cp -f morphe-builder/config.toml .
		rm -rf morphe-builder
		git clone https://github.com/elohim-etz/morphe-builder --recurse --depth 1
		mv -f config.toml morphe-builder/config.toml
		cd morphe-builder
	fi
else
	pr "Cloning morphe-builder."
	git clone https://github.com/elohim-etz/morphe-builder --depth 1
	cd morphe-builder
	sed -i '/^enabled.*/d; /^\[.*\]/a enabled = false' config.toml
	grep -q 'morphe-builder' ~/.gitconfig 2>/dev/null ||
		git config --global --add safe.directory ~/morphe-builder
fi

[ -f ~/storage/downloads/morphe-builder/config.toml ] ||
	cp config.toml ~/storage/downloads/morphe-builder/config.toml

if ask "Open rvmm-config-gen to generate a config?"; then
	am start -a android.intent.action.VIEW -d https://j-hc.github.io/rvmm-config-gen/
fi
printf "\n"
until
	if ask "Open 'config.toml' to configure builds?\nAll are disabled by default, you will need to enable at first time building"; then
		am start -a android.intent.action.VIEW -d file:///sdcard/Download/morphe-builder/config.toml -t text/plain
	fi
	ask "Setup is done. Do you want to start building?"
do :; done
cp -f ~/storage/downloads/morphe-builder/config.toml config.toml

./build.sh

cd build
PWD=$(pwd)
for op in *; do
	[ "$op" = "*" ] && {
		pr "glob fail"
		exit 1
	}
	mv -f "${PWD}/${op}" ~/storage/downloads/morphe-builder/"${op}"
done

pr "Outputs are available in /sdcard/Download/morphe-builder folder"
am start -a android.intent.action.VIEW -d file:///sdcard/Download/morphe-builder -t resource/folder
sleep 2
am start -a android.intent.action.VIEW -d file:///sdcard/Download/morphe-builder -t resource/folder
