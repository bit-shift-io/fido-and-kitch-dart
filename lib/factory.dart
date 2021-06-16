
import 'components/script.dart';
import 'package:flame/components.dart';
import 'components/inventory.dart';
import 'components/sprite_animation.dart';
import 'components/sprite.dart';
import 'components/entity.dart';
import 'components/pickup.dart';
import 'components/tiled_object.dart';
import 'components/usable.dart';
import 'player.dart';
import 'components/position.dart';
import 'components/switch.dart';
import 'utils/yaml.dart';

typedef Future<T> CreateComponentFromData<T>(dynamic yaml);

class Factory {

  static final Factory _singleton = Factory._internal();

  factory Factory() {
    return _singleton;
  }

  Factory._internal();

  Map<String, CreateComponentFromData> fromDataMap = {
    'SpriteAnimation': spriteAnimationComponentFromData,
    'Sprite': spriteComponentFromData,
    'Switch': switchComponentFromData,
    'PositionComponent': positionComponentFromData,
    'Entity': entityComponentFromData,
    'Player': playerComponentFromData,
    'Pickup': pickupComponentFromData,
    'Usable': usableComponentFromData,
    'Inventory': inventoryComponentFromData,
    'Script': scriptComponentFromData,
    'TiledObject': tiledObjectComponentFromData,
  };

  void registerComponentFromData(String name, CreateComponentFromData creator) {
    fromDataMap[name] = creator;
  }

  Future<T?> createFromFile<T>(String fileName, { Map<String, dynamic>? substitutions }) async {
    final yaml = await loadYamlFromFile(fileName, substitutions: substitutions);
    print("creating entity: $fileName");
    return createFromData<T>(yaml);
  }

  Future<T?> createFromData<T>(dynamic yaml) async {
    String componentName = yaml['component'];
    try {
      final creator = fromDataMap[componentName];
      if (creator == null) {
        print('No creator found for $componentName');
        return null;
      }
      print("\tcreating component: $componentName with name ${yaml['name']}");
      return await creator(yaml);
    } catch(e) {
      print("\terror creating component: $componentName with name ${yaml['name']}:");
      print("\t\t" + e.toString());
      return null;
    }
  }

  Future<List<Component>> createFromDataArray(dynamic yaml) async {
    List<Component> array = [];
    if (yaml == null) {
      return array;
    }

    for (final c in yaml) {
      Component? child = await createFromData<Component>(c);
      if (child != null) {
        array.add(child);
      }
    }
    return array;
  }

}
