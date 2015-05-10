
##################################################
# Common environment dirt (remove on clean)
##################################################

.DS_Store
/.pio.cache/
/.rt/
/**/.rt/


##################################################
# Created on PGS Install (remove on clean)
##################################################

/.pgs

# Stops provisioning from being re-run during boot
/.pgs/.provisioned

/boot
/node_modules/


##################################################
# Created on PGS Expand (remove on clean)
##################################################

/.pgs/.pinf/
/.pgs/program.rt.json
/bin/node
/bin/npm
/bin/smi
/bin/activate
/bin/activate.js
/bin/clean
/bin/clean.js
/bin/demo.harness
/bin/test.harness
/.pinf/
/program.rt.json

# Is always taken from the workspace implementation plugin such as devcomp.org
/WORKSPACE.md

# Is always generated based on PINF.json and is environment dependent.
/program.json
/%%BASENAME%%.inf
/%%BASENAME%%.inf.js


##################################################
# Created on PGS Expand (reset on clean)
##################################################

!/.gitignore
!/.distignore
!/.cleanignore
!/vortex.js
!/package.json


# Mark the end of all files that will be cleaned
#@STOP_CLEAN


##################################################
# Created on PGS Install (keep on clean)
##################################################

# Contains git submodules in pattern '.deps/github.com~ORG~REPO~MAJOR_VER/source/installed/master' if any
/.deps

# Stops git submodules from being re-initialized on provisioning during first boot
/.gitmodules.initialized


##################################################
# Custom rules (keep on clean)
##################################################

%%__EXISTING__%%

