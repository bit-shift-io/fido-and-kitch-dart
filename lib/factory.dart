
import 'package:flame/components.dart';
import 'components/sprite_animation_component.dart';
import 'components/sprite_component.dart';
import 'player.dart';
import 'components/position_component.dart';
import 'components/switch_component.dart';
import 'utils/yaml.dart';

typedef Future<T> CreateComponentFromYaml<T>(dynamic yaml);

class Factory {

  static final Factory _singleton = Factory._internal();

  factory Factory() {
    return _singleton;
  }

  Factory._internal();

  Map<String, CreateComponentFromYaml> fromYamlMap = {
    'SpriteAnimationComponent': spriteAnimationComponentFromYaml,
    'SpriteComponent': spriteComponentFromYaml,
    'SwitchComponent': switchComponentFromYaml,
    'PositionComponent': positionComponentFromYaml,
    'Player': playerComponentFromYaml
  };

  void registerComponentFromYaml(String name, CreateComponentFromYaml creator) {
    fromYamlMap[name] = creator;
  }

  Future<T> createFromYamlFile<T>(String fileName) async {
    final yaml = await loadYamlFromFile(fileName);
    return createFromYaml<T>(yaml);
  }

  Future<T> createFromYaml<T>(dynamic yaml) async {
    String componentName = yaml['component'];
    final creator = fromYamlMap[componentName];
    if (creator == null) {
      return null;
    }
    return await creator(yaml);
  }

  Future<List<Component>> createFromYamlArray(dynamic yaml) async {
    List<Component> array = [];
    if (yaml == null) {
      return array;
    }

    for (final c in yaml) {
      Component child = await createFromYaml<Component>(c);
      array.add(child);
    }
    return array;
  }

}
