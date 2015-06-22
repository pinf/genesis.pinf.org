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

		pushd "$TARGET_PATH" > /dev/null

			# Ensure trailing newline
			# @source http://stackoverflow.com/a/16198793/330439
			[[ $(tail -c1 ".gitignore") && -f ".gitignore" ]] && echo '' >> ".gitignore"

			if [ ! -f ".gitignore" ]; then
				BO_log "$VERBOSE" "Create ignore file: .gitignore"
				touch ".gitignore"
			fi
			if ! grep -qe "^\/node_modules\/$" .gitignore; then
				BO_log "$VERBOSE" "Append '/node_modules/' to ignore file: .gitignore"
			    echo -e "\n/node_modules/" >> .gitignore
			fi
			if ! grep -qe "^\/\.deps$" .gitignore; then
				BO_log "$VERBOSE" "Append '/.deps' to ignore file: $TARGET_PATH/.gitignore"
			    echo -e "\n/.deps" >> .gitignore
			fi
			if ! grep -qe "^\/boot$" .gitignore; then
				BO_log "$VERBOSE" "Append '/boot' to ignore file: $TARGET_PATH/.gitignore"
			    echo -e "\n/boot" >> .gitignore
			fi
			if ! grep -qe "^\/\.pgs$" .gitignore; then
				BO_log "$VERBOSE" "Append '/.pgs' to ignore file: $TARGET_PATH/.gitignore"
			    echo -e "\n/.pgs" >> .gitignore
			fi
			if [ -e ".gitmodules" ]; then
				if ! grep -qe "^\/\.gitmodules\.initialized$" .gitignore; then
					BO_log "$VERBOSE" "Append '/.gitmodules.initialized' to ignore file: $TARGET_PATH/.gitignore"
				    echo -e "\n/.gitmodules.initialized" >> .gitignore
				fi
			fi
		popd > /dev/null

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
			# TODO: Clean this up once we publish packages nicer.
			if [ -e "$PGS_DIRPATH/../node_modules/pto-for-npm" ]; then
				BO_sourcePrototype "$PGS_DIRPATH/../node_modules/pto-for-npm/bin/pto"
				runFor "`pwd`" turn $@
			else
				BO_callPlugin "github.com~bash-origin~bash.origin.pinf~0/source/installed/master/bash.origin.pinf" pto turn $@
			fi
			export PGS_WORKSPACE_UID="`cat "$PGS_PINF_DIRPATH/$PGS_PINF_EPOCH/uid"`"
		popd > /dev/null
		if [ ! -e "$PGS_REGISTRY_DIRPATH/workspaces/$PGS_WORKSPACE_UID" ]; then
			rm -f "$PGS_REGISTRY_DIRPATH/workspaces/$PGS_WORKSPACE_UID" > /dev/null || true
			BO_log "$VERBOSE" "Linking workspace '$PGS_WORKSPACE_ROOT' to shortcut '$PGS_REGISTRY_DIRPATH/workspaces/$PGS_WORKSPACE_UID'."
			if [ ! -e "$PGS_REGISTRY_DIRPATH/workspaces" ]; then
				mkdir -p "$PGS_REGISTRY_DIRPATH/workspaces"
			fi
			ln -s "$PGS_WORKSPACE_ROOT" "$PGS_REGISTRY_DIRPATH/workspaces/$PGS_WORKSPACE_UID"
		fi
		BO_format "$VERBOSE" "FOOTER"
	}

	function pgsTurn {		
		BO_checkVerbose "VERBOSE" "$@"
		export PTO_USE_EXISTING_PGS_PINF_DIRPATH="1"
		# TODO: Remove this once turning happens automatically on first spin.
		BO_format "$VERBOSE" "HEADER" "Turning system"
		pushd "$PGS_WORKSPACE_ROOT" > /dev/null
			export PGS_PINF_EPOCH="$PGS_WORKSPACE_UID"
			BO_callPlugin "bash.origin.pinf@0.1.7" pto turn $@
		popd > /dev/null
		BO_format "$VERBOSE" "FOOTER"
	}

	function pgsSpin {
		BO_checkVerbose "VERBOSE" "$@"
		export PTO_USE_EXISTING_PGS_PINF_DIRPATH="1"
		BO_format "$VERBOSE" "HEADER" "Spinning system"
		pushd "$PGS_WORKSPACE_ROOT" > /dev/null
			export PGS_PINF_EPOCH="$PGS_WORKSPACE_UID"
			BO_callPlugin "bash.origin.pinf@0.1.7" pto spin $@
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
		# NOTE: We don't want to symlink CLONE_PATH to our central install yet as smi will update some paths.
		#       This also needs to be fixed.
		local CLONE_PATH="$PGS_DIR/.clone"
		if [ ! -e "$CLONE_PATH" ]; then
			rm -Rf "$CLONE_PATH~tmp" > /dev/null || true
			if [ -e "$HOME/.bash.origin.cache/github.com~pinf~genesis.pinf.org~0/source/installed/master/.git" ]; then
				BO_log "$VERBOSE" "Cloning PINF.Genesis from '$HOME/.bash.origin.cache/github.com~pinf~genesis.pinf.org~0/source/installed/master/.git' to '$CLONE_PATH~tmp' ..."
				git clone --depth 1 "file://$HOME/.bash.origin.cache/github.com~pinf~genesis.pinf.org~0/source/installed/master" "$CLONE_PATH~tmp"
			else
				BO_log "$VERBOSE" "Cloning PINF.Genesis from 'https://github.com/pinf/genesis.pinf.org.git' to '$CLONE_PATH~tmp' ..."
				git clone --depth 1 "https://github.com/pinf/genesis.pinf.org.git" "$CLONE_PATH~tmp"
			fi
			BO_log "$VERBOSE" "... cloned PINF.Genesis."
			pushd "$CLONE_PATH~tmp" > /dev/null
				touch ".pgs/.provisioned"
				BO_log "$VERBOSE" "Activating PINF.Genesis ..."
				if [ "$VERBOSE" == "1" ]; then
					./boot activate -v
				else
					./boot activate > /dev/null
				fi
				BO_log "$VERBOSE" "... PINF.Genesis activation done."
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
			# If 'github.com~sourcemint~smi~0' is found in central cache we
			# use it instead of the one from genesis.pinf.org.
			if [ -L "$HOME/.bash.origin.cache/github.com~sourcemint~smi~0/source/installed/master" ]; then
				BO_log "$VERBOSE" "Linking 'github.com~sourcemint~smi~0' from '$HOME/.bash.origin.cache/github.com~sourcemint~smi~0' to '$PGS_WORKSPACE_ROOT/.deps/github.com~sourcemint~smi~0'."
				rm -Rf ".deps/github.com~sourcemint~smi~0"
				ln -s "$HOME/.bash.origin.cache/github.com~sourcemint~smi~0" ".deps/github.com~sourcemint~smi~0"
			fi
			if [ ! -L "node_modules/bash.origin" ]; then
				if [ -L "$HOME/.bash.origin.cache/github.com~bash-origin~bash.origin~0/source/installed/master" ]; then
					BO_log "$VERBOSE" "Linking from '$HOME/.bash.origin.cache/github.com~bash-origin~bash.origin~0/source/installed/master' to '$PGS_WORKSPACE_ROOT/node_modules/bash.origin'."
					rm -Rf "node_modules/bash.origin" > /dev/null || true
					ln -s "$HOME/.bash.origin.cache/github.com~bash-origin~bash.origin~0/source/installed/master" "node_modules/bash.origin"
				fi
			fi
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

	function ensureGitExclude {

		function ensureGitExcludesForFile {
			if [ ! -e "$1" ]; then
				if [ ! -d "$(dirname "$1")" ]; then
					mkdir -p "$(dirname "$1")"
				fi
				touch "$1"
			fi

			# Ensure trailing newline
			# @source http://stackoverflow.com/a/16198793/330439
			[[ $(tail -c1 "$1") && -f "$1" ]] && echo '' >> "$1"

			if ! grep -qe "^\.installed$" "$1"; then
				BO_log "$VERBOSE" "Append '.installed' to exclude file: '$1'"
			    echo -e ".installed" >> "$1"
			fi
			if ! grep -qe "^\.smi-for-npm$" "$1"; then
				BO_log "$VERBOSE" "Append '.smi-for-npm' to exclude file: '$1'"
			    echo -e ".smi-for-npm" >> "$1"
			fi
		}

		# @see http://git-scm.com/docs/git-config
		if [ -z "$XDG_CONFIG_HOME" ]; then
			echo "ERROR: 'XDG_CONFIG_HOME' environment varibale not set! It should have been set during booting!"
			exit 1
		fi

		ensureGitExcludesForFile "$XDG_CONFIG_HOME/git/ignore"
	}

	function ensureProvisioned {
		BO_format "$VERBOSE" "HEADER" "Provisioning base system"

		BO_log "$VERBOSE" "Using PGS_WORKSPACE_ROOT: $PGS_WORKSPACE_ROOT"
		BO_log "$VERBOSE" "Using PGS_DIR: $PGS_DIR"

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
			ensureGitExclude
			ensureDepsForClone "IS_CLONE"
			pushd "$PGS_DIR" > /dev/null

				# Link source resolver so we can override lookups for dev and easy system ops.
				BO_isInSystemCache "SMRESOLVE_BASE_PATH" "github.com/sourcemint/sm.resolve" "0.1.0"
				pushd "$SMRESOLVE_BASE_PATH" > /dev/null
					if [ ! -e ".installed" ]; then
						BO_log "$VERBOSE" "Install sm.resolve using 'npm install' in directory '$SMRESOLVE_BASE_PATH' ..."
					 	if [ "$VERBOSE" == "1" ]; then
							BO_run_npm install --production
					 	else
							BO_run_npm install --production > /dev/null
					 	fi
						touch ".installed"
						BO_log "$VERBOSE" "... sm.resolve install done"
					fi
				popd > /dev/null
				pushd "$PGS_WORKSPACE_ROOT" > /dev/null
					if [ ! -e "node_modules" ]; then
						mkdir "node_modules"
					fi
					if [ ! -e "node_modules/sm.resolve" ]; then
						rm -Rf "node_modules/sm.resolve" > /dev/null || true
						ln -s "$SMRESOLVE_BASE_PATH" "node_modules/sm.resolve"
					fi
					if [ ! -e "bin" ]; then
						mkdir "bin"
					fi
					if [ ! -e "bin/sm.resolve" ]; then
						rm -Rf "bin/sm.resolve" > /dev/null || true
						ln -s "$SMRESOLVE_BASE_PATH/sm.resolve" "bin/sm.resolve"
					fi
				popd > /dev/null

				# Use our own smi installer if provided in system
				BO_isInSystemCache "SMI_BASE_PATH" "github.com/sourcemint/smi" "0.x"
				pushd "$SMI_BASE_PATH" > /dev/null
					if [ ! -e ".installed" ]; then
						BO_log "$VERBOSE" "Install smi using 'npm install' in directory '$SMI_BASE_PATH' ..."
					 	if [ "$VERBOSE" == "1" ]; then
							BO_run_npm install --production
					 	else
							BO_run_npm install --production > /dev/null
					 	fi

					 	# Link some packages we have to hack on smi.
					 	# NOTE: The packages need to be installed first.
					 	if [ ! -L "node_modules/org.pinf.lib" ]; then
							BO_isInSystemCache "PL_BASE_PATH" "github.com/pinf/org.pinf.lib" "0.x"
					 		if [ -e "$PL_BASE_PATH" ]; then
								pushd "$PL_BASE_PATH" > /dev/null
									if [ ! -e "node_modules" ]; then
										BO_log "$VERBOSE" "Install org.pinf.lib using 'npm install' in directory '$PL_BASE_PATH'"
									 	if [ "$VERBOSE" == "1" ]; then
											BO_run_npm install --production
									 	else
											BO_run_npm install --production > /dev/null
									 	fi
									fi
								popd > /dev/null
								BO_log "$VERBOSE" "Linking '$PL_BASE_PATH' to '$SMI_BASE_PATH/node_modules/org.pinf.lib'"
						 		rm -Rf "node_modules/org.pinf.lib"
						 		ln -s "$PL_BASE_PATH" "node_modules/org.pinf.lib"
					 		fi
					 	fi

						touch ".installed"
						BO_log "$VERBOSE" "... smi install done"
					fi
				popd > /dev/null

				# Use smi installer from bash.origin which may download it if not installed.
				# bash.origin may use the same cache path as us above so it will be available
				# above on the second run.
			 	if [ "$VERBOSE" == "1" ]; then
					BO_run_smi install -vd
			 	else
					BO_run_smi install > /dev/null
			 	fi

			 	# TODO: Run an smi command to link all unlinked node_modules dependencies
			 	#       for which we now have provisioned dependencies now that everything is installed.

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