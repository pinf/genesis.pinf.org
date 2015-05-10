
// NOTE: This file is AUTO-GENERATED once by '../../' by taking the template
//       from https://github.com/pinf/genesis.pinf.org/blob/master/.pgs/vortex/bin/activate.js
//       This file may be comitted to git and maintained manually from now on. If not committed
//       to git, the file will be removed again on 'clean'.
//       If you don't want './.pgs/' to leave any trace behind in your original code,
//       DO NOT COMMIT THIS CODE (remove line if you decide to do so)

const PATH = require("path");


var runtimeDescriptor = require(PATH.join(process.cwd(), "program.rt.json"));

// TODO: Match based on info mapped by "pgs-vortex-prompt" at $aspects = [ "jsonld contect uri", {} ]
if (runtimeDescriptor["pgs-vortex-prompt"]) {

	for (var serviceId in runtimeDescriptor["pgs-vortex-prompt"].services) {

		var service = runtimeDescriptor["pgs-vortex-prompt"].services[serviceId];

		for (var name in service.variables) {
			if (typeof service.variables[name].value !== "undefined") {
				process.stdout.write('export ' + name + '=' + service.variables[name].value + "\n");
			}
		}
	}

}
