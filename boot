#!/bin/bash
# Source https://github.com/cadorn/bash.origin
if [ ! -f "$HOME/.bash.origin" ]; then
    # TODO: Alternatively use `wget`
    curl "https://raw.githubusercontent.com/bash-origin/bash.origin/master/bash.origin?t=$(date +%s)" | BO="install" sh
fi
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

		local TARGET_PATH="`pwd`"

		if [ -f "$TARGET_PATH/boot" ]; then
			if [ "$1" != "-f" ]; then
				echo "ERROR: Cannot install. File already exists: $TARGET_PATH/boot"
				exit 1
			fi
		fi

		echo "Ensuring ignore file: $TARGET_PATH/.gitignore"
		if [ ! -f "$TARGET_PATH/.gitignore" ]; then
			echo "Create ignore file: $TARGET_PATH/.gitignore"
			touch "$TARGET_PATH/.gitignore"
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
		cp -f "$__BO_DIR__/boot" "$TARGET_PATH/boot"
		chmod ug+x "$TARGET_PATH/boot"

		echo "Copying PINF.Genesis System to: $TARGET_PATH/.pgs"
		rsync -a --exclude-from="$__BO_DIR__/.pgs/.rsyncignore" "$__BO_DIR__/.pgs/" "$TARGET_PATH/.pgs/"

		echo "Copy done!"

		echo ""

		echo "  Action: You can now run './boot' to boot the system!"

		echo ""

		format "FOOTER"
	}

	function boot {

#		sed "s|%%EXTENDS%%|[\"$TPL_PATH\"]|g" "$TPL_PATH/program.json.tpl" > "$TARGET_PATH/program.json"
#		perl -pi -e "s/\%\%UID\%\%/$SYSTEM_UID/g" "$TARGET_PATH/program.json"
#echo "BASENAME: `BO_run_node --eval 'process.stdout.write(require("'$TARGET_PATH'/program.json").config["genesis.pinf.org/0"].basename);'`"

		# TODO: Detect if booting self or booting another package.
		bootSelf $@
	}

	function bootSelf {

		format "HEADER" "Turning template"

		pushd "$__BO_DIR__/.pgs"
			# Seed the PINF.Genesis System
			export PGS_WORKSPACE_ROOT="$__BO_DIR__"
			export PGS_PINF_DIR=".pinf"
			export PGS_PACKAGES_DIR=".packages"
			BO_callPlugin "/genesis.live/open-source/codi.sh/node_modules/bash.origin.pinf/bash.origin.pinf" pto turn $@
			export PGS_WORKSPACE_UID="`cat "$PGS_PINF_ROOT/uid"`"
		popd

		format "HEADER" "Turning system"

		pushd "$__BO_DIR__"
			BO_callPlugin "/genesis.live/open-source/codi.sh/node_modules/bash.origin.pinf/bash.origin.pinf" pto turn $@
		popd

		format "HEADER" "Spinning system"

		pushd "$__BO_DIR__"
			BO_callPlugin "/genesis.live/open-source/codi.sh/node_modules/bash.origin.pinf/bash.origin.pinf" pto spin $@
		popd

		format "FOOTER"
	}

	function signalDone {
		echo "BOOT DONE"
	}


	if [ "$1" == "install" ]; then
		install "$2"
	else
		boot $@
	fi
	signalDone
}
init $@