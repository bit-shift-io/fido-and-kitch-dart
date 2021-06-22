
import 'package:fido_and_kitch/components/visitor.dart';
import 'package:flame/components.dart';

import '../factory.dart';
import 'entity.dart';
import 'mixins.dart';
import 'extensions.dart';
import '../utils/script.dart';

//
// A list of components with only 1 active at once
//
@HTBinding()
class Switch extends BaseComponent with HasName, WithResolve, WithComponentVisitor {
  Map<String, Component> components = Map();

  Component? activeComponent;

  void addComponent(String name, Component component) {
    components[name] = component;
  }

  void setActiveComponent(String? name) {
    if (activeComponent != null) {
      removeChild(activeComponent!);
    }
    activeComponent = components[name];
    if (activeComponent != null) {
      addChild(activeComponent!);
    }
  }

  Future<void> fromData(dynamic yaml) async {
    name = yaml['name'];
    final children = yaml['components'];
    for (final c in children) {
      Component? child = await Factory().createFromData<Component>(c);
      if (child != null) {
        addComponent(c['name'], child);
      }
    }

    String? activeComponent = yaml['activeComponent'];
    setActiveComponent(activeComponent);

    // support random initial component?
  }

  @override
  void resolve(Entity entity) {
    // notify children
    for (final c in components.values.toList()) {
      if (activeComponent != c) {
        c.resolve(entity);
      }
    }
  }
  
  @override
  visit(ComponentVisitor visitor) {
    print("TODO: switch.visit");
  }
}

Future<Switch> switchComponentFromData(dynamic yaml) async {
  final comp = new Switch();
  await comp.fromData(yaml);
  return comp;
}