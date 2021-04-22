import 'dart:ui';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:fido_and_kitch/utils.dart';
import 'package:fido_and_kitch/player_animations.dart';

// https://github.com/flame-engine/trex-flame/blob/master/lib/game/t_rex/t_rex.dart
class Player extends PositionComponent with Resizable {

  AnimationComponent comp;

  Player() : super() {
    print("player constructed");
    onLoad();
  }

  Future<void> onLoad() async {
    print("onLoad in player");
    comp = animationComponentFromSprites(await spritesFromFilenames(walk('cat')), stepTime: 0.2, loop: true);
  }

  @override
  void render(Canvas c) {
    if (comp != null) {
      comp.render(c);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (comp != null) {
      comp.update(dt);
    }
  }
}
