import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Position;
import 'package:flame/components.dart' as c;
import './position.dart';
import '../factory.dart';
import '../utils/yaml.dart';
import 'entity.dart';
import 'mixins.dart';


// flame_forge2d sucks! loos it and just use forge2d?
class PhysicsBody extends BodyComponent with HasName, WithResolve {
  c.PositionComponent? positionComponent;

  @override
  bool debugMode = false;

  @override
  void update(double dt) {
    super.update(dt);
    updatePositionComponent();
  }

  void updatePositionComponent() {
    if (positionComponent != null) {
      positionComponent!.position..setFrom(body.position);
      positionComponent!.position.y *= -1;
      positionComponent!
        ..angle = -angle;
        //..size = size;
    }
  }

  Future<void> fromData(dynamic yaml) async {
    name = yaml['name'];
    debugMode = yaml['debugMode'] ?? this.debugMode;
    //size = vector2FromData(yaml['size']) ?? this.size;
    //position = vector2FromData(yaml['position']) ?? this.position;
    //addChildren(await Factory().createFromDataArray(yaml['children']));

    // TODO: positionComponent should point to an existing component, need to do some sort of name lookup and resolution....
    //positionComponent = (await Factory().createFromData(yaml['positionComponent'])) ?? this.positionComponent;
    
    print('yay');
  }

  @override
  void resolve(Entity entity) {
    body = createBody();
  }
/*
  @override
  Future<void>? onLoad() => null;
/*
  @override
  Future<void> onLoad() async {
    //await super.onLoad();
    //updatePositionComponent();
    //positionComponent..anchor = Anchor.center;
    //gameRef.add(positionComponent);
    return null;
  }
*/
*/
  @override
  Body createBody() {
    double radius = 10;
    Vector2 _position = Vector2(0, 0);

    final shape = CircleShape();
    shape.radius = radius;

    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.4;

    final bodyDef = BodyDef()
      // To be able to determine object in collision
      ..userData = this
      ..angularDamping = 0.8
      ..position = _position
      ..type = BodyType.dynamic;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

Future<PhysicsBody> physicsBodyComponentFromData(dynamic yaml) async {
  final comp = new PhysicsBody();
  await comp.fromData(yaml);
  return comp;
}