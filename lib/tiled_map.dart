import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';
import 'package:flame_forge2d/flame_forge2d.dart' hide Position;
import 'components/entity.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/widgets.dart' hide Animation, Image;
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:tiled/tiled.dart' as t;
export 'package:tiled/tiled.dart' show TileLayer;
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;

import 'components/physics_body.dart';
import 'factory.dart';
import 'game.dart';
import 'utils/number.dart';
import 'components/extensions.dart';
import 'components/position.dart';

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

  t.Parser getSource(String key) {
    final str = tilesetMap[key];
    final node = XmlDocument.parse(str ?? '').rootElement;
    return t.XmlParser(node);

    //final str = tilesetMap[key];
    //return str;
  }
}

class Tile {
  t.Gid gid;
  t.TileLayer layer;
  Int2 coord; // tile coordinates

  Tile(this.gid, this.layer, this.coord);

  get isEmpty => (gid.tile == 0);
}

extension ExtraData on t.TileLayer {
  // can we memo this?
  Tile? tile(Int2 coord) {
    if (tileData == null || coord.y >= tileData!.length || coord.y < 0) {
      return null;
    }

    final row = tileData![coord.y];
    if (coord.x >= row.length || coord.x < 0) {
      return null;
    }

    final gid = row[coord.x];
    return Tile(gid, this, coord);
  }

  Body createStaticPhysicsBodyForTile(Size size, Vector2 offset, World world) {
      // Define the circle shape.
      final shape = PolygonShape();
      shape.setAsBoxXY(size.width * 0.5, size.height * 0.5);

      // Create a body def.
      final bodyDef = BodyDef();
      bodyDef.position = offset + Vector2(size.width * 0.5, size.height * 0.5);
      var body = world.createBody(bodyDef);
      body.userData = 'Tile';
      body.createFixtureFromShape(shape);
      return body;
  }

  void createStaticPhysicsBodies(TiledMap tiledMap) {
    final map = tiledMap.map!;
    int y = 0;
    this.tileData!.forEach((tileRow) {

      int x = 0;
      tileRow.forEach((gid) {
        t.Tile tile = map.tileByGid(gid.tile);
        if (tile.isEmpty) {
          ++x;
          return;
        }

        // test it out!
        //TTile? test = layer.tile(Int2(x, y));
        //final testCoords = test!.coord;
        //final testTileset = test.tileset(map);

/*
        int x2 = tile.localId % map.width ;
        int y2 = (tile.localId.toDouble() / map.width.toDouble()).toInt();
  */

        final tileset = map.tilesetByTileGId(gid.tile); //tile.localId);
        
        final rect = tileset.computeDrawRect(tile);
        final src = Rect.fromLTRB(rect.left.toDouble(), rect.top.toDouble(), rect.right.toDouble(), rect.bottom.toDouble());

        final flips = _SimpleFlips.fromFlips(gid.flips);
        final Size tileSize = Size(tileset.tileWidth!.toDouble(), tileset.tileHeight!.toDouble());

        final offset = Vector2(
            x.toDouble() * tileSize.width +
                (gid.flips.horizontally ? tileSize.width : 0),
            y.toDouble() * tileSize.height +
                (gid.flips.vertically ? tileSize.height : 0),
          );

        Body body = createStaticPhysicsBodyForTile(tileSize, offset, tiledMap.gameRef.world);
/*
        // to debug draw
        PhysicsBody physicsBody = new PhysicsBody();
        physicsBody.body = body;
        physicsBody.debugMode = true;
        tiledMap.gameRef.add(physicsBody);
*/
        ++x;
      });

      ++y;
    });

  }
}

class TiledMap extends BaseComponent with HasGameRef<Game> {
  double scale = 1.0;
  String? filename;
  t.TiledMap? map;
  Image? image;
  Map<String, SpriteBatch> batches = <String, SpriteBatch>{};
  Future? future;
  bool _loaded = false;
  Size? destTileSize;

  static Paint paint = Paint()..color = Colors.white;

  Future _load() async {
    map = await _loadMap();
    if (map == null) {
      return;
    }

    final imagePath = getTilesetImagePath(map!.tilesets[0], map!.tilesets[0].image);
    if (imagePath == null) {
      return;
    }

    image = await Flame.images.load(imagePath);
    batches = await _loadImages(map!);
    generate();
    _loaded = true;
  }

