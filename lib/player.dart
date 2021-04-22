import 'dart:ui';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:fido_and_kitch/utils.dart';
import 'package:fido_and_kitch/player_animations.dart';

// https://github.com/flame-engine/trex-flame/blob/master/lib/game/t_rex/t_rex.dart
class Player extends PositionComponent with Resizable {

  Map<String, AnimationComponent> animations = Map();
  AnimationComponent currentAnimation;

  Player() : super() {
    onLoad();
  }

  addAnimation(String name, AnimationComponent animationComponent) {
    animations[name] = animationComponent;
  }

  Future<void> onLoad() async {
    var yaml = await loadYamlFromFile('cat.yaml');
    String dir = yaml['directory'];
    var anims = yaml['animations'];
    for (var a in anims) {
      addAnimation(a['name'], animationComponentFromSprites(await spritesFromFilenames(anim(dir, a['name'], a['frames'])), stepTime: a['stepTime'], loop: a['loop']));
    }

    setAnimation('Idle');
  }

  void setAnimation(animationName) {
    currentAnimation = animations[animationName];
  }

  @override
  void render(Canvas c) {
    if (currentAnimation != null) {
      currentAnimation.render(c);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (currentAnimation != null) {
      currentAnimation.x = x;
      currentAnimation.y = y;
      currentAnimation.update(dt);
    }
  }
}
