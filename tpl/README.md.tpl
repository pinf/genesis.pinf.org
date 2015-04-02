{{$from.system.label}}
======================

{{$from.system.description}}


Install
=======

	git clone https://github.com/codi-sh/codi.sh {{$from.system.basename}}
	cd {{$from.system.basename}}

	bin/install    # Ends with 'INSTALL DONE' on succcess


Run
---

	bin/demo       # Ends with 'DEMOS DONE' on succcess
	bin/test       # Ends with 'TESTS DONE' on succcess

Please [file an issue]({{$from.system.issues.url}}) if you run into an error.


Contribute
----------

	source bin/activate

Loads a command-line environment from which projects may be manipulated for the purpose of development. Once activated, the prompt will change and more commands are available. Run `help` for more information.

