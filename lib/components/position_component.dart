import 'package:flame/components.dart' as c;
import 'package:flame/game.dart';

import '../factory.dart';
import 'mixins.dart';
import 'extensions.dart';

class PositionComponent extends c.PositionComponent with HasName {
  Vector2 offset;

  Future<void> fromYaml(dynamic yaml) async {
    name = yaml['name'];
    addChildren(await Factory().createFromYamlArray(yaml['children']));
  }
}

Future<PositionComponent> positionComponentFromYaml(dynamic yaml) async {
  final comp = new PositionComponent();
  await comp.fromYaml(yaml);
  return comp;
}