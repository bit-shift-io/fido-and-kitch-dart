import 'package:flame/components.dart' as c;

import '../game.dart';
import 'entity.dart';
import 'mixins.dart';
import 'extensions.dart';
import 'physics_body.dart';
import 'position.dart';
import '../utils/script.dart';
import 'script.dart';

class AreaContactCallback implements ContactCallback<PhysicsBody, Area> {
  
  @override
  void begin(PhysicsBody a, Area b, Contact contact) {
    b.onEnterContact(a);
  }

  @override
  void end(PhysicsBody a, Area b, Contact contact) {
    b.onExitContact(a);
  }

  @override
  ContactTypes<PhysicsBody, Area> types = ContactTypes<PhysicsBody, Area>();

  @override
  void postSolve(PhysicsBody a, Area b, Contact contact, ContactImpulse impulse) {
    //print("postSolve");
  }

  @override
  void preSolve(PhysicsBody a, Area b, Contact contact, Manifold oldManifold) {
    //print("preSolve");
  }

}

//
// Detect objects entering and exiting
//
@HTBinding()
class Area extends c.BaseComponent with HasName, WithResolve, HasEntity, c.HasGameRef<Game> {
  Script? onEnter;
  Script? onExit;
  List<String> entityLayers = []; // the list of entity layers to check for 'collisions' that might trigger this
  bool enabled = true;
  PhysicsBody physicsBody = new PhysicsBody();

  Future<void> fromData(dynamic data) async {
    //await super.fromData(data);
    enabled = data['enabled'] ?? this.enabled;
    addChildIf(onEnter = scriptComponentFromString('onEnter', data['onEnter']));
    addChildIf(onExit = scriptComponentFromString('onExit', data['onExit']));

    BodyDef bodyDef = BodyDef();
    bodyDef.userData = this;
    physicsBody.bodyDef = bodyDef;
    Shape shape = shapeFromData(data['shape']);
    FixtureDef fixtureDef = FixtureDef(shape);
    fixtureDef.isSensor = true;
    physicsBody.fixureDefs.add(fixtureDef);
    addChild(physicsBody);
  }

  @override
  void resolve(Entity entity) {
    this.resolveChildren(entity);

    Position? p = entity.findFirstChildByClass<Position>();
    physicsBody.body!.setPosition(p!.center);
  }

  void onEnterContact(PhysicsBody body) {
    if (onEnter != null) {
      onEnter!.eval({'otherBody': body, 'otherEntity': body.entity});
    }
  }

  void onExitContact(PhysicsBody body) {
    if (onExit != null) {
      onExit!.eval({'otherBody': body, 'otherEntity': body.entity});
    }
  }
}

Future<Area> areaComponentFromData(dynamic data) async {
  final comp = new Area();
  await comp.fromData(data);
  return comp;
}