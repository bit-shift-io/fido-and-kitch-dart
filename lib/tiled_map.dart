import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/widgets.dart' hide Animation, Image;
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:tiled/tiled.dart' as t;
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;

import 'utils.dart';

/// Tiled represents all flips and rotation using three possible flips: horizontal, vertical and diagonal.
/// This class converts that representation to a simpler one, that uses one angle (with pi/2 steps) and two flips (H or V).
/// More reference: https://doc.mapeditor.org/en/stable/reference/tmx-map-format/#tile-flipping
class _SimpleFlips {
  /// The angle (in steps of pi/2 rads), clockwise, around the center of the tile.
  final int angle;

  /// Whether to flip across a central vertical axis (passing through the center).
  final bool flipH;

  /// Whether to flip across a central horizontal axis (passing through the center).
  final bool flipV;

  _SimpleFlips(this.angle, this.flipH, this.flipV);

  /// This is the conversion from the truth table that I drew.
  factory _SimpleFlips.fromFlips(t.Flips flips) {
    int angle;
    bool flipV, flipH;

    if (!flips.diagonally && !flips.vertically && !flips.horizontally) {
      angle = 0;
      flipV = false;
      flipH = false;
    } else if (!flips.diagonally && !flips.vertically && flips.horizontally) {
      angle = 0;
      flipV = false;
      flipH = true;
    } else if (!flips.diagonally && flips.vertically && !flips.horizontally) {
      angle = 0;
      flipV = true;
      flipH = false;
    } else if (!flips.diagonally && flips.vertically && flips.horizontally) {
      angle = 2;
      flipV = false;
      flipH = false;
    } else if (flips.diagonally && !flips.vertically && !flips.horizontally) {
      angle = 1;
      flipV = false;
      flipH = true;
    } else if (flips.diagonally && !flips.vertically && flips.horizontally) {
      angle = 1;
      flipV = false;
      flipH = false;
    } else if (flips.diagonally && flips.vertically && !flips.horizontally) {
      angle = 3;
      flipV = false;
      flipH = false;
    } else if (flips.diagonally && flips.vertically && flips.horizontally) {
      angle = 1;
      flipV = true;
      flipH = false;
    } else {
      // this should be exhaustive
      throw 'Invalid combination of booleans: $flips';
    }

    return _SimpleFlips(angle, flipH, flipV);
  }
}

class TsxProv extends t.TsxProvider {
  final Map<String, String> tilesetMap;
  
  TsxProv(this.tilesetMap);

  String getSource(String key) {
    final str = tilesetMap[key];
    return str;
  }
}

/// This component renders a tile map based on a TMX file from Tiled.
class Tiled {
  String filename;
  t.TileMap map;
  Image image;
  Map<String, SpriteBatch> batches = <String, SpriteBatch>{};
  Future future;
  bool _loaded = false;
  Size destTileSize;

  String mapBasePath = 'assets/tiles/';

  static Paint paint = Paint()..color = Colors.white;

  /// Creates this Tiled with the filename (for the tmx file resource)
  /// and destTileSize is the tile size to be rendered (not the tile size in the texture, that one is configured inside Tiled).
  Tiled(this.filename, this.destTileSize) {
    future = _load();
  }

  Future _load() async {
    map = await _loadMap();

    final imagePath = getTilesetImagePath(map.tilesets[0], map.tilesets[0].image);
    image = await Flame.images.load(imagePath);
    batches = await _loadImages(map);
    generate();
    _loaded = true;
  }

  String getTilesetImagePath(t.Tileset tileset, t.Image tmxImage) {
    // the image filepath if relstive to the tileset path
    // the tileset path is relative to the map
    final tilesetDir = p.dirname(tileset.source);
    final imagePath = p.normalize('$mapBasePath$tilesetDir/${tmxImage.source}');
    final imagePathInImages = imagePath.replaceAll('assets/images/', '');
    return imagePathInImages;
  }

  Future<t.TileMap> _loadMap() {
    return Flame.bundle.loadString('$mapBasePath$filename').then((contents) async {

      // here we need to parse the XML and extract external tileset filenames
      // then we need to load them as TsxProvider.getSource is no async
      // so we need to load them before we know what they are!

      final tilesetFilenames = <String>[];
      final xmlElement = XmlDocument.parse(contents).rootElement;
      xmlElement.children.whereType<XmlElement>().forEach((XmlElement element) {
        if (element.name.local == 'tileset') {
          final tsxFilename = element.getAttribute('source');
          tilesetFilenames.add(tsxFilename);
        }
      });

      final tilesetMap = Map<String, String>();
      await Future.forEach(tilesetFilenames, (String tsxFilename) async {
        String contents = await Flame.bundle.loadString('$mapBasePath$tsxFilename');
        tilesetMap[tsxFilename] = contents;
      });

      final parser = t.TileMapParser();
      return parser.parse(contents, tsx: TsxProv(tilesetMap));
    });
  }

  Future<Map<String, SpriteBatch>> _loadImages(t.TileMap map) async {
    final Map<String, SpriteBatch> result = {};
    await Future.forEach(map.tilesets, (tileset) async {
      await Future.forEach(tileset.images, (tmxImage) async {
        final imagePath = getTilesetImagePath(tileset, tmxImage);
        result[tmxImage.source] = await SpriteBatch.load(imagePath);
      });
    });
    return result;
  }

  /// Generate the sprite batches from the existing tilemap.
  void generate() {
    for (var batch in batches.keys) {
      batches[batch].clear();
    }
    _drawTiles(map);
  }

