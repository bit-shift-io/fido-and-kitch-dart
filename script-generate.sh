#!/bin/bash

FLUTTER_PUB_CACHE="~/.pub-cache"
FLUTTER_ROOT="/usr/local/Caskroom/flutter/2.0.4/flutter"

ROOT_DIR=$(pwd)

hetu-script-autobinding/bin/ht-binding-generator \
-f $FLUTTER_ROOT/ \
-o $ROOT_DIR/lib/auto_bindings \
-u $ROOT_DIR/lib/ \
-s $ROOT_DIR/ht-lib/ \
-j $ROOT_DIR/gen/json \
> $ROOT_DIR/script-generate-log.log