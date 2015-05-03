%%BASENAME%%
============

Usage
-----

Requirements:

  * OSX
  * NodeJS 10

#### Install [Development Workspace](http://devcomp.org)

	git clone <uri> %%BASENAME%%
	cd %%BASENAME%%

	npm install

#### Run Workspace

	./boot [-vd]

Upon `boot` a system will be initialized and running ready for exploration. If using [devcomp.org](http://devcomp.org) a *companion window* should have been opened.

#### Make changes

	source bin/activate

	# make changes ...

	test

	source clean

	# Commit changes & push

Upon `activation` a command-line environment is loaded from which the system may be manipulated for the purpose of development. Once activated, the prompt will change and more commands are available. Run `help` for more information.


Provenance
==========

The **Development Workspace** is a clone of [devcomp.org](http://devcomp.org) with original source logic [UNLICENSED](http://unlicense.org/) by [Christoph Dorn](http://christophdorn.com).
