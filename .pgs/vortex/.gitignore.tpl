
##################################################
# Common environment dirt (remove on clean)
##################################################

.DS_Store
/.pio.cache/
/.rt/


##################################################
# Created on PGS Install (remove on clean)
##################################################

/.pgs/
/boot
/.gitmodules.initialized


##################################################
# Created on PGS Expand (remove on clean)
##################################################

/.pgs/.pinf/
/.pgs/program.rt.json
/bin/
/.pinf/
/program.rt.json


##################################################
# Created on PGS Expand (reset on clean)
##################################################

!/README.md
!/.gitignore
!/.distignore
!/.cleanignore
!/vortex.js
!/program.json
!/package.json
!/%%BASENAME%%.inf
!/%%BASENAME%%.inf.js


# Mark the end of all files that will be cleaned
#@STOP_CLEAN


##################################################
# Created on PGS Install (keep on clean)
##################################################

/.deps
/node_modules/


##################################################
# Custom rules (keep on clean)
##################################################

%%__EXISTING__%%

