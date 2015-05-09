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
	# TODO: Deprecate PGS_WORKSPACE_PINF_DIRPATH
	export PGS_WORKSPACE_PINF_DIRPATH="$PGS_WORKSPACE_ROOT/.pinf"
	export PGS_PINF_DIRPATH="$PGS_WORKSPACE_PINF_DIRPATH"
	export PGS_PACKAGES_DIRPATH="$PGS_WORKSPACE_ROOT/.deps"
	export BO_PACKAGES_DIR="$PGS_PACKAGES_DIRPATH"
	export BO_SYSTEM_CACHE_DIR="$BO_PACKAGES_DIR"
	export PIO_PROFILE_PATH="$__BO_DIR__/../$(basename $__BO_DIR__).profile.json"


	if [ -f "$BO_PACKAGES_DIR/github.com~bash-origin~bash.origin~0/source/installed/master/bash.origin" ]; then
		# Use OUR Bash.Origin script from now on (even to handle the install if the previously
		# installed version supports delegation).
		export BO_ROOT_SCRIPT_PATH="$BO_PACKAGES_DIR/github.com~bash-origin~bash.origin~0/source/installed/master/bash.origin"
		"$BO_ROOT_SCRIPT_PATH" BO install > /dev/null
	fi
	. "$BO_ROOT_SCRIPT_PATH"


 	BO_checkVerbose "VERBOSE" "$@"


 	function activateExpanded {
		if [ -e "$PGS_PINF_DIRPATH/uid" ]; then
			export PGS_WORKSPACE_UID="`cat "$PGS_PINF_DIRPATH/uid"`"
			export PIO_PROFILE_KEY="$PGS_WORKSPACE_UID"
		fi
		if [ -e "$__BO_DIR__/../$(basename $__BO_DIR__).activate.sh" ]; then
			BO_sourcePrototype "$__BO_DIR__/../$(basename $__BO_DIR__).activate.sh"
		fi
 	}


	BO_sourcePrototype "$__BO_DIR__/.pgs/pgs.sh" "boot"
 	activateExpanded


	if [ "$1" == "activate" ]; then
		return 0
	fi

	# We always need to expand the PGS system to ensure all minimal code is in position.
	pgsExpand
	# We call it again to updated any changes after expansion.
	activateExpanded

	function linkDependencies {
		if [ ! -e "$__BO_DIR__/.pgs/.provisioned" ]; then
			return 0
		fi
		# If a global dependency is present but not linked for the source installed aspect
		# we link ours into the global namespace. We also link ours if it does not exist at all.

		function linkDependency {
			if [ ! -e "$1" ]; then
				# We don't include the source for 'bash.origin'.
				return 0;
			fi
			if [ ! -e "$2" ]; then
				rm -Rf "$2" > /dev/null || true
			fi
			if [ -L "$2" ]; then
				# Already a symlink so we leave it alone.
				return 0
			fi
			# Replace file with symlink
			rm -Rf "$2" > /dev/null || true
			BO_log "$VERBOSE" "Linking '$1' to '$2'"
			if [ ! -d "$(dirname "$2")" ]; then
				mkdir -p "$(dirname "$2")"
			fi
			ln -s "$1" "$2"
		}
		linkDependency "$__BO_DIR__/../.deps/github.com~bash-origin~bash.origin~0/source/installed/master/bash.origin" "$HOME/.bash.origin"

		# TODO: Use configurable base directory instead of assuming '$HOME'.
		if [ ! -e "$HOME/.bash.origin.cache" ]; then
			mkdir "$HOME/.bash.origin.cache"
		fi
		if [ -e "$PGS_WORKSPACE_ROOT/package.json" ]; then
			if grep -q -e '"name": "genesis.pinf.org"' "$PGS_WORKSPACE_ROOT/package.json"; then
				linkDependency "$__BO_DIR__/.." "$HOME/.bash.origin.cache/github.com~pinf~genesis.pinf.org~0/source/installed/master"
			fi
		fi
		for dir in "$__BO_DIR__/.deps/"* ; do
			dir="$(basename $dir)"
			if [ -e "$__BO_DIR__/.deps/$dir/source/installed/master" ]; then
				linkDependency "$__BO_DIR__/.deps/$dir/source/installed/master" "$HOME/.bash.origin.cache/$dir/source/installed/master"
			fi
		done
	}
	linkDependencies

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