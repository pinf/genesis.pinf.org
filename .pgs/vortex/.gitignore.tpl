
# NOTE: This file is AUTO-GENERATED once by './.pgs/' by taking the template
#       from https://github.com/pinf/genesis.pinf.org/blob/master/.pgs/vortex/.gitignore.tpl
#       and inserting any content from a pre-existing file into '% %__EXISTING__% %'.
#       This file may be comitted to git and maintained manually from now on. If not comitted
#       to git, the pre-existing file content will be recovered on 'clean' by doing
#       a 'git reset'.
#       If you don't want './.pgs/' to leave any trace behind in your original code,
#       DO NOT COMMIT THIS CODE (remove line if you decide to do so)

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

# Is always taken from the workspace implementation plugin such as devcomp.org
/WORKSPACE.md

# Is always generated based on PINF.json and is environment dependent.
/program.json
/%%BASENAME%%.inf
/%%BASENAME%%.inf.js


##################################################
# Created on PGS Expand (reset on clean)
##################################################

!/bin/reset
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