  String? getTilesetImagePath(t.Tileset tileset, t.TiledImage? tmxImage) {
    if (tmxImage == null || tileset.source == null) {
      return null;
    }

    // the image filepath if relstive to the tileset path
    // the tileset path is relative to the map
    final mapDir = p.dirname(filename!);
    final tilesetDir = p.dirname(tileset.source!);
    final imagePath = p.normalize('$mapDir/$tilesetDir/${tmxImage.source}');
    final imagePathInImages = imagePath.replaceAll('assets/images/', '');
    return imagePathInImages;
  }

  Future<t.TiledMap> _loadMap() {
    return Flame.bundle.loadString('$filename').then((contents) async {

      final mapDir = p.dirname(filename!);

      // here we need to parse the XML and extract external tileset filenames
      // then we need to load them as TsxProvider.getSource is no async
      // so we need to load them before we know what they are!

      final tilesetFilenames = <String>[];
      final xmlElement = XmlDocument.parse(contents).rootElement;
      xmlElement.children.whereType<XmlElement>().forEach((XmlElement element) {
        if (element.name.local == 'tileset') {
          final tsxFilename = element.getAttribute('source');
          if (tsxFilename != null) {
            tilesetFilenames.add(tsxFilename);
          }
        }
      });

      final tilesetMap = Map<String, String>();
      await Future.forEach(tilesetFilenames, (String tsxFilename) async {
        final normalized = p.normalize('$mapDir/$tsxFilename');
        String contents = await Flame.bundle.loadString(normalized);
        tilesetMap[tsxFilename] = contents;
      });

      return t.TileMapParser.parseTmx(contents, tsx: TsxProv(tilesetMap));
    });
  }

  Future<Map<String, SpriteBatch>> _loadImages(t.TiledMap map) async {
    final Map<String, SpriteBatch> result = {};
    await Future.forEach(map.tilesets, (t.Tileset tileset) async {
      final tmxImage = tileset.image;
      final imagePath = getTilesetImagePath(tileset, tmxImage);
      if (imagePath != null) {
        result[tmxImage!.source!] = await SpriteBatch.load(imagePath);
      }
    });
    return result;
  }

  List<t.ObjectGroup> getObjectGroupLayers() {
    return map!.layers.whereType<t.ObjectGroup>().toList();
  }

  List<t.TileLayer> getTileLayerLayers() {
    return map!.layers.whereType<t.TileLayer>().toList();
  }

  /// Generate the sprite batches from the existing tilemap.
  void generate() {
    for (var batch in batches.keys) {
      batches[batch]!.clear();
    }
    _drawTiles(map!);
  }
/*
  Int2 getTileXY(t.Tile tile) {
    final tileset = map.tilesetByTileGId(tile.localId);

    int width = map.width;
    int x = tile.localId / width;
    int y = tile.localId % width;

    return Int2(x, y);
  }
*/

  // Get tile rectangle in world space
  Rect? tileRect(Tile? tile) {
    if (tile == null) {
      return null;
    }

    final x = tile.coord.x * map!.tileWidth;
    final y = tile.coord.y * map!.tileHeight;
/*
    int width = map!.width;
    int x = tile.localId % width ;
    int y = (tile.localId.toDouble() / width.toDouble()).toInt();
  */  
    return Rect.fromLTRB(x.toDouble(), y.toDouble(), (x + map!.tileWidth).toDouble(), (y + map!.tileHeight).toDouble());
    //return rectFromTilePostion(Int2(tile.x, tile.y));
  }

  void _drawTiles(t.TiledMap map) {
    t.Layer l;
    final tileLayerLayers = getTileLayerLayers();
    tileLayerLayers.where((layer) => layer.visible && layer.tileData != null).forEach((layer) {
      int y = 0;
      layer.tileData!.forEach((tileRow) {

        int x = 0;
        tileRow.forEach((gid) {
          t.Tile tile = map.tileByGid(gid.tile);
          if (tile.isEmpty) {
            ++x;
            return;
          }

          // test it out!
          //TTile? test = layer.tile(Int2(x, y));
          //final testCoords = test!.coord;
          //final testTileset = test.tileset(map);

/*
          int x2 = tile.localId % map.width ;
          int y2 = (tile.localId.toDouble() / map.width.toDouble()).toInt();
    */

          final tileset = map.tilesetByTileGId(gid.tile); //tile.localId);
          final batch = batches[tileset.image!.source];

          final rect = tileset.computeDrawRect(tile);
          final src = Rect.fromLTRB(rect.left.toDouble(), rect.top.toDouble(), rect.right.toDouble(), rect.bottom.toDouble());

          final flips = _SimpleFlips.fromFlips(gid.flips);
          final Size tileSize = Size(tileset.tileWidth!.toDouble(), tileset.tileHeight!.toDouble());

          final offset = Vector2(
              x.toDouble() * tileSize.width +
                  (gid.flips.horizontally ? tileSize.width : 0),
              y.toDouble() * tileSize.height +
                  (gid.flips.vertically ? tileSize.height : 0),
            );

          batch!.add(
            source: src,
            offset: offset,
            rotation: flips.angle * math.pi / 2,
            scale: tileSize.width / tileset.tileWidth!.toDouble(),
          );

          ++x;
        });

        ++y;
      });
    });
  }

