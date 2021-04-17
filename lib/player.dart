
import 'package:flame/components/animation_component.dart';
import 'package:galaxygame/dragon.dart';
import 'package:galaxygame/main.dart';

// https://pub.dev/documentation/flame/latest/components_animation_component/AnimationComponent-class.html
// https://github.com/GeekyAnts/flutter-galaxy-game/blob/master/lib/explosion.dart
// 
// 
const DRAGON_SIZE = 40.0;

class Player extends AnimationComponent {
  static const TIME = 0.75;

  Player()
      : super.sequenced(DRAGON_SIZE, DRAGON_SIZE, 'cat_walk.png', 7,
            textureWidth: 31.0, textureHeight: 31.0) {
    //this.x = dragon.x;
    //this.y = dragon.y;
    this.animation.stepTime = TIME / 7;
  }

  //bool destroy() {
  //  return this.animation.isLastFrame;
  //}
}
