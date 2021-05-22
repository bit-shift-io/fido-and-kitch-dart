
import 'package:flame/components.dart';

import '../factory.dart';
import 'mixins.dart';

//
// A list of components with only 1 active at once
//
class SwitchComponent extends BaseComponent with HasName {
  Map<String, Component> components = Map();

  Component activeComponent;

  void addComponent(String name, Component component) {
    components[name] = component;
  }

  void setActiveComponent(String name) {
    removeChild(activeComponent);
    activeComponent = components[name];
    if (activeComponent != null) {
      addChild(activeComponent);
    }
  }

  Future<void> fromYaml(dynamic yaml) async {
    name = yaml['name'];
    final children = yaml['components'];
    for (final c in children) {
      Component child = await Factory().createFromYaml<Component>(c);
      if (child != null) {
        addComponent(c['name'], child);
      }
    }

    final activeComponent = yaml['activeComponent'];
    setActiveComponent(activeComponent);

    // support random initial component?
  }
}

Future<SwitchComponent> switchComponentFromYaml(dynamic yaml) async {
  final comp = new SwitchComponent();
  await comp.fromYaml(yaml);
  return comp;
}