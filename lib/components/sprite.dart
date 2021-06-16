import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'mixins.dart';
import '../utils/yaml.dart';
import 'package:flame/components.dart' as c;

class Sprite extends c.SpriteComponent with HasName {
  Future<void> fromData(dynamic yaml) async {
    name = yaml['name'];
    Vector2? size = vector2FromData(yaml['size']);
    String imageFilename = yaml['image'];
    final image = await Flame.images.load(imageFilename);

    Vector2? srcPosition = vector2FromData(yaml['srcPosition']);
    Vector2? srcSize = vector2FromData(yaml['srcSize']);

    sprite = c.Sprite(
      image,
      srcPosition: srcPosition,
      srcSize: srcSize
    );

    this.size = size ?? this.size;
  }
}

Future<Sprite> spriteComponentFromData(dynamic yaml) async {
  Sprite comp = new Sprite();
  await comp.fromData(yaml);
  return comp;
}
