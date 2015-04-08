PINF.Genesis System (PGS)
=========================

**PINF.Genesis** is [my](http://christophdorn.com) first *clean* incantation of [PINF](http://pinf.org) with a focus on:

  * Web Software Systems and
  * Web Software Development Workspaces

To learn more visit [genesis.pinf.org](http://genesis.pinf.org) in a Web Browser.


Your own system based on PINF.Genesis
-------------------------------------

### Create System

	mkdir MySystem
	cd MySystem

	echo "{}" > package.json

### Add genesis.pinf.org as dependency

	npm install --save genesis.pinf.org

### Initialize System

	./node_modules/.bin/genesis.pinf.org init

Refer to the [generated README.md file](https://github.com/pinf/genesis.pinf.org/tree/cleanup/.pgs/vortex) at the root of `MySystem` to continue.


Add PINF.Genesis to a package
-----------------------------

### Add genesis.pinf.org as dependency

	cd MyPackage

	npm install --save genesis.pinf.org

### Trigger System Initialization on install by adding to `package.json`

	"scripts": {
		"install": "./node_modules/.bin/genesis.pinf.org install"
	}

### Initialize System

	npm install

Refer to the [generated README.md file](https://github.com/pinf/genesis.pinf.org/tree/cleanup/.pgs/vortex) at the root of `MyPackage` to continue.


Hacking on PINF.Genesis
-----------------------

### Clone System

	git clone https://github.com/pinf/genesis.pinf.org.git
	cd genesis.pinf.org

Refer to the [generated README.md file](https://github.com/pinf/genesis.pinf.org/tree/cleanup/.pgs/vortex) at the root of `MyPackage` to continue.


License
=======

[UNLICENSE](http://unlicense.org/)

