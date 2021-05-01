
import 'dart:math';
import 'package:flame/components/animation_component.dart';
import 'package:flame/animation.dart';
import 'package:flame/sprite.dart';
import 'package:flame/flame.dart';
import 'dart:ui';
import "package:flutter/services.dart" as s;
import "package:yaml/yaml.dart";
import 'package:tiled/tiled.dart' show Tile;

class Int2 {
  Int2(this.x, this.y);

  Int2 operator +(Int2 rhs) => Int2(x + rhs.x, y + rhs.y);
  
  int x;
  int y;
}

class Double2 {
  Double2(this.x, this.y);

  Double2 operator *(double rhs) => Double2(x * rhs, y * rhs);
  
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

List<String> anim(dir, aninName, numImages) {
  return List<String>.generate(numImages, (index) => '$dir/$aninName (${index + 1}).png');
}
