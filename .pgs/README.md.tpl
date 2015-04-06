%%BASENAME%%
============


Usage
-----

One-time:

	git clone <uri> %%BASENAME%%
	cd %%BASENAME%%

For **every** change:

	./boot [-vd]

	source bin/activate

	# Make changes ...

	test

	clean

	# Commit changes & push

Upon `boot` a system will be initialized and running ready for exploration using your default browser which should have been opened.

Upon `activation` a command-line environment is loaded from which projects may be manipulated for the purpose of development. Once activated, the prompt will change and more commands are available. Run `help` for more information.


License
=======

This system is a clone of [genesis.pinf.org](http://genesis.pinf.org).

[UNLICENSE](http://unlicense.org/)

