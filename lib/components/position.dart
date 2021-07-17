import 'package:flame/components.dart';

import '../utils/yaml.dart';
import 'package:flame/components.dart' as c;
import 'package:flame/game.dart';

import '../factory.dart';
import 'entity.dart';
import 'mixins.dart';
import 'extensions.dart';

class Position extends c.PositionComponent with HasName, WithResolve {
  Vector2 offset = Vector2(0, 0);

  bool dm = false;

  Future<void> fromData(dynamic yaml) async {
    name = yaml['name'];
    addChildren(await Factory().createFromDataArray(yaml['children']));
    dm = yaml['debugMode'] ?? this.debugMode;
    size = vector2FromData(yaml['size']) ?? this.size;
    position = vector2FromData(yaml['position']) ?? this.position;

    final anchorStr = yaml['anchor'];
    switch (anchorStr) {
    case 'topLeft': anchor = c.Anchor.topLeft; break;
    case 'topRight': anchor = c.Anchor.topRight; break;
    case 'centerLeft': anchor = c.Anchor.centerLeft; break;
    case 'center': anchor = c.Anchor.center; break;
    case 'centerRight': anchor = c.Anchor.centerRight; break;
    case 'bottomLeft': anchor = c.Anchor.bottomLeft; break;
    case 'bottomCenter': anchor = c.Anchor.bottomCenter; break;
    case 'bottomRight': anchor = c.Anchor.bottomRight; break;
    default: break;
    }
  }

  void resolve(Entity entity) {
    debugMode = dm;
  }

  /// get position given a certain anchor point
  Vector2 getPosition(Anchor a) {
    return anchor.toOtherAnchorPosition(
      position,
      a,
      size,
    );
  }
}

Future<Position> positionComponentFromData(dynamic yaml) async {
  final comp = new Position();
  await comp.fromData(yaml);
  return comp;
}