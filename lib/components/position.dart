import '../utils/yaml.dart';
import 'package:flame/components.dart' as c;
import 'package:flame/game.dart';

import '../factory.dart';
import 'mixins.dart';
import 'extensions.dart';

class Position extends c.PositionComponent with HasName {
  Vector2 offset = Vector2(0, 0);

  Future<void> fromData(dynamic yaml) async {
    name = yaml['name'];
    debugMode = yaml['debugMode'] ?? this.debugMode;
    size = vector2FromData(yaml['size']) ?? this.size;
    position = vector2FromData(yaml['position']) ?? this.position;
    addChildren(await Factory().createFromDataArray(yaml['children']));
  }
}

Future<Position> positionComponentFromData(dynamic yaml) async {
  final comp = new Position();
  await comp.fromData(yaml);
  return comp;
}