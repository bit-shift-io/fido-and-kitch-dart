import 'dart:math';
import 'package:fido_and_kitch/hetu_script.dart';

import 'systems/pickup_system.dart';
import 'tiled_map.dart';
import 'package:flame/components.dart';
import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';

//import 'package:flame_forge2d/forge2d_game.dart';

import 'player.dart';
import 'package:tiled/tiled.dart' as t;

import 'components/system.dart';
import 'debug.dart';
import 'factory.dart';

// this is the world in ECS terms
class MyGame extends /*Forge2DGame*/BaseGame with DoubleTapDetector, TapDetector, KeyboardEvents {
  final double squareSize = 20;
  bool running = true;

  List<System> systems = [];
  Map<String, List> entityLists = Map();

  TiledMap map;
  Debug debug;

  Future<void> onLoad() async {
    // register anything needed here
    //await HetuScript().init();

    // load these from yaml?
    addSystem(new PickupSystem());
    
    map = TiledMap();
    add(map);

    Player p = await Factory().createFromFile<Player>('assets/player.yml');
    p.addToEntityLists(this);
    add(p);
    //addEntity(p, p.entityList);

    /*
    add(p
      ..x = 200
      ..y = 200);
      */

    debug = Debug();
    add(debug);
 

    map.load('assets/maps/sandbox.tmx').then(onMapLoad);  
  }

  void addSystem(System system) {
    systems.add(system);
    add(system);
  }

  void addEntity(Component entity, String listName) {
    if (!entityLists.containsKey(listName)) {
      entityLists[listName] = [];
    }

    entityLists[listName].add(entity);
  }

  void removeEntity(Component entity, String listName) {
    if (!entityLists.containsKey(listName)) {
      return;
    }

    entityLists[listName].remove(entity);
  }

  List<T> getEntities<T>(String listName) {
    if (!entityLists.containsKey(listName)) {
      return [];
    }

    return List<T>.from(entityLists[listName]);
  }

  List<Player> get players => getEntities<Player>('Players');

  void onMapLoad(value) {
    print('map loaded');

    // set the viewport to fit the whole map to the screen
    Vector2 mapSize = map.mapPixelSize();
    viewport = FixedResolutionViewport(mapSize);

    List<t.TiledObject> spawns = map.findObjectsByType("spawn");
    for (int i = 0; i < min(players.length, spawns.length); ++i) {
      t.TiledObject spawn = spawns[i];
      Player p = players[i];
      p.spawn(x: spawn.x.toDouble(), y: spawn.y.toDouble());
    }
  }

  @override
  void onKeyEvent(e) {
    for (Player p in players) {
      p.onKeyEvent(e);
    }
  }

  @override
  void onTapUp(details) {
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
}