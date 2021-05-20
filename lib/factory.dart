
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'position_component.dart';
import 'switch_component.dart';
import 'utils.dart';

typedef Future<T> CreateComponentFromYaml<T>(dynamic yaml);

Vector2 vector2FromYaml(dynamic yaml) {
  if (yaml == null) {
    return null;
  }
  double x = yaml[0].toDouble();
  double y = yaml[1].toDouble();
  return Vector2(x, y);
}

Future<SpriteAnimationComponent> spriteAnimationComponentFromYaml(dynamic yaml) async {
  String image = yaml['image'];
  String images = yaml['images'];
  double stepTime = yaml['stepTime'];
  bool loop = yaml['loop'];
  bool reversed = yaml['reversed'] ?? false;
  int frames = yaml['frames'];
  Vector2 textureSize = vector2FromYaml(yaml['textureSize']);
  Vector2 size = vector2FromYaml(yaml['size']);

  // if no size given, infer from textureSize
  if (size == null) {
    size = textureSize;
  }

  SpriteAnimation animation;

  // spritesheet
  if (image != null) {
    animation = await SpriteAnimation.load(
      image, 
      SpriteAnimationData.sequenced(amount: frames,
        stepTime: stepTime,
        textureSize: textureSize,
        loop: loop
      )
    );
  }

  // many single frames
  if (images != null) {
    List<Sprite> sprites;

    // if no size given, infer from first sprite
    if (size == null) {
      double width = sprites[0].image.width.toDouble();
      double height = sprites[0].image.height.toDouble();
      size = Vector2(width, height);
    }

    animation = SpriteAnimation.spriteList(sprites, 
      stepTime: stepTime,
      loop: loop
    );
  }

  if (reversed) {
    animation = animation.reversed();
  }

  return new SpriteAnimationComponent(size: size, animation: animation);
}


Future<SpriteComponent> spriteComponentFromYaml(dynamic yaml) async {
  Vector2 size = vector2FromYaml(yaml['size']);
  String imageFilename = yaml['image'];
  final image = await Flame.images.load(imageFilename);
  return new SpriteComponent.fromImage(image, size: size);
}

Future<SwitchComponent> switchComponentFromYaml(dynamic yaml) async {
  final comp = new SwitchComponent();
  // TODO: add components

  final children = yaml['components'];
  for (final c in children) {
    Component child = await Factory().createFromYaml<Component>(c);
    comp.addComponent(c['name'], child);
  }

  final activeComponent = yaml['activeComponent'];
  comp.setActiveComponent(activeComponent);

  // TODO: support random initial component

  return comp;
}

Future<PosComponent> positionComponentFromYaml(dynamic yaml) async {
  final comp = new PosComponent();
  comp.addChildren(await Factory().createFromYamlArray(yaml['children']));
  return comp;
}

class Factory {

  static final Factory _singleton = Factory._internal();

  factory Factory() {
    return _singleton;
  }

  Factory._internal();

  Map<String, CreateComponentFromYaml> fromYamlMap = {
    'SpriteAnimationComponent': spriteAnimationComponentFromYaml,
    'SpriteComponent': spriteComponentFromYaml,
    'SwitchComponent': switchComponentFromYaml,
    'PositionComponent': positionComponentFromYaml
  };

  Future<T> createFromYamlFile<T>(String fileName) async {
    final yaml = await loadYamlFromFile(fileName);
    return createFromYaml<T>(yaml);
  }

  Future<T> createFromYaml<T>(dynamic yaml) async {
    String componentName = yaml['component'];
    final creator = fromYamlMap[componentName];
    if (creator == null) {
      return null;
    }
    return await creator(yaml);
  }

  Future<List<Component>> createFromYamlArray(dynamic yaml) async {
    List<Component> array = [];
    if (yaml == null) {
      return array;
    }

    for (final c in yaml) {
      Component child = await createFromYaml<Component>(c);
      array.add(child);
    }
    return array;
  }

}
