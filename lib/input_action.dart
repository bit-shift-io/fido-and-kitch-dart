import 'package:flutter/services.dart';


Map<String, LogicalKeyboardKey> keyLookup = {
  'ArrowLeft': LogicalKeyboardKey.arrowLeft,
  'ArrowRight': LogicalKeyboardKey.arrowRight,
  'ArrowUp': LogicalKeyboardKey.arrowUp,
  'ArrowDown': LogicalKeyboardKey.arrowDown,
  'e': LogicalKeyboardKey.keyE,
};

class InputAction {
  String keyLabel;
  bool isKeyDown = false;
  LogicalKeyboardKey? logicalKey;

  InputAction({this.keyLabel = '', this.isKeyDown = false}) {
    logicalKey = keyLookup[keyLabel];
  }

  void onKeyEvent(e) {
    if (e.logicalKey == logicalKey) {
      isKeyDown = e is RawKeyDownEvent;
    }
/*
    if (e.data.keyLabel == keyLabel) {
      isKeyDown = e is RawKeyDownEvent;
    }*/
  }
}