
const PATH = require("path");
const FS = require("fs");
const EXEC = require("child_process").exec;


const VERBOSE = /(-\w*v|-\w*d)/.test(process.argv[2] || "");


// TODO: Based on ignore rules of each program, remove all temporary assets
//       for each nested in-tree program (skip symlinked programs).

function getCleanIgnoreRule () {
	var path = PATH.join(process.cwd(), ".cleanignore");
	if (!FS.existsSync(path)) {
		return {};
	}
	return FS.readFileSync(path, "utf8").split("\n").map(function(rule) {
		return rule.replace(/\s/g, "");
	});
}

var cleanIgnoreRules = getCleanIgnoreRule();


var ignorePrefixes = [];

var depsPath = PATH.join(process.cwd(), ".deps");
if (FS.existsSync(depsPath)) {
	if (FS.lstatSync(depsPath).isSymbolicLink()) {
		ignorePrefixes.push(new RegExp("^\\/\\.deps"));
	} else {
		FS.readdirSync(depsPath).forEach(function (dir) {
			if (FS.lstatSync(PATH.join(depsPath, dir)).isSymbolicLink()) {
				ignorePrefixes.push(new RegExp("^\\/\\.deps\\/" + dir.replace(/\./g, "\\.")));
			}
		});
	}
}


var commands = [];
var stop = false;
FS.readFileSync(PATH.join(process.cwd(), ".gitignore"), "utf8").split("\n").forEach(function (line) {
	if (stop) return;
	line = line.replace(/\s/g, "");
	if (!line) return;
	if (line === "#@STOP_CLEAN") {
		stop = true;
		return;
	}
	if (/^#/.test(line)) return;
	if (cleanIgnoreRules.indexOf(line) > -1) return;
	if (ignorePrefixes.length > 0) {
		for (var i = 0; i < ignorePrefixes.length ; i++) {
			if (ignorePrefixes[i].test(line)) {
				return;
			}
		}
	}
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

if (VERBOSE) {
	process.stdout.write("Cleaning for directory '" + cwd + "':\n");
	commands.forEach(function (command) {
		process.stdout.write(command + "\n");
	});
}

EXEC(commands.join("; "), {
	cwd: cwd
});


if (
	FS.existsSync(PATH.join(cwd, "PINF.json")) &&
	FS.readFileSync(PATH.join(cwd, "PINF.json"), "utf8") === "{}"
) {
	FS.unlinkSync(PATH.join(cwd, "PINF.json"));
}

