import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/flame.dart';
import 'dart:ui';
import "package:flutter/services.dart" as s;
import "package:yaml/yaml.dart";

class Int2 {
  Int2(this.x, this.y);
  Int2.fromVector2(Vector2 v) { x = v.x as int; y = v.y as int; }

  Int2 operator +(Int2 rhs) => Int2(x + rhs.x, y + rhs.y);
  
  Vector2 toVector2() => Vector2(x as double, y as double);

  int x = 0;
  int y = 0;
}

List<int> range(start, end) {
  return new List<int>.generate(end - start, (i) => start + i + 1);
}

Future<List<Sprite>> spritesFromFilenames(List<String> fileNames) async {
  List<Image> images = await Flame.images.loadAll(fileNames);
  final futureSprites = List<Future<Sprite>>.generate(images.length, (index) {
    Vector2 srcSize = Vector2(images[index].width as double, images[index].height as double);
    return Sprite.load(fileNames[index], srcPosition: Vector2(0,0), srcSize: srcSize);
  });
  List<Sprite> sprites = await Future.wait(futureSprites);
  return sprites;
}

SpriteAnimationComponent animationComponentFromSprites(List<Sprite> sprites, {double stepTime, bool loop = true, bool reversed = false}) {
  double width = sprites[0].image.width as double;
  double height = sprites[0].image.height as double;
  SpriteAnimationComponent comp = SpriteAnimationComponent(size: Vector2(width, height), 
    animation: SpriteAnimation.spriteList(sprites, 
      stepTime: stepTime,
      loop: loop
    )
  );

  if (reversed) {
    comp.animation = comp.animation.reversed();
  }
  return comp;
}

SpriteAnimationComponent animationComponentFromSpriteSheet(Image image, {int amount, double stepTime, bool loop = true, bool reversed = false}) {
  double width = image.width as double;
  double height = image.height as double;

  final animation = SpriteAnimation.fromFrameData(image, 
    SpriteAnimationData.sequenced(amount: amount,
            stepTime: stepTime,
            textureSize: Vector2(width, height),
            loop: loop
          )
  );

  final comp = SpriteAnimationComponent(
          size: Vector2(width, height),
          animation: animation
      );

  if (reversed) {
    comp.animation = comp.animation.reversed();
  }
  return comp;
}

dynamic loadYamlFromFile(String fileName) async {
  final data = await s.rootBundle.loadString(fileName);
  final mapData = loadYaml(data);
  return mapData;
}

List<String> anim(dir, aninName, numImages) {
  return List<String>.generate(numImages, (index) => '$dir/$aninName (${index + 1}).png');
}
