
const PATH = require("path");


var runtimeDescriptor = require(PATH.join(process.cwd(), "program.rt.json"));

if (runtimeDescriptor["pgs-prompt"]) {

	for (var serviceId in runtimeDescriptor["pgs-prompt"].services) {

		var service = runtimeDescriptor["pgs-prompt"].services[serviceId];

		for (var name in service.variables) {
			if (typeof service.variables[name].value !== "undefined") {
				process.stdout.write('export ' + name + '="' + service.variables[name].value + '"\n');
			}
		}
	}

}