  bool loaded() => _loaded;

  @override
  void render(Canvas c) {
    if (!loaded()) {
      return;
    }

    batches.forEach((_, batch) {
      batch.render(c);
    });

    super.render(c);
  }

  Future load(String filename) async {
    this.filename = filename;
    this.destTileSize = Size(32.0, 32.0);
    scale = 1.0;
    future = _load();
    await future;
  }

  Future createEntitiesFromObjects() async {

    // iterate over all objectGroups in the map
    // do a look up to get data from map.yaml
    // this will then allow us to look up which components to spawn
    Factory f = Factory();
    for (final objectGroup in getObjectGroupLayers()) {
      for (final tmxObj in objectGroup.objects) {

        try {
          //final tmxObjName = tmxObj.name;

          // attempt to load the entity using the type field
          final type = tmxObj.type;
          if (type == null) {
            continue;
          }

/*
          // debugging
          if (type != 'teleporter') {
            continue;
          }
*/
          String filename = "assets/$type.yml";
          List<t.Property> properties = tmxObj.properties;
          Map<String, dynamic> substitutions = {};
          properties.forEach((p) {
            if (p.type == t.PropertyType.object) {
              // TODO: resolve object
              print("resolve object");
            }
            substitutions[p.name] = p.value;
          });
          substitutions['type'] = type;
          substitutions['filename'] = filename;
          substitutions['name'] = tmxObj.name;
          substitutions['position'] = '[${tmxObj.x.toDouble()}, ${tmxObj.y.toDouble()}]';
          Entity? e = await f.createFromFile<Entity>(filename, substitutions: substitutions);
          if (e == null) {
            continue;
          }

          Position? p = e.findFirstChildByClass<Position>();
          if (p != null) {
            p.setPosition(tmxObj.positionCenter, Anchor.center);
          }

          Component tmxObjectComponent = await f.createFromData({'component': 'TiledObject', 'name': 'TiledObject', 'object': tmxObj});
          e.addChild(tmxObjectComponent);
          e.resolve(gameRef);
          gameRef.add(e); // add to world to start updating and rendering
        } catch (e) {
          // this is not an entity
          //print(e);
        }
      }
    }
  }

  t.TiledObject? findObjectById(int id) {
    for (final objectGroup in getObjectGroupLayers()) {
      for (final tmxObj in objectGroup.objects) {
        if (tmxObj.id == id) {
          return tmxObj;
        }
      }
    }

    return null;
  }

  List<t.TiledObject> findObjectsByType(String type) {
    List<t.TiledObject> objs = [];
    for (final objectGroup in getObjectGroupLayers()) {
      for (final tmxObj in objectGroup.objects) {
        if (tmxObj.type == type) {
          objs.add(tmxObj);
        }
      }
    }
    return objs;
  }

/*
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
*/


  Int2? worldToTileSpace(Vector2 position) {
    if (!loaded()) {
      return null;
    }
    
    double gridX = (position.x - (map!.tileWidth * scale)) / (map!.tileWidth * scale);
    double gridY = (position.y - (map!.tileHeight * scale)) / (map!.tileHeight * scale);

    int x = gridX.ceil();
    int y = gridY.ceil();

    return Int2(x, y);
  }
/*
  Rect rectFromTilePostion(Int2 position) {
    if (tiled == null || !tiled.loaded()) {
      return null;
    }

    return Rect.fromLTWH(position.x * tiled.map.tileWidth * scale, position.y * tiled.map.tileHeight * scale, tiled.map.tileWidth * scale, tiled.map.tileHeight * scale);
  }
*/
  t.TiledObject? getObjectByName({required String layerName, required String name}) {
    for (var layer in getObjectGroupLayers().where((layer) => layer.name == layerName)) {
      final object = layer.objects.cast().firstWhere((obj) {
        return obj.name == name;
      }, orElse: () => null);

      if (object != null) {
        return object;
      }
    }
    return null;
  }

