PINF.Genesis System (PGS)
=========================

**PINF.Genesis** is [my](http://christophdorn.com) first *clean* incantation of [PINF](http://pinf.org) with a focus on:

  * Web Software Systems and
  * Web Software Development Workspaces

To learn more visit [genesis.pinf.org](http://genesis.pinf.org) in a Web Browser.


Your own system based on PINF.Genesis
-------------------------------------

	mkdir MySystem
	cd MySystem

	echo "{}" > package.json

	npm install --save genesis.pinf.org

	./node_modules/.bin/genesis.pinf.org init

	./boot

	source bin/activate

	# Make changes ...

	test

	clean

	# Commit changes & push

Upon `boot` a system will be initialized and running ready for exploration using your default browser which should have been opened.

Refer to the generated README.md file at the root of `MySystem` any time you need to refresh your memory on how to boot or interact with the system.


Add PINF.Genesis to a package
-----------------------------

	cd MyPackage

	npm install --save genesis.pinf.org

Add to `package.json`:

	"scripts": {
		"install": "./node_modules/.bin/genesis.pinf.org install"
	}

Then:

	npm install

	.pinf/boot

	source .pinf/bin/activate

	# Make changes ...

	test

	clean

	# Commit changes & push

Upon `boot` a system will be initialized and running your package ready for exploration using your default browser which should have been opened.

Refer to the generated README.md file at the root of `.pinf` any time you need to refresh your memory on how to boot or interact with the system.


Hacking on PINF.Genesis
-----------------------

One-time:

	git clone https://github.com/pinf/genesis.pinf.org.git
	cd genesis.pinf.org

For **every** change:

	./boot

	source bin/activate

	# Make changes ...

	test

	clean

	# Commit changes & push


License
=======

[UNLICENSE](http://unlicense.org/)

