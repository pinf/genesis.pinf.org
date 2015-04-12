#!/bin/bash
# Source https://github.com/cadorn/bash.origin
. "$BO_PACKAGES_DIR/github.com~bash-origin~bash.origin~0~source/bash.origin"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	local __BO_DIR__="$___TMP___"


	BO_sourcePrototype "$__BO_DIR__/../.pgs/pgs.sh"


#	runExample "$__BO_DIR__/01-HelloWorld" $@
#	runExample "$__BO_DIR__/02-Sub-System" $@
	runExample "$__BO_DIR__/03-DeveloperCompanion" $@

}
init $@