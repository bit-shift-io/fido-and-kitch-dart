
import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:tiled/tiled.dart';

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
    data = statesData.nodes.firstWhere((s) => s['name'] == name);
  }

  void enter() {
    // by default try to play animation with the same name as the state
    player.setAnimation(name);
  }

  void exit() {}
  void update(double dt) {}
}


class Idle extends PlayerState {
  Idle(Player player, String name) : super(player, name);

  @override
  void update(double dt) {
    if (player.getMovementDirection() != 0.0) {
      player.setState('Walk');
    }
  }
}


class Walk extends PlayerState {
  Walk(Player player, String name) : super(player, name);

  @override
  void update(double dt) {
    Vector2 moveVec = Vector2(player.getMovementDirection(), player.velocity.y);
    //Vector2 moveVec = Vector2(0, player.getMovementDirection());
    /*
    if (moveVec.x == 0.0) {
      player.setState('Idle');
      return;
    }*/

    // are we falling or did we hit an object?
    
    
    moveVec.y += 9.8 * dt;

    // perform collision detection
    TiledMap map = player.gameRef.map;
    Int2 tileCoords = map.worldToTileSpace(player.position);
    if (tileCoords != null) {
      Rect playerRect = player.toRect();

      //player.gameRef.debug.drawRect(playerRect, Colors.yellow, PaintingStyle.fill);
      

      Int2 tileCoordBelow = tileCoords + Int2(0, 1);

      //Rect belowTileRect = map.rectFromTilePostion(tileCoordBelow);
      //player.gameRef.debug.drawRect(belowTileRect, Colors.purple, PaintingStyle.fill);
      
      Tile tileBelow = map.getTile(position: tileCoordBelow, layerName: 'Ground');
      if (tileBelow != null && !tileBelow.isEmpty) {
        Rect tileRect = map.tileRect(tileBelow);

        double playerBottom = playerRect.bottom;
        double tileTop = tileRect.top;
        double playerDistToTile = tileTop - playerBottom;

        moveVec.y = min(moveVec.y, playerDistToTile);

        player.gameRef.debug.drawRect(tileRect, Colors.blue, PaintingStyle.fill);
      }
/*
      // TODO: get the tile to the left or right
      Int2 tileCoordNextTo = tileCoords + Int2(moveVec.x as int, 0);
      Tile tileNextTo = map.getTile(position: tileCoordNextTo, layerName: 'Foreground');
      if (tileNextTo != null && !tileNextTo.isEmpty) {
        Rect tileRect = map.tileRect(tileNextTo);

        player.gameRef.debug.drawRect(tileRect, Colors.green, PaintingStyle.fill);
      }*/
    }

    moveVec.x *= data['movementSpeed'] * dt;

    player.velocity = moveVec;
    player.move(moveVec);
  }
}


class Fall extends PlayerState {
  Fall(Player player, String name) : super(player, name);

  @override
  void update(double dt) {}
}


class Dead extends PlayerState {
  Dead(Player player, String name) : super(player, name);

  @override
  void update(double dt) {}
}