**Status: DEV**

PINF.Genesis System (PGS)
=========================

[PINF.Genesis](http://genesis.pinf.org) is [my](http://christophdorn.com) first *constantly improving* incantation of [PINF](http://pinf.org) with a focus on:

  * Web Software Systems and
  * Web Software Development Workspaces

[PINF](http://pinf.org) is an abstract **Virtual Holographic Nodal Platform** discovered over more than 15 years of trial and error. **PINF.Genesis** is my first publicly consumable iteration of the implementation of the virtual PINF system.

Current Requirements:

  * OSX
  * NodeJS 10


Use PINF.Genesis
================

	cd YourNodeJSPackage

Setup
-----

#### Add 'genesis.pinf.org' as dependency

	npm install --save genesis.pinf.org

#### Trigger Initialization on install by adding to 'package.json'

	"scripts": {
		"install": "./node_modules/.bin/genesis.pinf.org install -v"
	}

Use
---

#### Install [Development Workspace](http://genesis.pinf.org)

	npm install

#### Initialize Workspace

	./boot turn -v

#### Use Workspace

Upon workspace initialization above, the `YourNodeJSPackage/README.md` file will be updated with [more instructions](https://github.com/pinf/genesis.pinf.org/blob/master/.pgs/vortex/README.md).


Contribute to PINF.Genesis
==========================

#### Clone System

	git clone https://github.com/pinf/genesis.pinf.org.git
	cd genesis.pinf.org

Refer to [README.md file](https://github.com/pinf/genesis.pinf.org/blob/master/.pgs/vortex/README.md) to continue.


Legal
=====

[UNLICENSE](http://unlicense.org/) by [Christoph Dorn](http://christophdorn.com)

