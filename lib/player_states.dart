
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
    final animationName = data?.nodes['animationName']?.value ?? name;
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
    if (ladderTile != null) {
      return true;
    }

    // if moving down, is there a ladder below us?
    InputState state = player.getInputState();
    if (state.dir.y > 0) {
      Tile nextLadderTile = map.getTileFromWorldPosition(worldPosition: player.position, tileOffset: Int2.fromVector2(state.dir), layerName: 'Ladders');
      if (nextLadderTile != null) {
        return true;
      }
    }

    return false;
  }

  @override
  void update(double dt) {

    // TODO:
    // a few issues here:
    // 1. when moving down, we can move down through the floor. Shouldn't be able to go down here
    // 2. when moving up, we push out above the ladder. Shouldn't be able to leave the ground
    // 3. sliding off the side of a ladder allows the player to run in the air for a bit?!
    
    InputState state = player.getInputState();
    
    TiledMap map = player.gameRef.map;
    Tile ladderTile = map.getTileFromWorldPosition(worldPosition: player.position, layerName: 'Ladders');

    if (ladderTile != null) {
      Rect ladderTileRect = map.tileRect(ladderTile);
      player.gameRef.debug.drawRect(ladderTileRect, Colors.pink, PaintingStyle.stroke);
    }

    // moving down
    if (state.dir.y > 0) {
      if (ladderTile == null) {
        // is there a tile below us?
        Tile nextLadderTile = map.getTileFromWorldPosition(worldPosition: player.position, tileOffset: Int2.fromVector2(state.dir), layerName: 'Ladders');
        if (nextLadderTile == null) {
          // hit the ground
          player.setState('Fall');
          return;
        }
      }
    }
    // moving up
    else {
      if (ladderTile == null) {
        Tile prevLadderTile = map.getTileFromWorldPosition(worldPosition: player.position, tileOffset: Int2.fromVector2(-state.dir), layerName: 'Ladders');
        if (prevLadderTile == null) {
          // can't go any higher
          player.setState('Fall');
          return;
        }
      }
    }

    player.applyMovement(dt, gravity: false, collisionDetection: false, movementSpeed: data['movementSpeed']);
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