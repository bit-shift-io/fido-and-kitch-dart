import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'mixins.dart';
import '../utils/yaml.dart';
import 'package:flame/components.dart' as c;

class SpriteAnimationComponent extends c.SpriteAnimationComponent with HasName {
  Future<void> fromData(dynamic yaml) async {
    name = yaml['name'];
    String image = yaml['image'];
    dynamic images = yaml['images'];
    double stepTime = yaml['stepTime'];
    bool loop = yaml['loop'];
    bool reversed = yaml['reversed'] ?? false;
    int frames = yaml['frames'];
    Vector2 textureSize = vector2FromData(yaml['textureSize']);
    Vector2 size = vector2FromData(yaml['size']);

    // if no size given, infer from textureSize
    if (size == null) {
      size = textureSize;
    }

    c.SpriteAnimation animation;

    // spritesheet
    if (image != null) {
      animation = await c.SpriteAnimation.load(
        image, 
        c.SpriteAnimationData.sequenced(amount: frames,
          stepTime: stepTime,
          textureSize: textureSize,
          loop: loop
        )
      );
    }

    // many single frames
    if (images != null) {
      // for images field we can put some sort of string expression
      if (images is String) {
        String imagesExpression = images;
        images = List<String>.generate(frames, (index) => imagesExpression.replaceAll('\${i+1}', '${index+1}'));
      }

      List<Image> spriteImages = await Flame.images.loadAll(images);
      List<c.Sprite> sprites = spriteImages.map<c.Sprite>((Image img) {
        return c.Sprite(img);
      }).toList();

      // if no size given, infer from first sprite
      if (size == null) {
        double width = sprites[0].image.width.toDouble();
        double height = sprites[0].image.height.toDouble();
        size = Vector2(width, height);
      }

      animation = c.SpriteAnimation.spriteList(sprites, 
        stepTime: stepTime,
        loop: loop
      );
    }

    if (reversed) {
      animation = animation.reversed();
    }

    this.animation = animation;
    this.size = size;
    //return new SpriteAnimationComponent(size: size, animation: animation);
  }
}

Future<SpriteAnimationComponent> spriteAnimationComponentFromData(dynamic yaml) async {
  SpriteAnimationComponent comp = new SpriteAnimationComponent();
  await comp.fromData(yaml);
  return comp;
}
