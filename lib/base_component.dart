
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';

// when we get to upgrade the flame engine we can just use this:
// https://github.com/flame-engine/flame/blob/733b003d9f2413cad85dc10b6e6c26db036c533e/packages/flame/lib/src/components/base_component.dart
// 
class ChildComponents {
  List<Component> children = [];

  void render(Canvas c) {
    for (Component ch in children) {
      ch.render(c);
    }
  }

  void update(double dt) {
    for (Component ch in children) {
      ch.update(dt);
    }
  }

  addChild(ch) {
    children.add(ch);
  }
}