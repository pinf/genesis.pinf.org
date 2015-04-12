

exports.main = function (API) {

	console.log("main()");

	var exports = {};

	exports.resolve = function (resolver, config, previousResolvedConfig) {

		console.log("resolve()");

		return resolver({}).then(function (resolvedConfig) {

			console.log("resolved");

			return resolvedConfig;
		});
	}

	exports.turn = function (resolvedConfig) {

		console.log("turn()");

	}

	exports.spin = function (resolvedConfig) {

		console.log("spin()");

	}

	console.log("initialized");

	return exports;
}

