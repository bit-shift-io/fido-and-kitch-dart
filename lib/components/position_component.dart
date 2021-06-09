import 'package:fido_and_kitch/utils/yaml.dart';
import 'package:flame/components.dart' as c;
import 'package:flame/game.dart';

import '../factory.dart';
import 'mixins.dart';
import 'extensions.dart';

class PositionComponent extends c.PositionComponent with HasName {
  Vector2 offset;

  Future<void> fromData(dynamic yaml) async {
    name = yaml['name'];
    size = vector2FromData(yaml['size']) ?? this.size;
    position = vector2FromData(yaml['position']) ?? this.position;
    addChildren(await Factory().createFromDataArray(yaml['children']));
  }
}

Future<PositionComponent> positionComponentFromData(dynamic yaml) async {
  final comp = new PositionComponent();
  await comp.fromData(yaml);
  return comp;
}