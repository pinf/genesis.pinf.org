#!/bin/bash
# Source https://github.com/cadorn/bash.origin
. "$HOME/.bash.origin"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	local __BO_DIR__="$___TMP___"

	function format {
		if [ "$1" == "HEADER" ]; then
			echo "##################################################";
			echo "# $2";
			echo "##################################################";
		fi
		if [ "$1" == "FOOTER" ]; then
			echo "##################################################";
			echo ""
		fi
	}

	function install {
		format "HEADER" "Installing PINF.Genesis System"

		local TARGET_PATH="$1"

		echo "Ensuring ignore file: $TARGET_PATH/.gitignore"
		if [ ! -f "$TARGET_PATH/.gitignore" ]; then
			echo "Create ignore file: $TARGET_PATH/.gitignore"
			touch "$TARGET_PATH/.gitignore"
		fi
		if ! grep -qe "^\/node_modules\/$" "$TARGET_PATH/.gitignore"; then
			echo "Append '/node_modules/' to ignore file: $TARGET_PATH/.gitignore"
			# TODO: Do a cleaner append
		    echo -e "\n/node_modules/" >> "$TARGET_PATH/.gitignore"
		fi
		if ! grep -qe "^\/.packages\/$" "$TARGET_PATH/.gitignore"; then
			echo "Append '/.packages/' to ignore file: $TARGET_PATH/.gitignore"
			# TODO: Do a cleaner append
		    echo -e "\n/.packages/" >> "$TARGET_PATH/.gitignore"
		fi
		if ! grep -qe "^\/boot$" "$TARGET_PATH/.gitignore"; then
			echo "Append '/boot' to ignore file: $TARGET_PATH/.gitignore"
			# TODO: Do a cleaner append
		    echo -e "\n/boot" >> "$TARGET_PATH/.gitignore"
		fi
		if ! grep -qe "^\/\.pgs\/$" "$TARGET_PATH/.gitignore"; then
			echo "Append '/.pgs/' to ignore file: $TARGET_PATH/.gitignore"
			# TODO: Do a cleaner append
		    echo -e "\n/.pgs/" >> "$TARGET_PATH/.gitignore"
		fi

		echo "Copying boot file to: $TARGET_PATH/boot"
		cp -f "$__BO_DIR__/../boot" "$TARGET_PATH/boot"
		chmod ug+x "$TARGET_PATH/boot"

		echo "Copying PINF.Genesis System to: $TARGET_PATH/.pgs"
		rsync -a --exclude-from="$__BO_DIR__/.rsyncignore" "$__BO_DIR__/" "$TARGET_PATH/.pgs/"

		echo "Copy done!"

		echo ""

		echo "  Action: You can now run './boot' to boot the system!"

		echo ""

		format "FOOTER"
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

		export PTO_USE_EXISTING_PGS_PINF_DIRPATH="1"

		format "HEADER" "Expanding PINF.Genesis System"

		local PREVIOUS_PGS_PINF_DIRPATH="$PGS_PINF_DIRPATH"

		pushd "$PGS_DIR"
			export PGS_PINF_DIRPATH="$PGS_DIR/.pinf"
			BO_callPlugin "github.com~bash-origin~bash.origin.pinf~0~source/bash.origin.pinf" pto turn $@
			export PGS_WORKSPACE_UID="`cat "$PREVIOUS_PGS_PINF_DIRPATH/uid"`"
		popd

		export PGS_PINF_DIRPATH="$PREVIOUS_PGS_PINF_DIRPATH"
	}

	function pgsSpin {

		export PTO_USE_EXISTING_PGS_PINF_DIRPATH="1"

		# TODO: Remove this once turning happens automatically on first spin.
		format "HEADER" "Turning system"
		pushd "$PGS_WORKSPACE_ROOT"
			BO_callPlugin "github.com~bash-origin~bash.origin.pinf~0~source/bash.origin.pinf" pto turn $@
		popd

		format "HEADER" "Spinning system"
		pushd "$PGS_WORKSPACE_ROOT"
			BO_callPlugin "github.com~bash-origin~bash.origin.pinf~0~source/bash.origin.pinf" pto spin $@
		popd

		format "FOOTER"
	}
}
init $@