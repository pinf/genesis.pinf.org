
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

	exports.turn = function (resolvedConfig) {

		// First we write the root program.json file which seeds the rest of the system.

		function copy (fromPath, toPath, callback) {

			API.console.debug("Copying and transforming fileset", fromPath, "to", toPath, "...");

			var domain = require('domain').create();
			domain.on('error', function(err) {
				// The error won't crash the process, but what it does is worse!
				// Though we've prevented abrupt process restarting, we are leaking
				// resources like crazy if this ever happens.
				// This is no better than process.on('uncaughtException')!
				console.error("UNHANDLED DOMAIN ERROR:", err.stack, new Error().stack);
				process.exit(1);
			});
			domain.run(function() {

				try {

					var destinationStream = null;

					destinationStream = API.GULP.dest(API.PATH.dirname(toPath));

					destinationStream.once("error", function (err) {
						return callback(err);
					});

					destinationStream.once("end", function () {

						API.console.debug("... done");

						return callback();
					});

					var filter = API.GULP_FILTER([
						'index.html',
						'**/index.html'
					]);

					// TODO: Respect gitignore by making pinf walker into gulp plugin. Use pinf-package-insight to load ignore rules.
					var stream = null;
					stream = API.GULP.src([
						"**",
						".*",
						"!.pinf/",
						"!.rt/",
						"!boot.js",
						"!package.json",
						"!program.json",
						"!program.rt.json",
						"!.gitignore",
						"!.rsyncignore",
						"!*.proto.json",
					], {
						cwd: fromPath
					});

					var lastPath = null;
					stream
						.pipe(API.GULP_PLUMBER())
						.pipe(API.GULP_DEBUG({
							title: '[pgs-boot]',
							minimal: true
						}))
						// TODO: Only replace variables in files ending with '.tpl'.
						.pipe(API.GULP_RENAME(function (path) {
							if (path.basename === "__from.gps.basename__") {
								path.basename = resolvedConfig.workspaceVariables.BASENAME;
							} else
							if ((path.basename + path.extname) === "__from.gps.basename__") {
								path.basename = resolvedConfig.workspaceVariables.BASENAME;
								path.extname = "";
							}

							if (path.extname === ".tpl") {
								var basename = path.basename.split(".");
								path.extname = "." + basename.pop();
								path.basename = basename.join(".");
							}

							lastPath = path.basename + path.extname;
						}))
//						.pipe(filter)
						// TODO: Add generic variables here and move to `to.pinf.lib`.
						.pipe(API.GULP_REPLACE(/%%[^%]+%%/g, function (matched) {
							if (matched === "%%UID%%") {
								return resolvedConfig.workspaceVariables.UID;
							} else
							if (matched === "%%EXTENDS%%") {
								return resolvedConfig.workspaceVariables.EXTENDS;
							} else
							if (matched === "%%BASENAME%%") {
								return resolvedConfig.workspaceVariables.BASENAME;
							} else
							if (
								resolvedConfig.workspaceFilesVariables &&
								resolvedConfig.workspaceFilesVariables[lastPath] &&
								typeof resolvedConfig.workspaceFilesVariables[lastPath][matched] !== "undefined"
							) {
								return resolvedConfig.workspaceFilesVariables[lastPath][matched];
							}
							return matched;
						}))
//						.pipe(filter.restore())											
						.pipe(destinationStream);

					return stream.once("error", function (err) {
						err.message += " (while running gulp)";
						err.stack += "\n(while running gulp)";
						return callback(err);
					});
				} catch (err) {
					return callback(err);
				}
			});
		}

		return API.Q.denodeify(copy)(__dirname, API.PATH.dirname(API.getRootPath())).then(function () {

			if (!API.FS.existsSync(API.PATH.join(resolvedConfig.workspaceRoot, resolvedConfig.directories.pinf))) {
				API.FS.mkdirsSync(API.PATH.join(resolvedConfig.workspaceRoot, resolvedConfig.directories.pinf));
			}
			if (!API.FS.existsSync(API.PATH.join(resolvedConfig.workspaceRoot, resolvedConfig.directories.packages))) {
				API.FS.mkdirsSync(API.PATH.join(resolvedConfig.workspaceRoot, resolvedConfig.directories.packages));
			}
		});
	}

	exports.spin = function (resolvedConfig) {

//console.log("spin resolvedConfig", resolvedConfig);

	}

	return exports;
}
