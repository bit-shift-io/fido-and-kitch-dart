import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:tiled/tiled.dart' as t;

import 'entity.dart';
import 'mixins.dart';
import 'visitor.dart';

extension Resolve on Component {
  void resolveChildren(Entity entity) {
    // notify children
    if (this is BaseComponent) {
      final bc = this as BaseComponent;
      for (final c in bc.children) {
        c.resolve(entity);
      }
    }
  }

  void resolve(Entity entity) {
    if (this is HasName) {
      final hn = this as HasName;
      print("\tresolve called on ${hn.name}");
    }
    
    // can we not use the same mechanic as HasGameRef?
    // not likely as we cant mixin HasEntity with BaseComponent
    if (this is HasEntity) {
      final ce = this as HasEntity;
      ce.entity = entity;
    }

    if (this is WithResolve) {
      final wr = this as WithResolve;
      wr.resolve(entity);
      // return here? this would mean WithResolve needs to notify all children
      return;
    }

    this.resolveChildren(entity);
/*
    // notify children
    if (this is BaseComponent) {
      final bc = this as BaseComponent;
      for (final c in bc.children) {
        c.resolve(entity);
      }
    }*/
  }

  visit(ComponentVisitor visitor) {
    if (this is Component) {
      visitor.visit(this);
    }
  }
}

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

  T? findFirstChild<T>(String name, {bool recursive = true}) {
    for (final c in children) {
      if (c is HasName) {
        HasName cname = c as HasName;
        if (cname.name == name) {
          return c as T;
        }
      }
    }

    for (final c in children) {
      if (c is BaseComponent) {
        T? t = c.findFirstChild(name, recursive: recursive);
        if (t != null) {
          return t;
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

extension BodyExtras on Body {
  void setPosition(Vector2 position) {
    this.setTransform(position, this.angle);
  }
}

extension TiledObjectExtras on t.TiledObject {
  Vector2 get positionCenter {
    return this.isRectangle ? Vector2(this.x, this.y) + (Vector2(this.width, -this.height) * 0.5) : Vector2(this.x, this.y);
  } 
}