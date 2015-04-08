
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

				var uidPath = API.PATH.join(partiallyResolvedConfig.workspaceRoot, partiallyResolvedConfig.directories.pinf, "uid");

				// If 'uid' is declared in 'package.json ~ uid' we recover the '.pinf/uid' file.
				var packageDescriptorPath = API.PATH.join(partiallyResolvedConfig.workspaceRoot, "package.json");
				if (API.FS.existsSync(packageDescriptorPath)) {
					var packageDescriptor = require(packageDescriptorPath);
					if (packageDescriptor.uid) {
						API.FS.outputFileSync(uidPath, packageDescriptor.uid, "utf8");
					}
				}

				return API.Q.denodeify(function (callback) {
					return API.FS.exists(uidPath, function (exists) {
						if (exists) {
							return API.FS.readFile(uidPath, "utf8", callback);
						}

						function useUid (uid, callback) {
							uid = uid.toLowerCase();
							return API.FS.outputFile(uidPath, uid, "utf8", function (err) {
								if (err) return callback(err);
								return callback(null, uid);
							});
						}

						if (process.env.PGS_WORKSPACE_UID) {
							API.console.verbose("Using 'PGS_WORKSPACE_UID' environment variable (" + process.env.PGS_WORKSPACE_UID + ") as system UID!");
							return useUid(process.env.PGS_WORKSPACE_UID, callback);
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
							return useUid(uid.replace(/[^0-9A-Z-]/g, ""), callback);
						});
					});
				})();
			},
			deriveBasename: function (partiallyResolvedConfig) {
				return API.Q.denodeify(API.FS.realpath)(partiallyResolvedConfig.workspaceRoot).then(function (path) {
					return API.PATH.basename(path);
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
