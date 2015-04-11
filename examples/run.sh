#!/bin/bash
# Source https://github.com/cadorn/bash.origin
. "$BO_PACKAGES_DIR/github.com~bash-origin~bash.origin~0~source/bash.origin"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	local __BO_DIR__="$___TMP___"

	function runExample {

		local EXAMPLE_NAME="$1"
		local EXAMPLE_DIR="$__BO_DIR__/$EXAMPLE_NAME"

		local DIFFERENT="0"

		pushd "$EXAMPLE_DIR" > /dev/null
			if [ ! -e ".packages" ]; then
				ln -s "../../.packages" ".packages"
			fi

			"../../.pgs/pgs.sh" install ${*:2}

			if [ ! -d ".result" ]; then
				mkdir ".result"
			fi

			export PGS_WORKSPACE_UID="uid-$EXAMPLE_NAME"
			export PGS_BOOT_TO="turn"
			"./boot" ${*:2} > ".result/actual.log" 2>&1

			cp -f "program.rt.json" ".result/actual.json"

			# TODO: Display this much better

			if [ ! -f ".result/expected.log" ]; then
				cp ".result/actual.log" ".result/expected.log"
			fi
			diff -Naur ".result/expected.log" ".result/actual.log" > /dev/null
			if [ $? -eq 1 ]; then
				DIFFERENT="1"
				echo "Output has changed!"
				echo "##############################"
				diff -Naur ".result/expected.log" ".result/actual.log"
				echo "##############################"
			fi

			if [ ! -f ".result/expected.json" ]; then
				cp ".result/actual.json" ".result/expected.json"
			fi
			diff -Naur ".result/expected.json" ".result/actual.json" > /dev/null
			if [ $? -eq 1 ]; then
				DIFFERENT="1"
				echo "Runtime config has changed!"
				echo "##############################"
				diff -Naur ".result/expected.json" ".result/actual.json"
				echo "##############################"
			fi

			"$EXAMPLE_DIR/bin/clean" ${*:2}
			rm "$EXAMPLE_DIR/.packages"
		popd > /dev/null

		if [ "$DIFFERENT" == "1" ]; then
			exit 1
		fi;
	}

	runExample "01-HelloWorld" $@
}
init $@