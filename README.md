**Status: DEV**

PINF.Genesis System (PGS)
=========================

[PINF.Genesis](http://genesis.pinf.org) is [my](http://christophdorn.com) first *constantly improving* incantation of [PINF](http://pinf.org) with a focus on:

  * Web Software Systems and
  * Web Software Development Workspaces

[PINF](http://pinf.org) is an abstract **Virtual Holographic Nodal Platform** discovered over more than 15 years of trial and error. **PINF.Genesis** is my first publicly consumable iteration of the implementation of the virtual PINF system.

Overview
--------

The diagram below illustrates the *core of PGS* by showing the

  * Boot sequence originally initiated by Human User
  * Data and interaction spaces managed by system
  * **System-wide Event Loop** capturing **ALL** modifications to system

as implemented by [DeveloperCompanion](http://devcomp.org). **DeveloperCompanion** is the **REFERENCE IMPLEMENTATION** of how I would build a system using PGS and doubles as a *100% open and hackable dev system that can be used for collaborative realtime distributed system development*.

![PGS Overview Diagram](https://raw.githubusercontent.com/pinf/genesis.pinf.org/cleanup/.pgs/docs/2015-03%20-%20Overview.jpg)

Current Requirements:

  * OSX
  * NodeJS 10


Your own system based on PINF.Genesis
-------------------------------------

#### Create System

	mkdir MySystem
	cd MySystem

	echo "{}" > package.json

#### Add genesis.pinf.org as dependency

	npm install --save genesis.pinf.org

#### Initialize System

	./node_modules/.bin/genesis.pinf.org install

Refer to the [generated README.md file](https://github.com/pinf/genesis.pinf.org/tree/cleanup/.pgs/vortex) at the root of `MySystem` to continue.


Add PINF.Genesis to a package
-----------------------------

#### Add genesis.pinf.org as dependency

	cd MyPackage

	npm install --save genesis.pinf.org

#### Trigger System Initialization on install by adding to `package.json`

	"scripts": {
		"install": "./node_modules/.bin/genesis.pinf.org install"
	}

#### Initialize System

	npm install

Refer to the [generated README.md file](https://github.com/pinf/genesis.pinf.org/tree/cleanup/.pgs/vortex) at the root of `MyPackage` to continue.


Hacking on PINF.Genesis
-----------------------

#### Clone System

	git clone https://github.com/pinf/genesis.pinf.org.git
	cd genesis.pinf.org

Refer to the [generated README.md file](https://github.com/pinf/genesis.pinf.org/tree/cleanup/.pgs/vortex) at the root of `MyPackage` to continue.


License
=======

[UNLICENSE](http://unlicense.org/)

