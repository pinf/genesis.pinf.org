
// Bootstrap a PINF.Genesis System (PGS) from the root seed program descriptor.

exports.for = function (API) {

	var exports = {};

	exports.resolve = function (resolver, config, previousResolvedConfig) {

		return resolver({}).then(function (resolvedConfig) {

			function setupPrograms () {
				if (!resolvedConfig.programs) {
					return API.Q.resolve();
				}
				function setupProgram (programId) {
					resolvedConfig.programs[programId] = {
						location: resolvedConfig.programs[programId],
						getRuntimeConfigFor: function ($from) {
							var runtimeConfigPath = resolvedConfig.programs[programId].location.replace(/\.json$/, ".rt.json");
							var runtimeConfig = require(runtimeConfigPath);
							if (!runtimeConfig[$from]) {
								throw new Error("Config for '" + $from + "' not found in '" + runtimeConfigPath + "'!");
							}
							return runtimeConfig[$from];
						}
					};
				}
				return API.Q.all(Object.keys(resolvedConfig.programs).map(setupProgram));
			}

			return setupPrograms().then(function () {
				return resolvedConfig;
			});
		});
	}

	return exports;
}
