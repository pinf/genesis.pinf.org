
const PATH = require("path");
const FS = require("fs");
const EXEC = require("child_process").exec;

var commands = [];
FS.readFileSync(PATH.join(process.cwd(), ".gitignore"), "utf8").split("\n").forEach(function (line) {
	line = line.replace(/\s/g, "");
	if (!line) return;
	if (/^#/.test(line)) return;
	if (/^!\//.test(line)) {
		commands.push('rm -Rf ' + line.substring(2));
		commands.push("git checkout HEAD -- " + line.substring(2));
		return;
	}
	if (/^\//.test(line)) {
		// Don't remove these files if in 'genesis.pinf.org'.
		if (PATH.basename(process.cwd()) === "genesis.pinf.org") {
			if (/^\/.pgs\/$/.test(line)) return;
			if (/^\/boot/.test(line)) return;
			if (/^\/package\.json/.test(line)) return;
		}
		commands.push('rm -Rf ' + line.substring(1));
	}
});


var cwd = PATH.dirname(__dirname);
process.stdout.write("Cleaning for directory '" + cwd + "':\n");
// TODO: Only print output on debug.
commands.forEach(function (command) {
	process.stdout.write(command + "\n");
});


EXEC(commands.join("; "), {
	cwd: cwd
});
