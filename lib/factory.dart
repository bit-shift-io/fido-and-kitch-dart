
import 'package:fido_and_kitch/components/script_component.dart';
import 'package:flame/components.dart';
import 'components/inventory_component.dart';
import 'components/sprite_animation_component.dart';
import 'components/sprite_component.dart';
import 'components/entity.dart';
import 'components/pickup_component.dart';
import 'components/tmxobject_component.dart';
import 'components/usable_component.dart';
import 'player.dart';
import 'components/position_component.dart';
import 'components/switch_component.dart';
import 'utils/yaml.dart';

typedef Future<T> CreateComponentFromData<T>(dynamic yaml);

class Factory {

  static final Factory _singleton = Factory._internal();

  factory Factory() {
    return _singleton;
  }

  Factory._internal();

  Map<String, CreateComponentFromData> fromDataMap = {
    'SpriteAnimationComponent': spriteAnimationComponentFromData,
    'SpriteComponent': spriteComponentFromData,
    'SwitchComponent': switchComponentFromData,
    'PositionComponent': positionComponentFromData,
    'Entity': entityComponentFromData,
    'Player': playerComponentFromData,
    'PickupComponent': pickupComponentFromData,
    'UsableComponent': usableComponentFromData,
    'InventoryComponent': inventoryComponentFromData,
    'ScriptComponent': scriptComponentFromData,
    'TmxObjectComponent': tmxObjectComponentFromData,
  };

  void registerComponentFromData(String name, CreateComponentFromData creator) {
    fromDataMap[name] = creator;
  }

  Future<T> createFromFile<T>(String fileName, { Map<String, dynamic> substitutions }) async {
    final yaml = await loadYamlFromFile(fileName, substitutions: substitutions);
    print("creating entity: $fileName");
    return createFromData<T>(yaml);
  }

  Future<T> createFromData<T>(dynamic yaml) async {
    try {
      String componentName = yaml['component'];
      final creator = fromDataMap[componentName];
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

  Future<List<Component>> createFromDataArray(dynamic yaml) async {
    List<Component> array = [];
    if (yaml == null) {
      return array;
    }

    for (final c in yaml) {
      Component child = await createFromData<Component>(c);
      if (child != null) {
        array.add(child);
      }
    }
    return array;
  }

}
