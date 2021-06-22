import 'package:flame/components.dart' as c;

import '../utils/script.dart';
import 'extensions.dart';
import 'position.dart';
import '../game.dart';
import '../utils/yaml.dart';

// root entity
// which will add itself to the appropriate world entity list
@HTBinding()
class Entity extends Position with c.HasGameRef<MyGame> {
  List<String> entityList = [];

  Future<void> fromData(dynamic yaml) async {
    entityList = toStringList(yaml['entityList']);
    await super.fromData(yaml);
  }

  addToEntityLists(MyGame ref) {
    ref.addEntity(this, entityList);
  }

  removeFromEntityLists(MyGame ref) {
    ref.removeEntity(this, entityList);
  }

  // Call this once loaded from file
  resolve(MyGame ref) {
    gameRef = ref;
    addToEntityLists(ref);

    for (final c in children) {
      c.resolve(this);
    }
  }
}

Future<Entity> entityComponentFromData(dynamic yaml) async {
  final comp = new Entity();
  await comp.fromData(yaml);
  return comp;
}