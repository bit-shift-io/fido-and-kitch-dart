import 'package:flame/components.dart';

import 'mixins.dart';

extension AddChildren on BaseComponent {
  void addChildren(List<Component> children) async {
    for (final c in children) {
      this.addChild(c);
    }
  }

  T findFirstChild<T>(String name) {
    for (final c in children) {
      if (c is HasName) {
        HasName cname = c as HasName;
        if (cname.name == name) {
          return c as T;
        }
      }
    }

    return null;
  }
}