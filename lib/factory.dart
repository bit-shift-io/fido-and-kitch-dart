
import 'package:flame/components.dart';

import 'utils.dart';

typedef Component ComponentConstructor(String name);

class Factory {

  static final Factory _singleton = Factory._internal();

  factory Factory() {
    return _singleton;
  }

  Factory._internal();

  Map<String, ComponentConstructor> constructors = Map();
  
  void registerComponentConstructor(String name, ComponentConstructor constructor) {
    constructors[name] = constructor;
  }

  Component createComponent(String name) {
    return null;
  }

  Component createComponentFromYaml(dynamic yaml) {
    return null;
  }

  Component createFromYaml(String fileName) {
    final yaml = loadYamlFromFile(fileName);
    String componentName = yaml['component'];
    return createComponentFromYaml(yaml);
  }
}

SpriteAnimation spriteAnimationFromYaml(dynamic yaml) {
}
