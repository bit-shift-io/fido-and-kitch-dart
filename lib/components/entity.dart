import 'package:fido_and_kitch/components/mixins.dart';
import 'package:fido_and_kitch/components/visitor.dart';
import 'package:flame/components.dart' as c;

import '../utils/script.dart';
import 'extensions.dart';
import 'position.dart';
import '../factory.dart';
import '../game.dart';
import '../utils/yaml.dart';

class ResolveComponentVisitor extends ComponentVisitor {
  MyGame gameRef;
  Entity entity;

  ResolveComponentVisitor(this.gameRef, this.entity);

  void visit(c.Component c) {
    // can we not use the same mechanic as HasGameRef?
    // not likely as we cant mixin HasEntity with BaseComponent
    if (c is HasEntity) {
      final ce = c as HasEntity;
      ce.entity = entity;
    }
  }
}


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

  // Call this once loaded from file
  resolve(MyGame ref) {
    gameRef = ref;
    addToEntityLists(ref);

    ResolveComponentVisitor resolveVisitor = ResolveComponentVisitor(gameRef, this);
    visit(resolveVisitor);
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