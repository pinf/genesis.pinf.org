
const PATH = require("path");
const FS = require("fs");
const EXEC = require("child_process").exec;

var commands = [];
FS.readFileSync(PATH.join(process.cwd(), ".gitignore"), "utf8").split("\n").forEach(function (line) {
	line = line.replace(/\s/g, "");
	if (!line) return;
	if (/^#/.test(line)) return;
	if (/^!/.test(line)) return;
	if (/^\//.test(line)) {
		// Don't remove these files if in 'genesis.pinf.org'.
console.log("PATH.basename(process.cwd())", PATH.basename(process.cwd()))		
		if (PATH.basename(process.cwd()) !== "genesis.pinf.org") {

console/log("LINE: " + line + " :LINE");

			if (/^\/.pgs\/$/.test(line)) return;
			if (/^\/boot/.test(line)) return;
			if (/^\/package\.json/.test(line)) return;
		}
		commands.push('rm -Rf ' + line.substring(1));
	}
});


// TODO: Only reset if files have not changed!
commands.push("git checkout HEAD -- README.md");
commands.push('rm -Rf .gitignore');
commands.push('rm -Rf main.js');
commands.push('rm -Rf program.json');

if (PATH.basename(process.cwd()) === "genesis.pinf.org") {
	commands.push("git checkout HEAD -- package.json");
} else {
	commands.push('rm -Rf package.json');
}


var cwd = PATH.dirname(__dirname);
process.stdout.write("Cleaning for directory '" + cwd + "':\n");
// TODO: Only print output on debug.
commands.forEach(function (command) {
//	process.stdout.write(command + "\n");
});


EXEC(commands.join("; "), {
	cwd: cwd
});
