import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' hide Animation;
import 'package:tiled/tiled.dart' show ObjectGroup, TmxObject;
import 'package:flame_tiled/flame_tiled.dart';

import 'base_component.dart';

class TiledMap extends Component with ChildComponents {
  TiledComponent tiledMap;

  TiledMap() {
    tiledMap = TiledComponent('map.tmx', Size(16.0, 16.0));
    addChild(tiledMap);
    _addCoinsInMap(tiledMap);
  }

  void _addCoinsInMap(TiledComponent tiledMap) async {
    final ObjectGroup objGroup =
        await tiledMap.getObjectGroupFromLayer("AnimatedCoins");
    if (objGroup == null) {
      return;
    }
    objGroup.tmxObjects.forEach((TmxObject obj) {
      final comp = AnimationComponent(
        20.0,
        20.0,
        Animation.sequenced(
          'coins.png',
          8,
          textureWidth: 20,
          textureHeight: 20,
        ),
      );
      comp.x = obj.x.toDouble();
      comp.y = obj.y.toDouble();
      addChild(comp);
    });
  }

  @override
  void render(Canvas c) {
    if (tiledMap != null) {
      tiledMap.render(c);
    }
  }

  @override
  void update(double dt) {
    tiledMap.update(dt);
  }
}