  void _drawTiles(t.TileMap map) {
    map.layers.where((layer) => layer.visible).forEach((layer) {
      layer.tiles.forEach((tileRow) {
        tileRow.forEach((tile) {
          if (tile.gid == 0) {
            return;
          }

          final batch = batches[tile.image.source];

          final rect = tile.computeDrawRect();

          final src = Rect.fromLTWH(
            rect.left.toDouble(),
            rect.top.toDouble(),
            rect.width.toDouble(),
            rect.height.toDouble(),
          );

          final flips = _SimpleFlips.fromFlips(tile.flips);
          final Size tileSize = destTileSize ??
              Size(tile.width.toDouble(), tile.height.toDouble());

          batch.add(
            source: src,
            offset: Vector2(
              tile.x.toDouble() * tileSize.width +
                  (tile.flips.horizontally ? tileSize.width : 0),
              tile.y.toDouble() * tileSize.height +
                  (tile.flips.vertically ? tileSize.height : 0),
            ),
            rotation: flips.angle * math.pi / 2,
            scale: tileSize.width / tile.width,
          );
        });
      });
    });
  }

  bool loaded() => _loaded;

  void render(Canvas c) {
    if (!loaded()) {
      return;
    }

    batches.forEach((_, batch) {
      batch.render(c);
    });
  }

  /// This returns an object group fetch by name from a given layer.
  /// Use this to add custom behaviour to special objects and groups.
  Future<t.ObjectGroup> getObjectGroupFromLayer(String name) {
    return future.then((onValue) {
      return map.objectGroups
          .firstWhere((objectGroup) => objectGroup.name == name);
    });
  }
}


class TiledMap extends BaseComponent {
  Tiled tiled;
  double scale;

  Future load(String fileName) async {
    tiled = Tiled(fileName, Size(32.0, 32.0)); // tiles in the loaded map are 16 bbut we are displaying as 32x32
    scale = 1.0;

    await tiled.future;

    _addCoinsInMap();
  }

  /// This returns an object group fetch by name from a given layer.
  /// Use this to add custom behaviour to special objects and groups.
  t.ObjectGroup getObjectGroupFromLayer(String name) {
      if (tiled == null || !tiled.loaded()) {
        print('Map still loading!');
        return null;
      }

      return tiled.map.objectGroups
          .firstWhere((objectGroup) => objectGroup.name == name);
  }

  void _addCoinsInMap() {
    final t.ObjectGroup objGroup = getObjectGroupFromLayer("AnimatedCoins");
    if (objGroup == null) {
      return;
    }
    
    objGroup.tmxObjects.forEach((t.TmxObject obj) async {
      final comp = SpriteAnimationComponent(
        size: Vector2(20.0, 20.0),
        animation: await SpriteAnimation.load(
          'coins.png',
          SpriteAnimationData.sequenced(amount: 8,
            stepTime: 0.2,
            textureSize: Vector2(20, 20)
          )
        ),
      );
      comp.x = obj.x.toDouble();
      comp.y = obj.y.toDouble();
      addChild(comp);
    });
  }

  List<t.Tile> rectIntersectingTiles(Rect r) {
    if (tiled == null || !tiled.loaded()) {
      print('Map still loading!');
      return [];
    }

    List<t.Tile> intersectingTiles = [];

    tiled.map.layers.where((layer) => layer.visible).forEach((layer) {
      layer.tiles.forEach((tileRow) {
        tileRow.forEach((tile) {
          if (tile.gid == 0) {
            return;
          }

          //final batch = tiled.batches[tile.image.source];

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
    super.render(c);
    tiled.render(c);
  }

  Int2 worldToTileSpace(Vector2 position) {
    if (tiled == null || !tiled.loaded()) {
      return null;
    }
    
    double gridX = (position.x - tiled.map.tileWidth) / (tiled.map.tileWidth * scale);
    double gridY = (position.y - (tiled.map.tileHeight * scale)) / (tiled.map.tileHeight * scale);

    int x = gridX.round();
    int y = gridY.round();

    return Int2(x, y);
  }

  Rect rectFromTilePostion(Int2 position) {
    if (tiled == null || !tiled.loaded()) {
      return null;
    }

    return Rect.fromLTWH(position.x * tiled.map.tileWidth * scale, position.y * tiled.map.tileHeight * scale, tiled.map.tileWidth * scale, tiled.map.tileHeight * scale);
  }

  t.Tile getTile({String layerName, Int2 position}) {
    if (tiled == null || !tiled.loaded() || position == null) {
      return null;
    }

    if (position.y < 0 || position.x < 0) {
      return null;
    }

    for (var layer in tiled.map.layers.where((layer) => layer.name == layerName)) {
      if (position.y >= layer.tiles.length) {
        return null;
      }
      List<t.Tile> row = layer.tiles[position.y];
      if (position.x >= row.length) {
        return null;
      }
      t.Tile tile = row[position.x];
      return tile;
    }

    return null;
  }

  Rect tileRect(t.Tile tile) {
    return rectFromTilePostion(Int2(tile.x, tile.y));
  }

  Int2 mapTileSize() {
    final width = tiled.map.width;
    final height = tiled.map.height;
    return Int2(width, height);
  }

  Vector2 mapPixelSize() {
    final width = tiled.map.width * tiled.map.tileWidth * scale;
    final height = tiled.map.height * tiled.map.tileHeight * scale;
    return Vector2(width, height);
  }
}
