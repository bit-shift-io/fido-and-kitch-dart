import 'package:flame/components.dart';

import 'entity.dart';
import 'visitor.dart';

mixin HasName {
  String? _name;

  //@override
  String? get name {
    return _name;
  }

  set name(String? n) {
    _name = n;
  }
}

mixin HasEntity {
  Entity? _entity;

  Entity? get entity {
    return _entity;
  }

  set entity(Entity? entity) {
    _entity = entity;
    if (this is BaseComponent) {
      (this as BaseComponent)
          .children
          .whereType<HasEntity>()
          .forEach((e) => e.entity = entity);
    }
  }
}

mixin WithComponentVisitor {
  visit(ComponentVisitor visitor) {
    if (this is Component) {
      Component c = this as Component;
      visitor.visit(c);
    }
  }
}