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

	function boot {

#		sed "s|%%EXTENDS%%|[\"$TPL_PATH\"]|g" "$TPL_PATH/program.json.tpl" > "$TARGET_PATH/program.json"
#		perl -pi -e "s/\%\%UID\%\%/$SYSTEM_UID/g" "$TARGET_PATH/program.json"
#echo "BASENAME: `BO_run_node --eval 'process.stdout.write(require("'$TARGET_PATH'/program.json").config["genesis.pinf.org/0"].basename);'`"

		# TODO: Detect if booting self or booting another package.
		bootSelf
	}

	function bootSelf {

		format "HEADER" "Turning template"

		pushd "$__BO_DIR__/.pgs"
			export PGS_SYSTEM_ROOT="$__BO_DIR__"
			BO_callPlugin "/genesis.live/open-source/codi.sh/node_modules/bash.origin.pinf/bash.origin.pinf" pto turn -vd
		popd

		format "HEADER" "Turning system"

		pushd "$__BO_DIR__"
			BO_callPlugin "/genesis.live/open-source/codi.sh/node_modules/bash.origin.pinf/bash.origin.pinf" pto turn -vd
		popd

		format "FOOTER"
	}

	function signalDone {
		echo "BOOT DONE"
	}


	boot
	signalDone
}
init @$