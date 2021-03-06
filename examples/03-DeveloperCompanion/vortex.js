

exports.main = function (API) {

	API.insight.debug("PINF.Genesis Vortex for DEVELOPER COMPANION Booted!");

	var exports = {};

	exports.resolve = function (resolver, config, previousResolvedConfig) {

		API.insight.debug("resolve()", resolver, config, previousResolvedConfig);

		return resolver({}).then(function (resolvedConfig) {

			API.insight.debug("resolve() - resolvedConfig", resolvedConfig);

			return resolvedConfig;
		});
	}

	exports.turn = function (resolvedConfig) {

		API.insight.debug("turn()", resolvedConfig);

	}

	exports.spin = function (resolvedConfig) {

		API.insight.debug("spin()", resolvedConfig);

	}

	return exports;
}

