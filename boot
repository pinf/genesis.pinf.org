#!/bin/bash
if [ -z "$HOME" ]; then
	echo "ERROR: 'HOME' environment variable is not set!"
	exit 1
fi
# Source https://github.com/cadorn/bash.origin
# NOTE: Setting up Bash.Origin is the ONLY SEQUENCE that MODIFIES OUTSIDE of the 'PGS_WORKSPACE_ROOT'!
export BO_ROOT_SCRIPT_PATH="$HOME/.bash.origin"
if [ ! -f "$BO_ROOT_SCRIPT_PATH" ]; then
	# Not installed so we need to download & install.
    # TODO: Alternatively use `wget`
    curl "https://raw.githubusercontent.com/bash-origin/bash.origin/master/bash.origin?t=$(date +%s)" | BO="install" sh
fi
. "$BO_ROOT_SCRIPT_PATH"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	local __BO_DIR__="$___TMP___"


	# Seed the PINF.Genesis System
	export PGS_WORKSPACE_ROOT="$__BO_DIR__"
	export PGS_PINF_DIRPATH="$PGS_WORKSPACE_ROOT/.pinf"
	export PGS_WORKSPACE_PINF_DIRPATH="$PGS_PINF_DIRPATH"
	export PGS_PACKAGES_DIRPATH="$PGS_WORKSPACE_ROOT/.deps"
	export BO_PACKAGES_DIR="$PGS_PACKAGES_DIRPATH"
	export BO_SYSTEM_CACHE_DIR="$BO_PACKAGES_DIR"


	if [ -f "$BO_PACKAGES_DIR/github.com~bash-origin~bash.origin~0/source/installed/master/bash.origin" ]; then
		# Use OUR Bash.Origin script from now on (even to handle the install if the previously
		# installed version supports delegation).
		export BO_ROOT_SCRIPT_PATH="$BO_PACKAGES_DIR/github.com~bash-origin~bash.origin~0/source/installed/master/bash.origin"
		"$BO_ROOT_SCRIPT_PATH" BO install > /dev/null
	fi
	. "$BO_ROOT_SCRIPT_PATH"


 	BO_checkVerbose "VERBOSE" "$@"


	BO_sourcePrototype "$__BO_DIR__/.pgs/pgs.sh" "boot"


	if [ "$1" == "activate" ]; then
		return 0
	fi

	# We always need to expand the PGS system to ensure all minimal code is in position.
	pgsExpand

	if [ -e "$PGS_WORKSPACE_ROOT/.call.on.provisioned" ]; then
		# Remove provisioned flag for now until we have called all scripts.
		local SCRIPT=`cat "$PGS_WORKSPACE_ROOT/.call.on.provisioned"`
		BO_log "$VERBOSE" "Found install trigger '$SCRIPT' at '$PGS_WORKSPACE_ROOT/.call.on.provisioned'"
		$SCRIPT
		if [[ $? != 0 ]]; then
			# We had an error so we ensure the install runs again.
			rm -f "$__BO_DIR__/.pgs/.provisioned"
		fi
		rm -f "$PGS_WORKSPACE_ROOT/.call.on.provisioned"
	fi

	if [ "$1" == "expand" ]; then
		return 0
	fi

	if [ "$1" == "turn" ]; then
		pgsTurn ${*:2}
	else
		if [ "$PGS_BOOT_TO" == "turn" ]; then
			pgsTurn $@
		else
			pgsSpin $@
		fi
	fi
}
init $@