#!/bin/bash
# Source https://github.com/cadorn/bash.origin
. "$HOME/.bash.origin"
function init {
	eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
	BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
	PGS_DIR="$___TMP___"

	function install {
		BO_checkVerbose "VERBOSE" "$@"

		BO_format "$VERBOSE" "HEADER" "Installing PINF.Genesis System"

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
		if [ -e "$TARGET_PATH/.gitmodules" ]; then
			if ! grep -qe "^\/\.gitmodules\.initialized$" "$TARGET_PATH/.gitignore"; then
				BO_log "$VERBOSE" "Append '/.gitmodules.initialized' to ignore file: $TARGET_PATH/.gitignore"
				# TODO: Do a cleaner append
			    echo -e "\n/.gitmodules.initialized" >> "$TARGET_PATH/.gitignore"
			fi
		fi

		BO_log "$VERBOSE" "Copying boot file from '$PGS_DIR/../boot' to '$TARGET_PATH/boot'"
		cp -f "$PGS_DIR/../boot" "$TARGET_PATH/boot"
		chmod ug+x "$TARGET_PATH/boot"

		BO_log "$VERBOSE" "Copying PINF.Genesis System from '$PGS_DIR' to '$TARGET_PATH/.pgs'"
		rsync -va --exclude-from="$PGS_DIR/.rsyncignore" "$PGS_DIR/" "$TARGET_PATH/.pgs/"

		BO_log "$VERBOSE" "Copy done!"

		BO_log "$VERBOSE" "Action: You can now run './boot' to boot the system!"

		BO_format "$VERBOSE" "FOOTER"
	}

	function runExample {

		BO_checkVerbose "VERBOSE" "$@"

		local EXAMPLE_DIR="$1"
		local EXAMPLE_NAME="$(basename "$EXAMPLE_DIR")"

		BO_format "$VERBOSE" "HEADER" "Run example $EXAMPLE_NAME"

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
					rm -Rf ".deps" "node_modules"
				fi

				if [ "$FIRST_RUN" == "1" ]; then
					BO_format "1" "HEADER" "First run output"
					cat ".result/actual.log"
				fi
			fi
		popd > /dev/null

		if [ "$DIFFERENT" == "1" ]; then
			exit 1
		fi;

		BO_format "$VERBOSE" "FOOTER"
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
	if [ -z "$BO_PACKAGES_DIR" ]; then
		echo "ERROR: 'BO_PACKAGES_DIR' environment variable is not set (file: $PGS_DIR/pgs.sh)!"
		exit 1
	fi
	export PGS_DIRPATH="$PGS_DIR"

	BO_checkVerbose "VERBOSE" "$@"

	function pgsExpand {
		BO_checkVerbose "VERBOSE" "$@"
		export PTO_USE_EXISTING_PGS_PINF_DIRPATH="1"
		BO_format "$VERBOSE" "HEADER" "Expanding PINF.Genesis System"
		pushd "$PGS_DIR" > /dev/null
			export PGS_PINF_EPOCH="expand.genesis.pinf.org"
			BO_callPlugin "github.com~bash-origin~bash.origin.pinf~0/source/installed/master/bash.origin.pinf" pto turn $@
			export PGS_WORKSPACE_UID="`cat "$PGS_PINF_DIRPATH/uid"`"
		popd > /dev/null
		BO_format "$VERBOSE" "FOOTER"
	}

	function pgsTurn {		
		BO_checkVerbose "VERBOSE" "$@"
		export PTO_USE_EXISTING_PGS_PINF_DIRPATH="1"
		# TODO: Remove this once turning happens automatically on first spin.
		BO_format "$VERBOSE" "HEADER" "Turning system"
		pushd "$PGS_WORKSPACE_ROOT" > /dev/null
			export PGS_PINF_EPOCH="$PGS_WORKSPACE_UID"
			BO_callPlugin "github.com~bash-origin~bash.origin.pinf~0/source/installed/master/bash.origin.pinf" pto turn $@
		popd > /dev/null
		BO_format "$VERBOSE" "FOOTER"
	}

	function pgsSpin {
		BO_checkVerbose "VERBOSE" "$@"
		export PTO_USE_EXISTING_PGS_PINF_DIRPATH="1"
		BO_format "$VERBOSE" "HEADER" "Spinning system"
		pushd "$PGS_WORKSPACE_ROOT" > /dev/null
			export PGS_PINF_EPOCH="$PGS_WORKSPACE_UID"
			BO_callPlugin "github.com~bash-origin~bash.origin.pinf~0/source/installed/master/bash.origin.pinf" pto spin $@
		popd > /dev/null
		BO_format "$VERBOSE" "FOOTER"
	}

	function ensureDepsForClone {
		BO_setResult $1 "0"
		if [ -e "$PGS_WORKSPACE_ROOT/package.json" ]; then
			if grep -q -e '"name": "genesis.pinf.org"' "$PGS_WORKSPACE_ROOT/package.json"; then
				# Not a clone.
				return 0
			fi
		fi
		BO_setResult $1 "1"
		# TODO: Use `sm.genesis` to load deps from catalog if not in `$HOME/.bash.origin.cache`
		local CLONE_PATH="$PGS_DIR/.clone"
		if [ ! -e "$CLONE_PATH" ]; then
			rm -Rf "$CLONE_PATH~tmp" > /dev/null || true
			BO_log "$VERBOSE" "Cloning PINF.Genesis from 'https://github.com/pinf/genesis.pinf.org.git' to '$CLONE_PATH~tmp' ..."
			git clone --depth 1 "https://github.com/pinf/genesis.pinf.org.git" "$CLONE_PATH~tmp"
			BO_log "$VERBOSE" "... cloned PINF.Genesis."
			pushd "$CLONE_PATH~tmp" > /dev/null
				touch ".pgs/.provisioned"
				BO_log "$VERBOSE" "Installing PINF.Genesis ..."
				if [ "$VERBOSE" == "1" ]; then
					./boot activate -v
				else
					./boot activate > /dev/null
				fi
				BO_log "$VERBOSE" "... PINF.Genesis install done."
				mv "$CLONE_PATH~tmp" "$CLONE_PATH"
			popd > /dev/null
		fi
		pushd "$PGS_WORKSPACE_ROOT" > /dev/null
			if [ ! -e ".deps" ]; then
				mkdir ".deps"
			fi
			for dir in $CLONE_PATH/.deps/* ; do
				dir="$(basename $dir)"
				if [ -L ".deps/$dir" ]; then
					BO_log "$VERBOSE" "Removing '$PGS_WORKSPACE_ROOT/.deps/$dir' because it is a symlink."
					rm -f ".deps/$dir"
				fi
				if [ ! -e ".deps/$dir" ]; then
					BO_log "$VERBOSE" "Copy '$CLONE_PATH/.deps/$dir' to '$PGS_WORKSPACE_ROOT/.deps/$dir'."
					cp -Rf "$CLONE_PATH/.deps/$dir" ".deps/$dir"
				fi
			done
		popd > /dev/null
	}

	function linkDepsForClone {
		local CLONE_PATH="$PGS_DIR/.clone"
		pushd "$PGS_WORKSPACE_ROOT" > /dev/null
			for dir in $CLONE_PATH/.deps/* ; do
				dir="$(basename $dir)"
				if [ -e "$HOME/.bash.origin.cache/$dir" ]; then
					BO_log "$VERBOSE" "Linking '$HOME/.bash.origin.cache/$dir' to '$PGS_WORKSPACE_ROOT/.deps/$dir'."
					rm -Rf ".deps/$dir" > /dev/null || true
					ln -s "$HOME/.bash.origin.cache/$dir" ".deps/$dir"
				fi
			done
		popd > /dev/null
	}

	function ensureProvisioned {
		BO_format "$VERBOSE" "HEADER" "Provisioning base system"
		pushd "$PGS_WORKSPACE_ROOT" > /dev/null
			if [ -f ".gitmodules" ]; then
				if [ ! -f ".gitmodules.initialized" ]; then
					BO_log "$VERBOSE" "Init submodules ..."
					git submodule update --init --recursive --rebase
					BO_log "$VERBOSE" "... submodules init done"
					touch ".gitmodules.initialized"
				else
					BO_log "$VERBOSE" "Skip init submodules. Already initialized."
				fi
			fi
		popd > /dev/null
		if [ -e "$PGS_DIR/.provisioned" ]; then
			BO_log "$VERBOSE" "Skip provision. Already provisioned."
		else
			ensureDepsForClone "IS_CLONE"
			pushd "$PGS_DIR" > /dev/null
				BO_isInSystemCache "SMI_BASE_PATH" "github.com/sourcemint/smi" "0.x"
				pushd "$SMI_BASE_PATH" > /dev/null
					if [ ! -e ".installed" ]; then
						BO_log "$VERBOSE" "Install smi ..."
					 	if [ "$VERBOSE" == "1" ]; then
							BO_run_npm install --production
					 	else
							BO_run_npm install --production > /dev/null
					 	fi
						touch ".installed"
						BO_log "$VERBOSE" "... smi install done"
					fi
				popd > /dev/null
			 	if [ "$VERBOSE" == "1" ]; then
					BO_run_smi install -v
			 	else
					BO_run_smi install > /dev/null
			 	fi
				touch ".provisioned"
			popd > /dev/null
			if [ "$IS_CLONE" == "1" ]; then
				linkDepsForClone
			fi
		fi
		BO_format "$VERBOSE" "FOOTER"
	}

	ensureProvisioned
}
init $@