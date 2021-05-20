
import 'package:flame/components.dart';

//
// A list of components with only 1 active at once
//
class SwitchComponent extends BaseComponent {
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
}