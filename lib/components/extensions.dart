import 'package:flame/components.dart';

import 'mixins.dart';
import 'visitor.dart';

extension AddChildren on BaseComponent {
  void addChildIf(Component? child) async {
    if (child != null) {
      await this.addChild(child);
    }
  }

  void addChildren(List<Component> children) async {
    for (final c in children) {
      this.addChild(c);
    }
  }

  T? findFirstChild<T>(String name) {
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

  List<T> findChildrenByClass<T>() {
    List<T> found = [];
    for (final c in children) {
      if (c is T) {
        found.add(c as T);
      }
    }
    return found;
  }

  T? findFirstChildByClass<T>() {
    for (final c in children) {
      if (c is T) {
        return c as T;
      }
    }
    return null;
  }

  visit(ComponentVisitor visitor) {
    visitor.visit(this);

    for (final c in children) {
      if (c is BaseComponent) {
        c.visit(visitor);
      }
    }
  }
}