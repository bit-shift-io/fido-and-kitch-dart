#!/bin/bash
# https://github.com/hetu-script/hetu-script-autobinding/issues/5#issuecomment-858601380

yay --noconfirm --needed -S dart flutter
flutter pub get

# setup hetu script
# https://hetu.dev/
git clone https://github.com/hetu-script/hetu-script-autobinding.git
cd hetu-script-autobinding

# modify pubspec
tee pubspec.yaml > /dev/null << EOL       
name: hetu_binding_generator
description: A binding-code generator for Hetu script language. You can generate glue codes from Flutter/Dart library, your own codes, or any packages. Then you can use them in the Hetu script.
version: 1.0.15
homepage: https://github.com/hetu-script/hetu-script-autobinding

environment:
  sdk: '>=2.12.0 <3.0.0'

dependencies:
  analyzer: 1.1.0
  args: 2.0.0
  json_annotation: 4.0.0
  mustache_template: 2.0.0
  meta: <=1.3.0

dev_dependencies:
  json_serializable: 4.0.2
  pedantic: ^1.9.0
  test: ^1.14.4
EOL

dart pub get
./build.sh

#mkdir -p bin
#dart compile exe lib/main.dart -o bin/ht-binding-generator --no-sound-null-safety
# hetu script complete




echo -e '\n\ninstall complete'
notify-send 'Install' 'Install completed'
