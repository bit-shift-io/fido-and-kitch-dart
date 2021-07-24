import 'dart:ui';
import 'package:flame_forge2d/flame_forge2d.dart' hide Position;
export 'package:flame_forge2d/flame_forge2d.dart' hide Position;
export 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flame/components.dart' as c;
import '../game.dart';
import '../utils/yaml.dart';
import 'entity.dart';
import 'mixins.dart';
import 'extensions.dart';

BodyDef bodyDefFromData(dynamic data) {
  BodyDef def = BodyDef();
  //def.userData = this;
  def.linearDamping = toDouble(data['linearDamping']) ?? def.linearDamping;
  def.fixedRotation = data['fixedRotation'] ?? def.fixedRotation;
  def.angularDamping = toDouble(data['angularDamping']) ?? def.angularDamping;

  final type = data['type'];
  switch (type) {
  case 'dynamic':
    def.type = BodyType.dynamic;
    break;

  case 'kinematic':
    def.type = BodyType.kinematic;
    break;

  case 'static':
    def.type = BodyType.static;
    break;
  } 

  return def;
}


Shape shapeFromData(dynamic data) {
  final type = data['type'];

  if (type == 'circle') {
    CircleShape c = CircleShape();
    c.radius = toDouble(data['radius']) ?? 10.0;
    return c;
  } else if (type == 'polygon') {
    PolygonShape shape = PolygonShape();
    return shape;
  } else if (type == 'box') {
    PolygonShape b = PolygonShape();
    final size = vector2FromData(data['size']);
    if (size != null) {
      b.setAsBoxXY(size.x, size.y);
    }
    return b;
  }

  // return something at least!
  print('PhysicsBody: Unknown shape: $type');
  CircleShape c = CircleShape();
  c.radius = 10.0;
  return c;
}

FixtureDef fixtureDefFromData(dynamic data) {
  Shape shape = shapeFromData(data['shape']);
  FixtureDef def = FixtureDef(shape);
  def.restitution = toDouble(data['restitution']) ?? def.restitution;
  def.density = toDouble(data['density']) ?? def.density;
  def.friction = toDouble(data['friction']) ?? def.friction;
  def.isSensor = toBool(data['isSensor']) ?? def.isSensor;
  return def;
}

AABB bodyAABB(Body body) {
  AABB aabb = AABB();
  bool first = true;
  for (final fixture in body.fixtures) {
    AABB shape_aabb = AABB();
    fixture.shape.computeAABB(shape_aabb, Transform.zero(), 0);
    if (first) {
      aabb = shape_aabb;
      first = false;
    } else {
      aabb.combine(shape_aabb);
    }
  }
  return aabb;
}

class PhysicsBody extends c.BaseComponent with HasName, WithResolve, HasEntity, c.HasGameRef<Game> {
  c.PositionComponent? positionComponent;

  BodyDef bodyDef = BodyDef();
  List<FixtureDef> fixureDefs = [];
  Body? body;
  AABB aabb = AABB();

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
    bodyDef = bodyDefFromData(yaml['bodyDef']);
    bodyDef.userData = this;
    for (final fd in yaml['fixtureDefs']) {
      fixureDefs.add(fixtureDefFromData(fd));
    }
  }

  @override
  void resolve(Entity entity) {
    this.resolveChildren(entity);

    body = createBody();
    aabb = bodyAABB(body!);
    debugMode = true; // adding child resets this value?!
  }

  Body createBody() {
    Body b = world.createBody(bodyDef);
    for (final f in fixureDefs) {
      b.createFixture(f);
    }
    return b;
  }

  @override
  void onRemove() {
    super.onRemove();
    if (body != null) {
      world.destroyBody(body!);
    }
  }

  World get world => gameRef.world;

  set linearVelocity(Vector2 v) => body?.linearVelocity = v;
  Vector2 get linearVelocity => body?.linearVelocity ?? Vector2.zero();

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