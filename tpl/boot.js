
exports.for = function (API) {

	var exports = {};

	exports.resolve = function (resolver, config, previousResolvedConfig) {
		return resolver({
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
			deriveBasename: function () {
				return API.PATH.basename(API.PATH.dirname(API.getRootPath()));
			}
		});
	}

	exports.turn = function (resolvedConfig) {

console.log("turn resolvedConfig", resolvedConfig);

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
						"!.pinf.*",
						"!.rt/",
						"!boot.js",
						"!package.json",
						"!program.json"
					], {
						cwd: fromPath
					});

					stream
						.pipe(API.GULP_PLUMBER())
						.pipe(API.GULP_DEBUG({
							title: '[pgs-boot]',
							minimal: true
						}))
//						.pipe(filter)
						// TODO: Add generic variables here and move to `to.pinf.lib`.
						.pipe(API.GULP_REPLACE(/%[^%]+%/g, function (matched) {
							// TODO: Arrive at minimal set of core variables and options to add own.
							if (matched === "%boot.loader.uri%") {
								return (relativeBaseUri?relativeBaseUri+"/":"") + "bundles/loader.js";
							} else
							if (matched === "%boot.bundle.uri%") {
								return (relativeBaseUri?relativeBaseUri+"/":"") + ("bundles/" + packageDescriptor.main).replace(/\/\.\//, "/");
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



/*
		# First we write the root program.json file which seeds the rest of the system.
#		sed "s|%%EXTENDS%%|[\"$TPL_PATH\"]|g" "$TPL_PATH/program.json.tpl" > "$TARGET_PATH/program.json"
#		perl -pi -e "s/\%\%UID\%\%/$SYSTEM_UID/g" "$TARGET_PATH/program.json"
#		perl -pi -e "s/\%\%BASENAME\%\%/$SYSTEM_BASENAME/g" "$TARGET_PATH/program.json"


#		replaceInFile "$TARGET_PATH/program.json" '\%\%UID\%\%' "$SYSTEM_UID"
#		replaceInFile "$TARGET_PATH/program.json" '\%\%EXTENDS\%\%' "[\"$TPL_PATH/*.proto.json\"]"
#		replaceInFile "$TARGET_PATH/program.json" '\%\%BASENAME\%\%' "$SYSTEM_BASENAME"

#echo "BASENAME: `BO_run_node --eval 'process.stdout.write(require("'$TARGET_PATH'/program.json").config["genesis.pinf.org/0"].basename);'`"

		# Now we load the root program descriptor and use the variables to seed the root system files.
#		forceCopyFile "$TPL_PATH/bin/__from.pgs.basename__" "$TARGET_PATH/bin/$SYSTEM_BASENAME"
#		forceCopyFile "$TPL_PATH/bin/__from.pgs.basename__.js" "$TARGET_PATH/bin/$SYSTEM_BASENAME.js"

#		forceCopyFile "$TPL_PATH/bin/install" "$TARGET_PATH/bin/install"
#		forceCopyFile "$TPL_PATH/bin/activate" "$TARGET_PATH/bin/activate"
#		forceCopyFile "$TPL_PATH/bin/demo" "$TARGET_PATH/bin/demo"
#		forceCopyFile "$TPL_PATH/bin/test" "$TARGET_PATH/bin/test"


#		forceCopyFile "$TPL_PATH/.gitignore.tpl" "$TARGET_PATH/.gitignore"
#		forceCopyFile "$TPL_PATH/main.js" "$TARGET_PATH/main.js"
#		forceCopyFile "$TPL_PATH/package.json.tpl" "$TARGET_PATH/package.json"
#		forceCopyFile "$TPL_PATH/README.md.tpl" "$TARGET_PATH/README.md"
*/

		return API.Q.reject("STOP");
	}

	exports.spin = function (resolvedConfig) {

console.log("spin resolvedConfig", resolvedConfig);

	}

	return exports;
}
