
# Created when turning template on boot

/bin/activate
/bin/demo
/bin/install
/bin/test
/bin/{{$from.system.basename}}
/bin/{{$from.system.basename}}.js


# Created when installing on boot

/bin/node
/bin/npm
/bin/smi
/node_modules/
/.pio.cache/


# Created when booting self

/.pinf.uid

