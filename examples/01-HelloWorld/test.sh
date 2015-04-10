#!/bin/bash
# Source https://github.com/cadorn/bash.origin
. "$BO_PACKAGES_DIR/github.com~bash-origin~bash.origin~0~source/bash.origin"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	local __BO_DIR__="$___TMP___"

	pushd "$__BO_DIR__"
		"$__BO_DIR__/../../.pgs/pgs.sh" install
	popd
}
init $@