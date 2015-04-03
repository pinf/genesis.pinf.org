
// Bootstrap a PINF.Genesis System (PGS) from the root seed program descriptor.

exports.for = function (API) {

	var exports = {};

	exports.resolve = function (resolver, config, previousResolvedConfig) {
		return resolver({
			deriveRevision: function () {
				return API.Q.nbind(API.getFileTreeHashFor, API)(__dirname, {
					ignore: [
						"/program.rt.json",
						"/.rt",
						"/.pinf.boot",
						"/.gitignore"
					]
				});
			},
			ensureUid: function () {
				var uidPath = API.PATH.join(API.getRootPath(), "../.pinf.uid");
				return API.Q.denodeify(function (callback) {
					return API.FS.exists(uidPath, function (exists) {
						if (exists) {
							return API.FS.readFile(uidPath, "utf8", callback);
						}
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
							uid = uid.replace(/[^0-9A-Z-]/g, "");
							return API.FS.outputFile(uidPath, uid, "utf8", function (err) {
								if (err) return callback(err);

								return callback(null, uid);
							});
						});
					});
				})();
			},
			deriveBasename: function (partiallyResolvedConfig) {
				return API.Q.denodeify(API.FS.realpath)(partiallyResolvedConfig.systemRoot).then(function (path) {
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
						"!.pinf.*",
						"!.rt/",
						"!boot.js",
						"!package.json",
						"!program.json",
						"!.gitignore",
						"!*.proto.json"
					], {
						cwd: fromPath
					});

					stream
						.pipe(API.GULP_PLUMBER())
						.pipe(API.GULP_DEBUG({
							title: '[pgs-boot]',
							minimal: true
						}))
						.pipe(API.GULP_RENAME(function (path) {
							if (path.basename === "__from.gps.basename__") {
								path.basename = resolvedConfig.variables.BASENAME;
							} else
							if ((path.basename + path.extname) === "__from.gps.basename__") {
								path.basename = resolvedConfig.variables.BASENAME;
								path.extname = "";
							}

							if (path.extname === ".tpl") {
								var basename = path.basename.split(".");
								path.extname = "." + basename.pop();
								path.basename = basename.join(".");
							}
						}))
//						.pipe(filter)
						// TODO: Add generic variables here and move to `to.pinf.lib`.
						.pipe(API.GULP_REPLACE(/%%[^%]+%%/g, function (matched) {
							if (matched === "%%UID%%") {
								return resolvedConfig.variables.UID;
							} else
							if (matched === "%%EXTENDS%%") {
								return resolvedConfig.variables.EXTENDS;
							} else
							if (matched === "%%BASENAME%%") {
								return resolvedConfig.variables.BASENAME;
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

		return API.Q.denodeify(copy)(__dirname, API.PATH.dirname(API.getRootPath()));
	}

	exports.spin = function (resolvedConfig) {

console.log("spin resolvedConfig", resolvedConfig);

	}

	return exports;
}
