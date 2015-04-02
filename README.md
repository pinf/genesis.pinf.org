PINF.Genesis
============

**PINF.Genesis** is [my](http://christophdorn.com) first *clean* incantation of [PINF](http://pinf.org) with a focus on web software systems and development workspaces.

To learn more visit [genesis.pinf.org](http://genesis.pinf.org) in a Web Browser.


Your own system based on PINF.Genesis
-------------------------------------

	mkdir MySystem
	cd MySystem

	echo "{}" > package.json

	npm install --save genesis.pinf.org

	./node_modules/.bin/genesis.pinf.org boot

Upon completion a system will be initialized and running ready for exploration using your default browser which should have been opened.

Refer to the generated README.md file at the root of `MySystem` any time you need to refresh your memory on how to boot or interact with the system.


Hacking on PINF.Genesis
-----------------------

	git clone https://github.com/pinf/genesis.pinf.org.git
	cd genesis.pinf.org

	./bin/boot


License
=======

[UNLICENSE](http://unlicense.org/)

