import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'mixins.dart';
import '../utils/yaml.dart';
import 'package:flame/components.dart' as c;

class SpriteComponent extends c.SpriteComponent with HasName {
  Future<void> fromYaml(dynamic yaml) async {
    name = yaml['name'];
    Vector2 size = vector2FromYaml(yaml['size']);
    String imageFilename = yaml['image'];
    final image = await Flame.images.load(imageFilename);

    sprite = c.Sprite(
          image
        );

    this.size = size;
  }
}

Future<SpriteComponent> spriteComponentFromYaml(dynamic yaml) async {
  SpriteComponent comp = new SpriteComponent();
  await comp.fromYaml(yaml);
  return comp;
}