  t.TiledObject? getObjectFromWorldPosition({required String layerName, required Vector2 worldPosition, Int2? tileOffset, bool nullIfEmpty: true}) {
    Int2? position = worldToTileSpace(worldPosition);
    if (position == null) {
      return null;
    }

    if (tileOffset != null) {
      position = position + tileOffset;
    }

    return getObjectFromPosition(layerName: layerName, position: position, nullIfEmpty: nullIfEmpty);
  }

  t.TiledObject? getObjectFromPosition({required String layerName, required Int2 position, bool nullIfEmpty: true}) {
    if (!loaded() || position == null) {
      return null;
    }

    if (position.y < 0 || position.x < 0) {
      return null;
    }

    for (var layer in getObjectGroupLayers().where((layer) => layer.name == layerName)) {
      t.TiledObject? object = layer.objects.cast().firstWhere((obj) {
        // we can cache this at load time? only if performance is an issue
        Int2? objTileSpace = worldToTileSpace(Vector2(obj.x, obj.y));
        if (objTileSpace == null) {
          return false;
        }

        bool isAtPos = objTileSpace.x == position.x && objTileSpace.y == position.y;
        return isAtPos;
      }, orElse: () => null);

      if (object != null) {
        return object;
      }
    }

    return null;
  }

  Tile? getTile({required String layerName, required Int2 position, bool nullIfEmpty: true}) {
    if (!loaded() || position == null) {
      return null;
    }

    if (position.y < 0 || position.x < 0) {
      return null;
    }

    for (var layer in getTileLayerLayers().where((layer) => layer.name == layerName && layer.tileData != null)) {
      Tile? tile = layer.tile(position);
      return tile;
      /*
      if (position.y >= layer.tileData!.length) {
        return null;
      }
      List<t.Gid> row = layer.tileData![position.y];
      if (position.x >= row.length) {
        return null;
      }
      t.Gid gid = row[position.x];
      t.Tile tile = map!.tileByGid(gid.tile);
      if (tile.isEmpty) {
        return null;
      }

      return tile;*/
    }

    return null;
  }

  Tile? getTileFromWorldPosition({required String layerName, required Vector2 worldPosition, Int2? tileOffset, bool nullIfEmpty: true}) {
    Int2? position = worldToTileSpace(worldPosition);
    if (position == null) {
      return null;
    }

    if (tileOffset != null) {
      position = position + tileOffset;
    }
    return getTile(layerName: layerName, position: position, nullIfEmpty: nullIfEmpty);
  }

  Int2 mapTileSize() {
    final width = map!.width;
    final height = map!.height;
    return Int2(width, height);
  }

  Vector2 mapPixelSize() {
    final width = map!.width * map!.tileWidth * scale;
    final height = map!.height * map!.tileHeight * scale;
    return Vector2(width, height);
  }

  Body createStaticPhysicsBodyBoundary() {
    final def = BodyDef();
    final boundaryBody = gameRef.world.createBody(def);
    boundaryBody.userData = 'Boundary';

    final shape = PolygonShape();

    final fixtureDef = FixtureDef(shape);

    final width = map!.width * map!.tileWidth * scale;
    final height = map!.height * map!.tileHeight * scale;

    final boundaryX = width;
    final boundaryY = height;

    shape.setAsEdge(
      Vector2(0, 0),
      Vector2(boundaryX, 0),
    );

    boundaryBody.createFixture(fixtureDef);

    shape.setAsEdge(
      Vector2(boundaryX, 0),
      Vector2(boundaryX, boundaryY),
    );
    boundaryBody.createFixture(fixtureDef);

    shape.setAsEdge(
      Vector2(boundaryX, boundaryY),
      Vector2(0, boundaryY),
    );
    boundaryBody.createFixture(fixtureDef);

    shape.setAsEdge(
      Vector2(0, boundaryY),
      Vector2(0, 0),
    );
    boundaryBody.createFixture(fixtureDef);

    return boundaryBody;
  }
}
