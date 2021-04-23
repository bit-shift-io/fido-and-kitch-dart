import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' hide Animation;
import 'package:tiled/tiled.dart' show ObjectGroup, Tile, TileMap, TmxObject;
import 'package:flame_tiled/tiled.dart';

import 'base_component.dart';

class TiledMap extends Component with ChildComponents {
  Tiled tiled;

  Future load(String fileName) async {
    tiled = Tiled(fileName, Size(16.0, 16.0));
    await tiled.future;

    _addCoinsInMap();
  }

  /// This returns an object group fetch by name from a given layer.
  /// Use this to add custom behaviour to special objects and groups.
  ObjectGroup getObjectGroupFromLayer(String name) {
      if (tiled == null || !tiled.loaded()) {
        print('Map still loading!');
        return null;
      }

      return tiled.map.objectGroups
          .firstWhere((objectGroup) => objectGroup.name == name);
  }

  void _addCoinsInMap() {
    final ObjectGroup objGroup = getObjectGroupFromLayer("AnimatedCoins");
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

  List<Tile> rectIntersectingTiles(Rect r) {
    if (tiled == null || !tiled.loaded()) {
      print('Map still loading!');
      return [];
    }

    List<Tile> intersectingTiles = [];

    tiled.map.layers.where((layer) => layer.visible).forEach((layer) {
      layer.tiles.forEach((tileRow) {
        tileRow.forEach((tile) {
          if (tile.gid == 0) {
            return;
          }

          final batch = tiled.batches[tile.image.source];

          final rect = tile.computeDrawRect();

          final src = Rect.fromLTWH(
            rect.left.toDouble(),
            rect.top.toDouble(),
            rect.width.toDouble(),
            rect.height.toDouble(),
          );

          if (r.overlaps(src)) {
            intersectingTiles.add(tile);
          }
        });
      });
    });

    return intersectingTiles;
  }

  @override
  void render(Canvas c) {
    tiled.render(c);
    renderChildren(c);
  }

  @override
  void update(double dt) {
    updateChildren(dt);
  }
}
