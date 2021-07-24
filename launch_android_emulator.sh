#!/bin/bash

EMULATOR=$HOME/Library/Android/sdk/emulator/emulator

echo $EMULATOR
AVD=$($EMULATOR -list-avds | head -n 1)
echo $AVD
$EMULATOR -avd $AVD
