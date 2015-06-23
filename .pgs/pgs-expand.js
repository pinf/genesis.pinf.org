
// Bootstrap a PINF.Genesis System (PGS) from the root seed program descriptor.

exports.for = function (API) {

	var exports = {};

	exports.resolve = function (resolver, config, previousResolvedConfig) {

		return resolver({
			getWorkspaceFiles: function () {
				if (
					!previousResolvedConfig ||
					!previousResolvedConfig.workspaceRoot
				) {
					return {};
				}
				return API.Q.nbind(API.getFileTreeInfoFor, API)(previousResolvedConfig.workspaceRoot, {}).then(function (info) {
					return info;
				});
			},
			ensureUid: function (partiallyResolvedConfig) {

				var uidPath = API.PATH.join(partiallyResolvedConfig.workspaceVariables.PGS_PINF_DIRPATH, partiallyResolvedConfig.workspaceVariables.PGS_PINF_EPOCH, "uid");

				// Recover the '.pinf/uid' file from various sources

				function recoverAndReturn (uid) {
					API.FS.outputFileSync(uidPath, uid, "utf8");
					return uid;
				}

				// 1) 'program.json ~ uid'
				// TODO: Use generic program descriptor loader.
				var programDescriptorPath = API.PATH.join(partiallyResolvedConfig.workspaceRoot, "program.json");
				if (API.FS.existsSync(programDescriptorPath)) {
					var programDescriptor = require(programDescriptorPath);
					if (programDescriptor.uid) {
						API.console.verbose("Using 'uid' (" + programDescriptor.uid + ") from program descriptor '" + programDescriptorPath + "' as system UID!");
						return recoverAndReturn(programDescriptor.uid);
					}
				}

				// 2) 'package.json ~ uid'
				// TODO: Use generic package descriptor loader.
				var packageDescriptorPath = API.PATH.join(partiallyResolvedConfig.workspaceRoot, "package.json");
				if (API.FS.existsSync(packageDescriptorPath)) {
					var packageDescriptor = require(packageDescriptorPath);
					if (packageDescriptor.uid) {
						API.console.verbose("Using 'uid' (" + packageDescriptor.uid + ") from package descriptor '" + packageDescriptorPath + "' as system UID!");
						return recoverAndReturn(packageDescriptor.uid);
					}
				}

				// 3) 'PGS_WORKSPACE_UID' environment variable
				if (process.env.PGS_WORKSPACE_UID) {
					API.console.verbose("Using 'PGS_WORKSPACE_UID' environment variable (" + process.env.PGS_WORKSPACE_UID + ") as system UID!");
					return recoverAndReturn(process.env.PGS_WORKSPACE_UID);
				}

				return API.Q.denodeify(function (callback) {
					return API.FS.exists(uidPath, function (exists) {
						if (exists) {
							return API.FS.readFile(uidPath, "utf8", callback);
						}

						API.console.verbose("Generating new UID to use as system UID!");

						return API.runCommands([
							"uuidgen"
						], function (err, uid) {
							if (err) {
								// TODO: Chain error.
								return callback(new Error("'uuidgen' command not found! " +
									"Please install and re-run or patch this script " +
									"($__BO_DIR__/boot) to use an alternative command " +
									"that is available on your system."));
							}
							return API.Q.when(recoverAndReturn(uid.replace(/[^0-9A-Z-]/g, ""))).then(function (uid) {
								return callback(null, uid);
							}).fail(callback);
						});
					});
				})();
			},
			deriveBasename: function (partiallyResolvedConfig) {
				return API.Q.denodeify(API.FS.realpath)(partiallyResolvedConfig.workspaceRoot).then(function (path) {
					var basename = API.PATH.basename(path);
					// Remove numbered prefix as numbers are for local organization only.
					basename = basename.replace(/^\d+-/, "");
					return basename;
				});
			}
		}).then(function (resolvedConfig) {


			function resetCacheIfPGSChanged () {

				return API.Q.fcall(function () {

					var pgsProvisionTime = ""+API.FS.statSync(resolvedConfig.workspaceVariables.PGS_DIRPATH).mtime.getTime();

					if (
						!(
							previousResolvedConfig &&
							previousResolvedConfig.provisionTime === pgsProvisionTime
						)
					) {

						resolvedConfig.provisionTime = pgsProvisionTime;

						API.console.verbose("Resetting 'PGS_PINF_DIRPATH' (" + resolvedConfig.workspaceVariables.PGS_PINF_DIRPATH + ") as 'PGS_DIRPATH' mtime changed!");

						API.forceTurnAllFurtherNodes();
					}
				});
			}

			return resetCacheIfPGSChanged().then(function () {

				return resolvedConfig;
			});
		});
	}

	exports.turn = function (resolvedConfig) {

		function ensureXDGEnvironment () {
			// The Environment variables are already set. Now we ensure the directories exist.
			// @see http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
			var paths = [
				API.PATH.join(resolvedConfig.workspaceVariables.XDG_DATA_HOME, "data"),
				resolvedConfig.workspaceVariables.XDG_CONFIG_HOME,
				resolvedConfig.workspaceVariables.XDG_CACHE_HOME,
				resolvedConfig.workspaceVariables.XDG_RUNTIME_DIR
			];
			paths.forEach(function (path) {
				if (!API.FS.existsSync(path)) {
					API.FS.mkdirsSync(path);
				}
			});
			return API.Q.resolve();
		}

		function ensureGitExcludesInGitRepositories () {

			var excludeRulesPath = API.PATH.join(resolvedConfig.workspaceVariables.XDG_CONFIG_HOME, "git/ignore");

			if (!API.FS.existsSync(excludeRulesPath)) {
				API.console.verbose("Skip loading git exclude rules from file '" + excludeRulesPath + "' as it does not exist. Also skip writing git exclude files into submodule repositories.");
				return API.Q.resolve();
			}

			var excludeRules = API.FS.readFileSync(excludeRulesPath, "utf8");
			excludeRules = excludeRules.split("\n").filter(function (line) {
				if (!line || /^#/.test(line)) return false;
				return true;
			});
			API.console.verbose("Loaded git exclude rules from file '" + excludeRulesPath + "': " + JSON.stringify(excludeRules, null, 4));

			// @see https://help.github.com/articles/ignoring-files/#explicit-repository-excludes			
			function ensureGitExcludesForGitPath (gitPath, callback) {
				if (!API.FS.existsSync(API.PATH.join(gitPath, "info/exclude"))) {
					if (!API.FS.existsSync(API.PATH.join(gitPath, "info"))) {
						API.FS.mkdirSync(API.PATH.join(gitPath, "info"));
					}
					API.FS.writeFileSync(API.PATH.join(gitPath, "info/exclude"), "", "utf8");
				}
				var excludes = API.FS.readFileSync(API.PATH.join(gitPath, "info/exclude"), "utf8");
				var lengthBefore = excludes.length;
				excludes = excludes.split("\n");
				excludeRules.forEach(function (rule) {
					if (excludes.indexOf(rule) === -1) {
						API.console.verbose("Append rule '" + rule + "' to exclude file: '" + gitPath + "/info/exclude'");
						excludes.push(rule);
					}
				});
				excludes = excludes.join("\n");
				if (excludes.length !== lengthBefore) {
					API.FS.writeFileSync(API.PATH.join(gitPath, "info/exclude"), excludes, "utf8");
				}
				function traverseUntilAllFound (basePath, callback) {
					return API.FS.readdir(basePath, function (err, filenames) {
						if (err) return callback(err);
						var headFound = false;
						filenames.forEach(function (filename) {
							if (headFound === true) return;
							if (filename === "HEAD") {
								headFound = true;
							}
						});
						if (headFound) {
							return ensureGitExcludesForGitPath(basePath, callback);
						}
						var waitfor = API.WAITFOR.parallel(callback);
						filenames.forEach(function (filename) {
							return waitfor(API.PATH.join(basePath, filename), traverseUntilAllFound);
						});
						return waitfor();
					});
				}
				return API.FS.exists(API.PATH.join(gitPath, "modules"), function (exists) {
					if (!exists) {
						return callback(null);
					}
					return traverseUntilAllFound(API.PATH.join(gitPath, "modules"), callback);
				});
			}

			return API.Q.denodeify(function (callback) {
				var gitPath = API.PATH.join(resolvedConfig.workspaceVariables.PGS_WORKSPACE_ROOT, ".git");
				return API.FS.exists(gitPath, function (exists) {
					if (!exists) {
						return callback(null);
					}
					return API.FS.stat(gitPath, function (err, stat) {
						if (err) return callback(err);
						if (stat.isFile()) {
							var path = API.PATH.join(gitPath, "..", API.FS.readFileSync(gitPath, "utf8").match(/^gitdir: (.*)\n/)[1]);
							return ensureGitExcludesForGitPath(path, callback);
						} else {
							return ensureGitExcludesForGitPath(gitPath, callback);
						}
					});
				});
			})();
		}

		function ensureInGlobalBashOriginSystemCache () {
			return API.Q.denodeify(function (callback) {

				if (!resolvedConfig.workspaceVariables.BO_GLOBAL_SYSTEM_CACHE_DIR) {
					API.console.verbose("Skip linking '" + resolvedConfig.workspaceVariables.PGS_WORKSPACE_ROOT + "' to Bash.Origin system cache as 'BO_GLOBAL_SYSTEM_CACHE_DIR' not set!");
					return callback(null);
				}

				var globalPath = API.PATH.join(
					resolvedConfig.workspaceVariables.BO_GLOBAL_SYSTEM_CACHE_DIR,
					resolvedConfig.workspaceVariables.UID,
					"source/installed/master"
				);

				function link (callback) {
					try {
						API.FS.removeSync(globalPath);
					} catch (err) {}
					if (!API.FS.existsSync(API.PATH.dirname(globalPath))) {
						API.FS.mkdirsSync(API.PATH.dirname(globalPath));
					}
					return API.FS.symlink(
						resolvedConfig.workspaceVariables.PGS_WORKSPACE_ROOT,
						globalPath,
						callback
					);
				}

				return API.FS.exists(globalPath, function (exists) {
					if (exists) {
						return API.FS.lstat(globalPath, function (err, stat) {
							if (err) return callback(err);
							if (stat.isSymbolicLink()) {
								return callback(null);
							}
							return link(callback);
						});
					}
					return link(callback);
				});
			})();
		}

		return ensureXDGEnvironment().then(function () {

			return ensureGitExcludesInGitRepositories().then(function () {

				return ensureInGlobalBashOriginSystemCache();
			});
		});
	}

	return exports;
}
