import 'package:flame/components.dart' as c;

import 'extensions.dart';
import 'position_component.dart';
import '../factory.dart';
import '../game.dart';

// root entity
// which will add itself to the appropriate world entity list
class Entity extends PositionComponent with c.HasGameRef<MyGame> {
  String entityList; // TODO: replace with a list, an entity might want to be in multiple lists

  Future<void> fromYaml(dynamic yaml) async {
    await super.fromYaml(yaml);
    entityList = yaml['entityList'];
  }

  addToEntityLists(MyGame ref) {
    ref.addEntity(this, entityList);
  }

  removeFromEntityLists(MyGame ref) {
    ref.removeEntity(this, entityList);
  }
/*
  set gameRef(MyGame ref) {
    //if ((!hasGameRef && ref != null) || (hasGameRef && gameRef != ref)) {
      addToEntityLists(ref);
    //}
    super.gameRef = ref;
  }*/
}

Future<Entity> entityComponentFromYaml(dynamic yaml) async {
  final comp = new Entity();
  await comp.fromYaml(yaml);
  return comp;
}