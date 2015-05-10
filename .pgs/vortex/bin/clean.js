
const PATH = require("path");
const FS = require("fs");
const EXEC = require("child_process").exec;


const VERBOSE = /(-\w*v|-\w*d)/.test(process.argv[2] || "");



var cwd = PATH.dirname(__dirname);

if (process.cwd() !== cwd) {
	throw new Error("This script is not being called from the root of the system or this script is not in the right place!");
}


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



var commands = [];


// TODO: Move this into sourcemint plugin that uses package insight and declarations.
// We remove installed transitive dependencies for all dependencies that are not symlinked in.
var depsPath = PATH.join(cwd, ".deps");
if (FS.existsSync(depsPath)) {
	// If '.deps' is a symlink we don't touch it at all.
	if (!FS.lstatSync(depsPath).isSymbolicLink()) {
		FS.readdirSync(depsPath).forEach(function (id) {			
			// If dependency is symlinked we don't touch it.
			if (
				!FS.lstatSync(PATH.join(depsPath, dir)).isSymbolicLink() &&
				FS.existsSync(PATH.join(depsPath, dir, "source")) &&
				!FS.lstatSync(PATH.join(depsPath, dir, "source")).isSymbolicLink() &&
				FS.existsSync(PATH.join(depsPath, dir, "source", "installed")) &&
				!FS.lstatSync(PATH.join(depsPath, dir, "source", "installed")).isSymbolicLink() &&
				FS.existsSync(PATH.join(depsPath, dir, "source", "installed", "master")) &&
				!FS.lstatSync(PATH.join(depsPath, dir, "source", "installed", "master")).isSymbolicLink()
			) {
				if (FS.existsSync(PATH.join(depsPath, dir, "source", "installed", "master", "node_modules"))) {
					commands.push('rm -Rf ' + PATH.join(".deps", dir, "source", "installed", "master", "node_modules"));
				}
				if (FS.existsSync(PATH.join(depsPath, dir, "source", "installed", "master", ".installed"))) {
					commands.push('rm -f ' + PATH.join(".deps", dir, "source", "installed", "master", ".installed"));
				}
			}
			var globalPath = PATH.join(process.env.HOME, ".bash.origin.cache", dir, "source", "installed", "master");
			if (
				FS.existsSync(globalPath) &&
				FS.lstatSync(globalPath).isSymbolicLink() &&
				FS.realpathSync(globalPath) === FS.realpathSync(PATH.join(depsPath, dir, "source", "installed", "master"))
			) {
				commands.push('rm -f ' + globalPath);
			}
		});
	}
}


var cleanIgnoreRules = getCleanIgnoreRule();

var stop = false;
FS.readFileSync(PATH.join(cwd, ".gitignore"), "utf8").split("\n").forEach(function (line) {
	if (stop) return;
	line = line.replace(/\s/g, "");
	if (!line) return;
	if (line === "#@STOP_CLEAN") {
		stop = true;
		return;
	}
	if (/^#/.test(line)) return;
	if (cleanIgnoreRules.indexOf(line) > -1) return;
	if (/^!\//.test(line)) {
		commands.push('rm -Rf ' + line.substring(2));
		commands.push("git checkout HEAD -- " + line.substring(2));
		return;
	}
	if (/^\//.test(line)) {
		// Don't remove these files if in 'genesis.pinf.org'.
		if (PATH.basename(cwd) === "genesis.pinf.org") {
			if (/^\/.pgs\/$/.test(line)) return;
			if (/^\/boot/.test(line)) return;
			if (/^\/package\.json/.test(line)) return;
		}
		commands.push('rm -Rf ' + line.substring(1));
	}
});

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

