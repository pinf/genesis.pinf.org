#!/bin/bash
# Source https://github.com/cadorn/bash.origin
if [ ! -f "$HOME/.bash.origin" ]; then
	echo "ERROR: Run 'boot' at least once first!"
	exit 1;
fi
. "$HOME/.bash.origin"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	local __BO_DIR__="$___TMP___"


	export PGS_BOOT_TO="turn"
	if [ ! -f "$__BO_DIR__/../program.rt.json" ]; then
		BO_sourcePrototype "$__BO_DIR__/../boot" $@
	else
		BO_sourcePrototype "$__BO_DIR__/../boot" $@ > /dev/null 2>&1
	fi
	export PGS_BOOT_TO=""


	runExample "$__BO_DIR__/01-HelloWorld" $@
#	runExample "$__BO_DIR__/02-Sub-System" $@
#	runExample "$__BO_DIR__/03-DeveloperCompanion" $@

}
init $@