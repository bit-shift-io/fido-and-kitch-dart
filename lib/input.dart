import 'package:flame/components.dart';
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

enum GestureEventType {
  Drag,
}

enum GestureState {
  Start,
  End,
  Update
}

class GestureEvent {
  GestureState state;
  GestureEventType type;
  Vector2 velocity;

  GestureEvent(this.type, this.state, this.velocity);
}