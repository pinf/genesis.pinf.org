
// NOTE: This file is AUTO-GENERATED once by './.pgs/' by taking the template
//       from https://github.com/pinf/genesis.pinf.org/blob/master/.pgs/vortex/vortex.js
//       This file SHOULD BE COMMITTED to git and maintained manually from now on.
//       If not committed to git, the file will be removed again on 'clean'.
//       If you don't want './.pgs/' to leave any trace behind in your original code,
//       DO NOT COMMIT THIS CODE (remove line if you decide to do so)


exports.for = function (API) {

	API.insight.debug("PINF.Genesis Vortex Booted!");

	// This is the place where you can intercept **ANYTHING** that is accessible
	// to the PINF.Genesis system.
	// Use it for making hacks on existing systems or to orchestrate new systems.

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

