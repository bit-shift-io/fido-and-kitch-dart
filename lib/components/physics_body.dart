import 'dart:ui';

import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Position;
import 'package:flame/components.dart' as c;
import '../game.dart';
import './position.dart';
import '../factory.dart';
import '../utils/yaml.dart';
import 'entity.dart';
import 'mixins.dart';


// flame_forge2d sucks! loos it and just use forge2d?
class PhysicsBody extends c.BaseComponent with HasName, WithResolve, HasEntity, c.HasGameRef<Game> {
  c.PositionComponent? positionComponent;
  Body? body;

  static const defaultColor = Color.fromARGB(128, 255, 0, 0);
  Paint paint = Paint()..color = defaultColor;

  @override
  void update(double dt) {
    super.update(dt);
    updatePositionComponent();
  }

  void updatePositionComponent() {
    if (positionComponent != null && body != null) {
      positionComponent!.position..setFrom(body!.position);
      positionComponent!.position.y *= -1;
      positionComponent!
        ..angle = -body!.angle;
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
    debugMode = true; // adding child resets this value?!
  }

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

  @override
  void onRemove() {
    super.onRemove();
    if (body != null) {
      world.destroyBody(body!);
    }
  }

  World get world => gameRef.world;

/// The matrix used for preparing the canvas
//  final c.Matrix4 _transform = c.Matrix4.identity();
//  double? _lastAngle;

  @override
  void prepareCanvas(Canvas canvas) {
    /*
    /*
    if (_transform.m14 != body!.position.x ||
        _transform.m24 != body!.position.y ||
        _lastAngle != body!.angle)
      */ {
      _transform.setIdentity();
      _transform.scale(1.0, -1.0);
      _transform.translate(body!.position.x, body!.position.y);
      _transform.rotateZ(body!.angle);
      _lastAngle = body!.angle;
    }
    canvas.transform(_transform.storage);
    */

    canvas.translate(body!.position.x, body!.position.y);
    canvas.rotate(body!.angle);
  }

  @override
  void renderDebugMode(Canvas canvas) {
    for (final fixture in body!.fixtures) {
      switch (fixture.type) {
        case ShapeType.chain:
          _renderChain(canvas, fixture);
          break;
        case ShapeType.circle:
          _renderCircle(canvas, fixture);
          break;
        case ShapeType.edge:
          _renderEdge(canvas, fixture);
          break;
        case ShapeType.polygon:
          _renderPolygon(canvas, fixture);
          break;
      }
    }
  }

  void _renderChain(Canvas canvas, Fixture fixture) {
    final chainShape = fixture.shape as ChainShape;
    renderChain(
      canvas,
      chainShape.vertices.map((v) => v.toOffset()).toList(growable: false),
    );
  }

  void renderChain(Canvas canvas, List<Offset> points) {
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, paint);
  }

  void _renderCircle(Canvas canvas, Fixture fixture) {
    final circle = fixture.shape as CircleShape;
    renderCircle(canvas, circle.position.toOffset(), circle.radius);
  }

  void renderCircle(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, paint);
  }

  void _renderPolygon(Canvas canvas, Fixture fixture) {
    final polygon = fixture.shape as PolygonShape;
    renderPolygon(
      canvas,
      polygon.vertices.map((v) => v.toOffset()).toList(growable: false),
    );
  }

  void renderPolygon(Canvas canvas, List<Offset> points) {
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, paint);
  }

  void _renderEdge(Canvas canvas, Fixture fixture) {
    final edge = fixture.shape as EdgeShape;
    renderEdge(canvas, edge.vertex1.toOffset(), edge.vertex2.toOffset());
  }

  void renderEdge(Canvas canvas, Offset p1, Offset p2) {
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool containsPoint(Vector2 point) {
    return body!.fixtures.any((fixture) => fixture.testPoint(point));
  }
}

Future<PhysicsBody> physicsBodyComponentFromData(dynamic yaml) async {
  final comp = new PhysicsBody();
  await comp.fromData(yaml);
  return comp;
}