

exports.main = function (API) {

API.console.log("Tes 1");

console.log("Yes from main.js!");

	var exports = {};

	exports.resolve = function (resolver, config, previousResolvedConfig) {
		return resolver({});
	}

	exports.turn = function (resolvedConfig) {

console.log("TURN main.js for system %%BASENAME%%", resolvedConfig);

	}

	exports.spin = function (resolvedConfig) {

console.log("SPIN main.js for system %%BASENAME%%", resolvedConfig);

	}

	return exports;
}
