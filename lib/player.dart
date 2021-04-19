import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/sprite.dart';

// https://github.com/flame-engine/trex-flame/blob/master/lib/game/t_rex/t_rex.dart
class Player extends PositionComponent with Resizable {

  AnimationComponent comp;

  load() {
    // https://github.com/flame-engine/trex-flame/blob/master/lib/game/t_rex/t_rex.dart
    double width = 542;
    double height = 474;
    comp = AnimationComponent(width, height, 
      Animation.spriteList([
          Sprite(
            'Walk (1).png',
            width: width,
            height: height
          )
        ], 
        stepTime: 0.2,
        loop: true
      )
    );

  }

  @override
  void render(Canvas c) {
    comp.render(c);
  }
}
