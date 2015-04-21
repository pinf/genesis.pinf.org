
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
