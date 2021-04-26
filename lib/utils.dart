
import 'package:flame/components/animation_component.dart';
import 'package:flame/animation.dart';
import 'package:flame/sprite.dart';
import 'package:flame/flame.dart';
import 'dart:ui';
import "package:flutter/services.dart" as s;
import "package:yaml/yaml.dart";


class IntPoint2 {
  IntPoint2(this.x, this.y);

  IntPoint2 add(int px, int py) => IntPoint2(x + px, y + py);
  
  int x;
  int y;
}

class DoublePoint2 {
  DoublePoint2(this.x, this.y);
  
  double x;
  double y;
}

List<int> range(start, end) {
  return new List<int>.generate(end - start, (i) => start + i + 1);
}

Future<List<Sprite>> spritesFromFilenames(List<String> fileNames) async {
  List<Image> images = await Flame.images.loadAll(fileNames);
  List<Sprite> sprites = List<Sprite>.generate(images.length, (index) => Sprite.fromImage(images[index], width: images[index].width as double, height: images[index].height as double));
  return sprites;
}

AnimationComponent animationComponentFromSprites(List<Sprite> sprites, {double stepTime, bool loop = true}) {
  double width = sprites[0].image.width as double;
  double height = sprites[0].image.height as double;
  AnimationComponent comp = AnimationComponent(width, height, 
    Animation.spriteList(sprites, 
      stepTime: stepTime,
      loop: loop
    )
  );

  return comp;
}

dynamic loadYamlFromFile(String fileName) async {
  final data = await s.rootBundle.loadString(fileName);
  final mapData = loadYaml(data);
  return mapData;
}
