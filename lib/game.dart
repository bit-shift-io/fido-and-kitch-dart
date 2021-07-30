import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:tiled/tiled.dart' as t;
import 'package:flame/components.dart';
import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flame_forge2d/forge2d_game.dart';

import 'components/area.dart';
import 'components/physics_body.dart';
import 'hetu_script.dart';
import 'input.dart';
import 'systems/pickup_system.dart';
import 'tiled_map.dart';
import 'player.dart';
import 'components/system.dart';
import 'components/extensions.dart';
import 'debug.dart';
import 'factory.dart';

// this is the world in ECS terms
class Game extends Forge2DGame with HasCollidables, DoubleTapDetector, TapDetector, KeyboardEvents, VerticalDragDetector, HorizontalDragDetector {
  final double squareSize = 20;
  bool running = true;

  List<System> systems = [];
  Map<String, List> entityLists = Map();

  TiledMap? map;
  Debug? debug;

  Future<void> onLoad() async {
    const tileSize = 32.0;
    const tileSizeInMetres = 1;
    const gravityMultiplier = tileSizeInMetres * tileSize;
    world.setGravity(Vector2(0, 10.0 * gravityMultiplier));
    // register anything needed here
    //await HetuScript().init();

    // setup special contact callbacks
    addContactCallback(AreaPhysicsBodyContactCallback());
    addContactCallback(AreaAreaContactCallback());

    // load these from yaml?
    //addSystem(new PickupSystem());
    
    map = TiledMap();
    add(map!);

    debug = Debug();
    add(debug!);
 
    map!.load('assets/maps/ll1.tmx').then(onMapLoad);  

  }

  void addSystem(System system) {
    systems.add(system);
    add(system);
  }

  void addEntity(Component entity, List<String> listNames) {
    for (final listName in listNames) {
      if (!entityLists.containsKey(listName)) {
        entityLists[listName] = [];
      }

      entityLists[listName]!.add(entity);
    }
  }

  void removeEntity(Component entity, List<String> listNames) {
    for (final listName in listNames) {
      if (!entityLists.containsKey(listName)) {
        return;
      }

      entityLists[listName]!.remove(entity);
    }
  }

  List<T> getEntities<T>(String listName) {
    if (!entityLists.containsKey(listName)) {
      return [];
    }

    return List<T>.from(entityLists[listName]!);
  }

  List<Player> get players => getEntities<Player>('Players');

  void onMapLoad(value) async {
    print('map loaded');

    // set the viewport to fit the whole map to the screen
    Vector2 mapSize = map!.mapPixelSize();
    viewport = FixedResolutionViewport(mapSize);
    camera.zoom = 1;

    map!.createEntitiesFromObjects();
    map!.createStaticPhysicsBodyBoundary();

    // convert tile layers into physics - TODO: can we have a layer flags which turns colissions on or off?
    final groundTileLayers = map!.getTileLayerLayers().where((layer) => layer.name == 'ground');
    for (TileLayer tileLayer in groundTileLayers) {
      tileLayer.createStaticPhysicsBodies(map!);
    }


    Player? p = await Factory().createFromFile<Player>('assets/player.yml');
    p!.resolve(this);

    List<t.TiledObject> spawns = map!.findObjectsByType("spawn");
    for (int i = 0; i < min(players.length, spawns.length); ++i) {
      t.TiledObject spawn = spawns[i];
      Player p = players[i];
      p.spawn(spawn.positionCenter);
      add(p); // add to world to start updating and rendering
    }
  }

  @override
  void onKeyEvent(e) {
    for (Player p in players) {
      p.onKeyEvent(e);
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    for (Player p in players) {
      p.onGestureEvent(GestureEvent(GestureEventType.Tap, GestureState.Start, Vector2.zero()));
    }
  }

  @override
  void onTapUp(details) {
    for (Player p in players) {
      p.onGestureEvent(GestureEvent(GestureEventType.Tap, GestureState.End, Vector2.zero()));
    }

    /*
    final touchArea = Rect.fromCenter(
      center: details.localPosition,
      width: 20,
      height: 20,
    );

    bool handled = false;
    components.forEach((c) {
      if (c is PositionComponent && c.toRect().overlaps(touchArea)) {
        handled = true;
        markToRemove(c);
      }
    });

    if (!handled) {
      addLater(Square()
        ..x = touchArea.left
        ..y = touchArea.top);
    }*/
  }

  @override
  void onDoubleTap() {
    if (running) {
      pauseEngine();
    } else {
      resumeEngine();
    }

    running = !running;
  }

  @override
  void onHorizontalDragDown(DragDownInfo info) {
    //print('onHorizontalDragDown');
  }

  @override
  void onHorizontalDragStart(DragStartInfo info) {
    for (Player p in players) {
      p.onGestureEvent(GestureEvent(GestureEventType.Drag, GestureState.Start, Vector2.zero()));
    }
  }

  @override
  void onHorizontalDragUpdate(DragUpdateInfo info) {
    for (Player p in players) {
      p.onGestureEvent(GestureEvent(GestureEventType.Drag, GestureState.Update, info.delta.global));
    }
  }

  @override
  void onHorizontalDragEnd(DragEndInfo info) {
    for (Player p in players) {
      p.onGestureEvent(GestureEvent(GestureEventType.Drag, GestureState.End, info.velocity));
    }
  }

  @override
  void onHorizontalDragCancel() {
    for (Player p in players) {
      p.onGestureEvent(GestureEvent(GestureEventType.Drag, GestureState.End, Vector2.zero()));
    }
  }

  @override
  void onVerticalDragDown(DragDownInfo info) {
    //print('onVerticalDragDown');
  }

  @override
  void onVerticalDragStart(DragStartInfo info) {
    for (Player p in players) {
      p.onGestureEvent(GestureEvent(GestureEventType.Drag, GestureState.Start, Vector2.zero()));
    }
  }

  @override
  void onVerticalDragUpdate(DragUpdateInfo info) {
    for (Player p in players) {
      p.onGestureEvent(GestureEvent(GestureEventType.Drag, GestureState.Update, info.delta.global));
    }
  }

  @override
  void onVerticalDragEnd(DragEndInfo info) {
    for (Player p in players) {
      p.onGestureEvent(GestureEvent(GestureEventType.Drag, GestureState.End, info.velocity));
    }
  }

  @override
  void onVerticalDragCancel() {
    for (Player p in players) {
      p.onGestureEvent(GestureEvent(GestureEventType.Drag, GestureState.End, Vector2.zero()));
    }
  }
}