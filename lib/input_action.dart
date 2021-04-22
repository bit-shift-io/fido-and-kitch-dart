import 'package:flutter/services.dart';

class InputAction {
  String keyLabel;
  bool isKeyDown = false;

  InputAction({this.keyLabel, this.isKeyDown});

  void onKeyEvent(e) {
    if (e.data.keyLabel == keyLabel) {
      isKeyDown = e is RawKeyDownEvent;
    }
  }
}