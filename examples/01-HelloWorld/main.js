

exports.main = function (API) {

	API.insight.debug("Hello World Booted!");

	var exports = {};

	exports.resolve = function (resolver, config, previousResolvedConfig) {

		API.insight.debug("Hello World - resolve()", resolver, config, previousResolvedConfig);

		return resolver({}).then(function (resolvedConfig) {

			API.insight.debug("Hello World - resolve() - resolvedConfig", resolvedConfig);

			return resolvedConfig;
		});
	}

	exports.turn = function (resolvedConfig) {

		API.insight.debug("Hello World - turn()", resolvedConfig);

	}

	exports.spin = function (resolvedConfig) {

		API.insight.debug("Hello World - spin()", resolvedConfig);

	}

	return exports;
}

