
import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:tiled/tiled.dart';
import 'package:yaml/yaml.dart';

import 'player.dart';
import 'utils.dart';
//import 'game.dart';
import 'tiled_map.dart';

class PlayerState {
  Player player;
  String name;
  dynamic data;

  PlayerState(this.player, this.name) {
    // assign state data from yml to data field
    dynamic statesData = player.data['states'];
    data = statesData.nodes.firstWhere((s) => s['name'] == name, orElse: () => null);
  }

  void enter() {
    //YamlMap m;
    // by default try to play animation with the same name as the state
    final animationName = data?.nodes['animationName'] ?? name;
    player.setAnimation(animationName);
  }

  void exit() {}
  void update(double dt) {}

  bool canTransition() => true; // override to help know if we can transition to other states
}


class Idle extends PlayerState {
  Idle(Player player, String name) : super(player, name);

  @override
  void update(double dt) {
    InputState state = player.getInputState();

    player.applyMovement(dt, gravity: true);

    if (player.velocity.y > 0.0) {
      player.setState('Fall');
      return;
    }

    if (state.dir.x != 0.0) {
      player.setState('Walk');
      return;
    }

    if (state.dir.y != 0.0) {
      if (player.states['Ladder'].canTransition()) {
        player.setState('Ladder');
      }
    }

    if (state.use) {
      player.setState('Use');
      return;
    }
  }
}


class Walk extends PlayerState {
  Walk(Player player, String name) : super(player, name);

  @override
  void update(double dt) {
    player.applyMovement(dt, gravity: true, movementSpeed: data['movementSpeed']);

    if (player.velocity.y > 0.0) {
      player.setState('Fall');
      return;
    }

    if (player.velocity.x == 0.0) {
      player.setState('Idle');
      return;
    }
  }
}


class Fall extends PlayerState {
  Fall(Player player, String name) : super(player, name);

  @override
  void update(double dt) {
    player.applyMovement(dt);
    
    if (player.velocity.y == 0.0) {
      player.setState('Idle');
    }

    // TODO: how hard did we hit the ground? DEAD?!
  }
}


class Dead extends PlayerState {
  Dead(Player player, String name) : super(player, name);

  @override
  void update(double dt) {}
}

class Teleport extends PlayerState {
  Teleport(Player player, String name) : super(player, name);

  @override
  void update(double dt) {}
}

class Ladder extends PlayerState {
  Ladder(Player player, String name) : super(player, name);

  bool canTransition() {
    TiledMap map = player.gameRef.map;
    Tile ladderTile = map.getTileFromWorldPosition(worldPosition: player.position, layerName: 'Ladders');
    return ladderTile != null;
  }

  @override
  void update(double dt) {
    InputState state = player.getInputState();
    
    TiledMap map = player.gameRef.map;
    Tile ladderTile = map.getTileFromWorldPosition(worldPosition: player.position, layerName: 'Ladders');
    if (ladderTile != null) {
      print("we can have a ladder!");

      Rect ladderTileRect = map.tileRect(ladderTile);
      player.gameRef.debug.drawRect(ladderTileRect, Colors.pink, PaintingStyle.fill);
    
      Tile nextLadderTile = map.getTileFromWorldPosition(worldPosition: player.position, tileOffset: Int2.fromVector2(state.dir), layerName: 'Ladders');
      if (nextLadderTile != null) {
        print("there is a ladder in the direction we are moving.... okay!");

        Rect nextLadderTileRect = map.tileRect(nextLadderTile);
        player.gameRef.debug.drawRect(nextLadderTileRect, Colors.brown, PaintingStyle.fill);

      }
    }

    player.applyMovement(dt, gravity: false, movementSpeed: data['movementSpeed']);

    // TODO: fell off the ladder?
  }
}

class Elevator extends PlayerState {
  Elevator(Player player, String name) : super(player, name);

  @override
  void update(double dt) {}
}

class Use extends PlayerState {
  Use(Player player, String name) : super(player, name);

  @override
  void update(double dt) {}
}