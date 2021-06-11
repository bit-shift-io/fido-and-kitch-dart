#!/bin/bash
# https://github.com/hetu-script/hetu-script-autobinding/issues/5#issuecomment-858601380

flutter pub get

git clone https://github.com/hetu-script/hetu-script-autobinding.git

cd hetu-script-autobinding

dart pub get

./build.sh

#mkdir -p bin
#dart compile exe lib/main.dart -o bin/ht-binding-generator --no-sound-null-safety