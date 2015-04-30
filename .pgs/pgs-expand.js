
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

				var uidPath = API.PATH.join(partiallyResolvedConfig.workspaceVariables.PGS_WORKSPACE_PINF_DIRPATH, "uid");

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
		});
	}

/*
	exports.turn = function (resolvedConfig) {
		if (
			resolvedConfig.workspaceFilesVariables &&
			resolvedConfig.workspaceFilesVariables[lastPath] &&
			typeof resolvedConfig.workspaceFilesVariables[lastPath][matched] !== "undefined"
		) {
			return resolvedConfig.workspaceFilesVariables[lastPath][matched];
		}
	}
*/

	return exports;
}
