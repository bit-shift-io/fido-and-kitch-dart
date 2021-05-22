
import 'package:flame/components.dart';
import 'components/inventory_component.dart';
import 'components/sprite_animation_component.dart';
import 'components/sprite_component.dart';
import 'components/entity.dart';
import 'components/pickup_component.dart';
import 'components/usable_component.dart';
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
    'Entity': entityComponentFromYaml,
    'Player': playerComponentFromYaml,
    'PickupComponent': pickupComponentFromYaml,
    'UsableComponent': usableComponentFromYaml,
    'InventoryComponent': inventoryComponentFromYaml
  };

  void registerComponentFromYaml(String name, CreateComponentFromYaml creator) {
    fromYamlMap[name] = creator;
  }

  Future<T> createFromYamlFile<T>(String fileName) async {
    final yaml = await loadYamlFromFile(fileName);
    print("creating entity: $fileName");
    return createFromYaml<T>(yaml);
  }

  Future<T> createFromYaml<T>(dynamic yaml) async {
    try {
      String componentName = yaml['component'];
      final creator = fromYamlMap[componentName];
      if (creator == null) {
        print('No creator found for $componentName');
        return null;
      }
      print("\tcreating component: $componentName with name ${yaml['name']}");
      return await creator(yaml);
    } catch(e) {
      print(e);
      return null;
    }
  }

  Future<List<Component>> createFromYamlArray(dynamic yaml) async {
    List<Component> array = [];
    if (yaml == null) {
      return array;
    }

    for (final c in yaml) {
      Component child = await createFromYaml<Component>(c);
      if (child != null) {
        array.add(child);
      }
    }
    return array;
  }

}
