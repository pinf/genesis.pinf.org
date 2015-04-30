#!/bin/bash
# Source https://github.com/cadorn/bash.origin
. "$HOME/.bash.origin"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	PGS_DIR="$___TMP___"

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

	function install {
		BO_checkVerbose "VERBOSE" "$@"

		format "$VERBOSE" "HEADER" "Installing PINF.Genesis System"

		local TARGET_PATH="$1"

		BO_log "$VERBOSE" "Ensuring ignore file: $TARGET_PATH/.gitignore"
		if [ ! -f "$TARGET_PATH/.gitignore" ]; then
			BO_log "$VERBOSE" "Create ignore file: $TARGET_PATH/.gitignore"
			touch "$TARGET_PATH/.gitignore"
		fi
		if ! grep -qe "^\/node_modules\/$" "$TARGET_PATH/.gitignore"; then
			BO_log "$VERBOSE" "Append '/node_modules/' to ignore file: $TARGET_PATH/.gitignore"
			# TODO: Do a cleaner append
		    echo -e "\n/node_modules/" >> "$TARGET_PATH/.gitignore"
		fi
		if ! grep -qe "^\/.deps$" "$TARGET_PATH/.gitignore"; then
			BO_log "$VERBOSE" "Append '/.deps' to ignore file: $TARGET_PATH/.gitignore"
			# TODO: Do a cleaner append
		    echo -e "\n/.deps" >> "$TARGET_PATH/.gitignore"
		fi
		if ! grep -qe "^\/boot$" "$TARGET_PATH/.gitignore"; then
			BO_log "$VERBOSE" "Append '/boot' to ignore file: $TARGET_PATH/.gitignore"
			# TODO: Do a cleaner append
		    echo -e "\n/boot" >> "$TARGET_PATH/.gitignore"
		fi
		if ! grep -qe "^\/\.pgs$" "$TARGET_PATH/.gitignore"; then
			BO_log "$VERBOSE" "Append '/.pgs' to ignore file: $TARGET_PATH/.gitignore"
			# TODO: Do a cleaner append
		    echo -e "\n/.pgs" >> "$TARGET_PATH/.gitignore"
		fi

		BO_log "$VERBOSE" "Copying boot file to: $TARGET_PATH/boot"
		cp -f "$PGS_DIR/../boot" "$TARGET_PATH/boot"
		chmod ug+x "$TARGET_PATH/boot"

		BO_log "$VERBOSE" "Copying PINF.Genesis System to: $TARGET_PATH/.pgs"
		rsync -a --exclude-from="$PGS_DIR/.rsyncignore" "$PGS_DIR/" "$TARGET_PATH/.pgs/"

		BO_log "$VERBOSE" "Copy done!"

		BO_log "$VERBOSE" "Action: You can now run './boot' to boot the system!"

		format "$VERBOSE" "FOOTER"
	}

	function runExample {

		BO_checkVerbose "VERBOSE" "$@"

		local EXAMPLE_DIR="$1"
		local EXAMPLE_NAME="$(basename "$EXAMPLE_DIR")"

		format "$VERBOSE" "HEADER" "Run example $EXAMPLE_NAME"

		local DIFFERENT="0"

		pushd "$EXAMPLE_DIR" > /dev/null
			if [ ! -e ".deps" ]; then
				ln -s "../../.deps" ".deps"
			fi

			install "$EXAMPLE_DIR" ${*:2}

			local FIRST_RUN="0"
			if [ ! -d ".result" ]; then
				FIRST_RUN="1"
				mkdir ".result"
			fi

			export PGS_WORKSPACE_UID="UID-$EXAMPLE_NAME"
			export PGS_BOOT_TO="turn"

			if [ "$VERBOSE" == "1" ]; then

				"./boot" ${*:2}

			else

				"./boot" ${*:2} > ".result/actual.log" 2>&1

				cp -f "program.rt.json" ".result/actual.json"

				# TODO: Display this much better

				if [ ! -f ".result/expected.log" ]; then
					FIRST_RUN="1"
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
					FIRST_RUN="1"
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

				if [ "$DIFFERENT" == "0" ]; then
					"$EXAMPLE_DIR/bin/clean" ${*:2}
					rm -Rf ".deps" "node_modules" ".installed"
				fi

				if [ "$FIRST_RUN" == "1" ]; then
					format "1" "HEADER" "First run output"
					cat ".result/actual.log"
				fi
			fi
		popd > /dev/null

		if [ "$DIFFERENT" == "1" ]; then
			exit 1
		fi;

		format "$VERBOSE" "FOOTER"
	}

	if [ "$1" == "install" ]; then		
		install "`pwd`" ${*:2}
		return;
	fi

	# The rest is used when sourcing into a boot file. See '../boot'.
	if [ "$1" != "boot" ]; then		
		return;
	fi
	if [ -z "$PGS_PINF_DIRPATH" ]; then
		echo "ERROR: 'PGS_PINF_DIRPATH' environment variable is not set (file: $PGS_DIR/pgs.sh)!"
		exit 1
	fi
	if [ -z "$PGS_PACKAGES_DIRPATH" ]; then
		echo "ERROR: 'PGS_PACKAGES_DIRPATH' environment variable is not set (file: $PGS_DIR/pgs.sh)!"
		exit 1
	fi
	if [ -z "$PGS_WORKSPACE_ROOT" ]; then
		echo "ERROR: 'PGS_WORKSPACE_ROOT' environment variable is not set (file: $PGS_DIR/pgs.sh)!"
		exit 1
	fi
	if [ -z "$PGS_WORKSPACE_PINF_DIRPATH" ]; then
		echo "ERROR: 'PGS_WORKSPACE_PINF_DIRPATH' environment variable is not set (file: $PGS_DIR/pgs.sh)!"
		exit 1
	fi
	if [ -z "$BO_PACKAGES_DIR" ]; then
		echo "ERROR: 'BO_PACKAGES_DIR' environment variable is not set (file: $PGS_DIR/pgs.sh)!"
		exit 1
	fi
	export PGS_DIRPATH="$PGS_DIR"

	function pgsExpand {
		BO_checkVerbose "VERBOSE" "$@"
		export PTO_USE_EXISTING_PGS_PINF_DIRPATH="1"
		local PREVIOUS_PGS_PINF_DIRPATH="$PGS_PINF_DIRPATH"
		format "$VERBOSE" "HEADER" "Expanding PINF.Genesis System"
		pushd "$PGS_DIR" > /dev/null
			export PGS_PINF_DIRPATH="$PGS_DIR/.pinf"
			BO_callPlugin "github.com~bash-origin~bash.origin.pinf~0/source/vcs/master/bash.origin.pinf" pto turn $@
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
			BO_callPlugin "github.com~bash-origin~bash.origin.pinf~0/source/vcs/master/bash.origin.pinf" pto turn $@
		popd > /dev/null
		format "$VERBOSE" "FOOTER"
	}

	function pgsSpin {
		BO_checkVerbose "VERBOSE" "$@"
		export PTO_USE_EXISTING_PGS_PINF_DIRPATH="1"
		format "$VERBOSE" "HEADER" "Spinning system"
		pushd "$PGS_WORKSPACE_ROOT" > /dev/null
			BO_callPlugin "github.com~bash-origin~bash.origin.pinf~0/source/vcs/master/bash.origin.pinf" pto spin $@
		popd > /dev/null
		format "$VERBOSE" "FOOTER"
	}

	function ensureProvisioned {
		BO_checkVerbose "VERBOSE" "$@"
		format "$VERBOSE" "HEADER" "Provisioning base system"
		pushd "$PGS_DIR/.." > /dev/null
		if [ -f ".gitmodules" ]; then
			if [ ! -f ".gitmodules.initialized" ]; then
				BO_log "$VERBOSE" "Init submodules ..."
#				git submodule update --init --recursive --rebase
				BO_log "$VERBOSE" "... submodules init done"
				touch ".gitmodules.initialized"
			else
				BO_log "$VERBOSE" "Skip init submodules. Already initialized."
			fi
		fi
		if [ ! -f ".installed" ]; then
			BO_isInSystemCache "SMI_BASE_PATH" "github.com/sourcemint/smi" "0.x"
			if [ ! -e "$SMI_BASE_PATH/.installed" ]; then
				BO_log "$VERBOSE" "Install smi ..."
				pushd "$SMI_BASE_PATH" > /dev/null
					BO_run_npm install --production $@
					touch "$SMI_BASE_PATH/.installed"
				popd > /dev/null
				BO_log "$VERBOSE" "... smi install done"
			fi
			pushd "$PGS_DIR" > /dev/null
				BO_run_smi install $@
			popd > /dev/null
			touch ".installed"
		fi
		popd > /dev/null
		format "$VERBOSE" "FOOTER"
	}

	ensureProvisioned $@
}
init $@