#!/bin/bash

YADA_LIBS=../yada/libs/

STARLING_SWC=~/dev/starling/starling/bin/starling.swc
FEATHERS_SWC=~/dev/feathers/bin/feathers.swc
SKEIN_SWC=~/dev/skein/bin/skein-1.0.0.swc

SPICELIB_COMMANDS_SWC=~/dev/rozdonmobile/spicelib-commands/bin/spicelib-commands-3.1.1.swc
SPICELIB_LOGGING_SWC=~/dev/rozdonmobile/spicelib-logging/bin/spicelib-logging.swc
SPICELIB_REFLECT_SWC=~/dev/rozdonmobile/spicelib-reflect/bin/spicelib-reflect-3.0.0.swc
SPICELIB_UTIL_SWC=~/dev/rozdonmobile/spicelib-util/bin/spicelib-util-3.1.0.swc
SPICELIB_XML_MAPPER_SWC=~/dev/rozdonmobile/spicelib-xml-mapper/bin/spicelib-xml-mapper-3.0.2.swc

PARSLEY_CORE_SWC=~/dev/rozdonmobile/parsley-core/bin/release/parsley-core-3.0.0.swc
PARSLEY_XML_SWC=~/dev/rozdonmobile/parsley-core/bin/release/parsley-xml-3.0.0.swc
PARSLEY_STARLING_SWC=~/dev/rozdonmobile/parsley-starling/bin/parsley-starling.swc

CAIRNGORM_NAVIGATION_SWC=~/dev/rozdonmobile/cairngorm-navigation/bin/cairngorm-navigation.swc
CAIRNGORM_NAVIGATION_PARSLEY_SWC=~/dev/rozdonmobile/cairngorm-navigation-parsley/bin/cairngorm-navigation-parsley.swc
CAIRNGORM_NAVIGATION_FEATHERS_SWC=~/dev/rozdonmobile/cairngorm-navigation-feathers/bin/cairngorm-navigation-feathers.swc

cp -R $STARLING_SWC $YADA_LIBS
cp -R $FEATHERS_SWC $YADA_LIBS
cp -R $SKEIN_SWC $YADA_LIBS

cp -R $SPICELIB_COMMANDS_SWC $YADA_LIBS
cp -R $SPICELIB_LOGGING_SWC $YADA_LIBS
cp -R $SPICELIB_REFLECT_SWC $YADA_LIBS
cp -R $SPICELIB_UTIL_SWC $YADA_LIBS
cp -R $SPICELIB_XML_MAPPER_SWC $YADA_LIBS

cp -R $PARSLEY_CORE_SWC $YADA_LIBS
cp -R $PARSLEY_XML_SWC $YADA_LIBS
cp -R $PARSLEY_STARLING_SWC $YADA_LIBS

cp -R $CAIRNGORM_NAVIGATION_SWC $YADA_LIBS
cp -R $CAIRNGORM_NAVIGATION_PARSLEY_SWC $YADA_LIBS
cp -R $CAIRNGORM_NAVIGATION_FEATHERS_SWC $YADA_LIBS