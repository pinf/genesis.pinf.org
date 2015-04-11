#!/bin/bash
# Source https://github.com/cadorn/bash.origin
. "$BO_PACKAGES_DIR/github.com~bash-origin~bash.origin~0~source/bash.origin"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	local __BO_DIR__="$___TMP___"

	pushd "$__BO_DIR__"
		if [ ! -e "$__BO_DIR__/.packages" ]; then
			ln -s "../../.packages" "$__BO_DIR__/.packages"
		fi
		"$__BO_DIR__/../../.pgs/pgs.sh" install
		export PGS_BOOT_TO="turn"
		"$__BO_DIR__/boot" $@
		cp -f "$__BO_DIR__/program.rt.json" "$__BO_DIR__/result.json"
		"$__BO_DIR__/bin/clean"
		rm "$__BO_DIR__/.packages"
	popd
}
init $@