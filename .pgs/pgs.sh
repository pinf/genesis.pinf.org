#!/bin/bash
# Source https://github.com/cadorn/bash.origin
. "$HOME/.bash.origin"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	local __BO_DIR__="$___TMP___"

	function format {
		if [ "$1" != "1" ]; then
			return;
		fi
		if [ "$2" == "HEADER" ]; then
			echo "##################################################";
			echo "# $3";
			echo "##################################################";
		fi
		if [ "$2" == "FOOTER" ]; then
			echo "##################################################";
			echo ""
		fi
	}

	function log {
		if [ "$1" != "1" ]; then
			return;
		fi
		echo ${*:2}
	}

	function install {
		BO_checkVerbose "VERBOSE" "$@"

		format "$VERBOSE" "HEADER" "Installing PINF.Genesis System"

		local TARGET_PATH="$1"

		log "$VERBOSE" "Ensuring ignore file: $TARGET_PATH/.gitignore"
		if [ ! -f "$TARGET_PATH/.gitignore" ]; then
			log "$VERBOSE" "Create ignore file: $TARGET_PATH/.gitignore"
			touch "$TARGET_PATH/.gitignore"
		fi
		if ! grep -qe "^\/node_modules\/$" "$TARGET_PATH/.gitignore"; then
			log "$VERBOSE" "Append '/node_modules/' to ignore file: $TARGET_PATH/.gitignore"
			# TODO: Do a cleaner append
		    echo -e "\n/node_modules/" >> "$TARGET_PATH/.gitignore"
		fi
		if ! grep -qe "^\/.packages\/$" "$TARGET_PATH/.gitignore"; then
			log "$VERBOSE" "Append '/.packages/' to ignore file: $TARGET_PATH/.gitignore"
			# TODO: Do a cleaner append
		    echo -e "\n/.packages/" >> "$TARGET_PATH/.gitignore"
		fi
		if ! grep -qe "^\/boot$" "$TARGET_PATH/.gitignore"; then
			log "$VERBOSE" "Append '/boot' to ignore file: $TARGET_PATH/.gitignore"
			# TODO: Do a cleaner append
		    echo -e "\n/boot" >> "$TARGET_PATH/.gitignore"
		fi
		if ! grep -qe "^\/\.pgs\/$" "$TARGET_PATH/.gitignore"; then
			log "$VERBOSE" "Append '/.pgs/' to ignore file: $TARGET_PATH/.gitignore"
			# TODO: Do a cleaner append
		    echo -e "\n/.pgs/" >> "$TARGET_PATH/.gitignore"
		fi

		log "$VERBOSE" "Copying boot file to: $TARGET_PATH/boot"
		cp -f "$__BO_DIR__/../boot" "$TARGET_PATH/boot"
		chmod ug+x "$TARGET_PATH/boot"

		log "$VERBOSE" "Copying PINF.Genesis System to: $TARGET_PATH/.pgs"
		rsync -a --exclude-from="$__BO_DIR__/.rsyncignore" "$__BO_DIR__/" "$TARGET_PATH/.pgs/"

		log "$VERBOSE" "Copy done!"

		log "$VERBOSE" "Action: You can now run './boot' to boot the system!"

		format "$VERBOSE" "FOOTER"
	}

	if [ "$1" == "install" ]; then		
		install "`pwd`" ${*:2}
		return;
	fi

	# The rest is used when sourcing into a boot file. See '../boot'.

	if [ -z "$PGS_PINF_DIRPATH" ]; then
		echo "ERROR: 'PGS_PINF_DIRPATH' environment variable is not set (file: $__BO_DIR__/pgs.sh)!"
		exit 1
	fi
	if [ -z "$PGS_PACKAGES_DIRPATH" ]; then
		echo "ERROR: 'PGS_PACKAGES_DIRPATH' environment variable is not set (file: $__BO_DIR__/pgs.sh)!"
		exit 1
	fi
	if [ -z "$PGS_WORKSPACE_ROOT" ]; then
		echo "ERROR: 'PGS_WORKSPACE_ROOT' environment variable is not set (file: $__BO_DIR__/pgs.sh)!"
		exit 1
	fi
	if [ -z "$PGS_WORKSPACE_PINF_DIRPATH" ]; then
		echo "ERROR: 'PGS_WORKSPACE_PINF_DIRPATH' environment variable is not set (file: $__BO_DIR__/pgs.sh)!"
		exit 1
	fi
	if [ -z "$BO_PACKAGES_DIR" ]; then
		echo "ERROR: 'BO_PACKAGES_DIR' environment variable is not set (file: $__BO_DIR__/pgs.sh)!"
		exit 1
	fi

	PGS_DIR="$__BO_DIR__"

	function pgsExpand {
		BO_checkVerbose "VERBOSE" "$@"
		export PTO_USE_EXISTING_PGS_PINF_DIRPATH="1"
		local PREVIOUS_PGS_PINF_DIRPATH="$PGS_PINF_DIRPATH"
		format "$VERBOSE" "HEADER" "Expanding PINF.Genesis System"
		pushd "$PGS_DIR" > /dev/null
			export PGS_PINF_DIRPATH="$PGS_DIR/.pinf"
			BO_callPlugin "github.com~bash-origin~bash.origin.pinf~0~source/bash.origin.pinf" pto turn $@
			export PGS_WORKSPACE_UID="`cat "$PREVIOUS_PGS_PINF_DIRPATH/uid"`"
		popd > /dev/null
		format "$VERBOSE" "FOOTER"
		export PGS_PINF_DIRPATH="$PREVIOUS_PGS_PINF_DIRPATH"
	}

	function pgsTurn {
		BO_checkVerbose "VERBOSE" "$@"
		export PTO_USE_EXISTING_PGS_PINF_DIRPATH="1"
		# TODO: Remove this once turning happens automatically on first spin.
		format "$VERBOSE" "HEADER" "Turning system"
		pushd "$PGS_WORKSPACE_ROOT" > /dev/null
			BO_callPlugin "github.com~bash-origin~bash.origin.pinf~0~source/bash.origin.pinf" pto turn $@
		popd > /dev/null
		format "$VERBOSE" "FOOTER"
	}

	function pgsSpin {
		BO_checkVerbose "VERBOSE" "$@"
		export PTO_USE_EXISTING_PGS_PINF_DIRPATH="1"
		format "$VERBOSE" "HEADER" "Spinning system"
		pushd "$PGS_WORKSPACE_ROOT" > /dev/null
			BO_callPlugin "github.com~bash-origin~bash.origin.pinf~0~source/bash.origin.pinf" pto spin $@
		popd > /dev/null
		format "$VERBOSE" "FOOTER"
	}
}
init $@