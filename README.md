**Status: DEV**

PINF.Genesis System (PGS)
=========================

[PINF.Genesis](http://genesis.pinf.org) is [my](http://christophdorn.com) first *constantly improving* incantation of [PINF](http://pinf.org) with a focus on:

  * Web Software Systems and
  * Web Software Development Workspaces

[PINF](http://pinf.org) is an abstract **Virtual Holographic Nodal Platform** discovered over more than 15 years of trial and error. **PINF.Genesis** is my first isomorphic publicly consumable iteration of the implementation of the virtual PINF system.

Requirements:

  * OSX
  * NodeJS 10


Use PINF.Genesis
================

Setup
-----

	cd Your-NodeJS-Package

#### Create install script using [Bash.Origin](https://github.com/cadorn/bash.origin)

**chmod ug+x** `bin/install`:

	#!/bin/bash
	# Source https://github.com/cadorn/bash.origin
	. "$HOME/.bash.origin"
	function init {
		eval BO_SELF_BASH_SOURCE="$BO_READ_SELF_BASH_SOURCE"
		BO_deriveSelfDir ___TMP___ "$BO_SELF_BASH_SOURCE"
		local __BO_DIR__="$___TMP___"


		pushd "$__BO_DIR__/.." > /dev/null
			if [ ! -e ".pgs/.provisioned" ]; then
				BO_callPlugin "bash.origin.pinf@0.1.2" ensure genesis $@
			fi
		popd > /dev/null
	}
	init $@

#### Trigger install script on *npm install* by adding to 'package.json'

	"dependencies": {
		"bash.origin": "0.1.x"
	},
	"scripts": {
		"install": "./bin/install"
	}

Use
---

	cd Your-NodeJS-Package

#### Install [Development Workspace](http://devcomp.org)

	npm install

#### Initialize Workspace

	./boot turn -v

#### Use Workspace

Upon workspace initialization above, [more instructions](https://github.com/pinf/genesis.pinf.org/blob/master/.pgs/vortex/WORKSPACE.md) will be available at `Your-NodeJS-Package/WORKSPACE.md`.


Contribute to PINF.Genesis
==========================

#### Clone System

	git clone https://github.com/pinf/genesis.pinf.org.git
	cd genesis.pinf.org

#### Initialize Workspace

	./boot turn -v

#### Use Workspace

Upon workspace initialization above, [more instructions](https://github.com/pinf/genesis.pinf.org/blob/master/.pgs/vortex/WORKSPACE.md) will be available at `WORKSPACE.md`.


Provenance
==========

Original source logic [UNLICENSED](http://unlicense.org/) by [Christoph Dorn](http://christophdorn.com).

