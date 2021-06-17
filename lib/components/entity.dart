import 'package:flame/components.dart' as c;

import '../utils/script.dart';
import 'extensions.dart';
import 'position.dart';
import '../factory.dart';
import '../game.dart';
import '../utils/yaml.dart';


// root entity
// which will add itself to the appropriate world entity list
@HTBinding()
class Entity extends Position with c.HasGameRef<MyGame> {
  List<String> entityList = [];

  Future<void> fromData(dynamic yaml) async {
    await super.fromData(yaml);
    
    entityList = toStringList(yaml['entityList']);
    print(entityList);
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

Future<Entity> entityComponentFromData(dynamic yaml) async {
  final comp = new Entity();
  await comp.fromData(yaml);
  return comp;
}