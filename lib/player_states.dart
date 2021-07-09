import 'dart:ui';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

import 'components/inventory.dart';
import 'components/position.dart';
import 'components/script.dart';
import 'components/usable.dart';
import 'components/extensions.dart';
import 'components/entity.dart';
import 'player.dart';
import 'tiled_map.dart';
import 'utils/number.dart';

class PlayerState {
  Player player;
  String name;
  dynamic data;

  PlayerState(this.player, this.name) {
    // assign state data from yml to data field
    dynamic statesData = player.data['states'];
    data = statesData.nodes.cast().firstWhere((s) => s['name'] == name, orElse: () => null);
  }

  void enter() {
    //YamlMap m;
    // by default try to play animation with the same name as the state
    final animationName = data?.nodes['animationName']?.value ?? name;
    player.setAnimation(animationName);
  }

  void exit() {}
  void update(double dt) {}

  // immutable
  bool canTransition() => true; // override to help know if we can transition to other states
  
  // mutable
  bool tryTransition() {
    if (canTransition()) {
      player.setState(name);
      return true;
    }

    return false;
  }
}


class Idle extends PlayerState {
  Idle(Player player, String name) : super(player, name);

  @override
  void update(double dt) {
    InputState state = player.getInputState();

    player.applyMovement(dt);

    if (player.states['Fall']!.tryTransition()) {
      return;
    }

    if (state.dir.x != 0.0) {
      player.setState('Walk');
      return;
    }

    if (state.dir.y != 0.0) {
      if (player.states['Ladder']!.tryTransition()) {
        return;
      }
    }

    if (state.use) {
      if (player.states['Use']!.tryTransition()) {
        return;
      }
    }
  }
}


class Walk extends PlayerState {
  Walk(Player player, String name) : super(player, name);

  @override
  void update(double dt) {
    InputState state = player.getInputState();
    player.applyMovement(dt, movementSpeed: data['movementSpeed'].toDouble());

    if (player.states['Fall']!.tryTransition()) {
      return;
    }

    if (state.dir.x == 0.0) {
      player.setState('Idle');
      return;
    }

    if (player.states['Teleport']!.tryTransition()) {
      return;
    }
  }
}


class Fall extends PlayerState {
  Fall(Player player, String name) : super(player, name);

  bool canTransition() {
    bool inAir = !player.isOnGround;
    return inAir;
  }

  @override
  void update(double dt) {
    player.applyMovement(dt);
    
    if (player.velocity.y == 0.0) {
      player.setState('Idle');
    }

    if (player.states['Teleport']!.tryTransition()) {
      return;
    }

    // TODO: how hard did we hit the ground? DEAD?!
  }
}


class Dead extends PlayerState {
  Dead(Player player, String name) : super(player, name);

  @override
  void update(double dt) {}
}

enum TeleportState {
  None,
  PlayingFromAnim,
  FinishedFromAnim,
  PlayingToAnim,
  FinishedToAnim
}

class Teleport extends PlayerState {
  TiledObject? from;
  TiledObject? to;
  TeleportState state = TeleportState.None;

  Teleport(Player player, String name) : super(player, name);

  TiledObject? getTeleportObjectUnderPlayer() {
    TiledMap? map = player.gameRef.map;
    return map!.getObjectFromWorldPosition(worldPosition: player.position!.position, layerName: 'teleporters'); // TODO: FIXME! Get from collision contact or teleporters entity list
  }

  bool canTransition() {
    TiledObject? teleporter = getTeleportObjectUnderPlayer();
    if (teleporter == null) {
      return false;
    }

    if (teleporter == from) {
      return false;
    }

    if (teleporter == to) {
      return false;
    }

    return true;
  }

  bool tryTransition() {
    // if player moved off of the teleporter,
    // clear the tile
    TiledObject? teleporter = getTeleportObjectUnderPlayer();
    if (teleporter == null) {
      from = null;
      to = null;
    }

    return super.tryTransition();
  }

  void enter() {
    /* TODO: FIXME
    state = TeleportState.PlayingFromAnim;

    TiledMap map = player.gameRef.map;
    from = map.getObjectFromWorldPosition(worldPosition: player.position, layerName: 'teleporters'); // TODO: FIXME! Get from collision contact or teleporters entity list
    to = map.getObjectByName(layerName: 'teleporters', name: from.properties['target']); /// TODO: FIXME! Get from collision contact or teleporters entity list

    final animationName = data?.nodes['fromAnimationName']?.value;
    player.setAnimation(animationName, onComplete: onFromAnimationComplete);
    */
  }

  void onFromAnimationComplete() {
    state = TeleportState.FinishedFromAnim;
  }

  void onToAnimationComplete() {
    state = TeleportState.FinishedToAnim;
  }

  @override
  void update(double dt) {
    switch (state) {
      case TeleportState.FinishedFromAnim:
        state = TeleportState.PlayingToAnim;
        final animationName = data?.nodes['toAnimationName']?.value;
        player.setAnimation(animationName, onComplete: onToAnimationComplete);
        if (to != null) {
          player.position!.position = Vector2(to!.x, to!.y);
        }
        break;

      case TeleportState.FinishedToAnim:
        state = TeleportState.None;
        player.setState('Idle');
        break;

      default:
        break;
    }
  }

}

class Ladder extends PlayerState {
  Ladder(Player player, String name) : super(player, name);

  Tile? getLadderTile() {
    // what tile is at the players feet?
    final pos = player.positionBottomCenter;
    TiledMap map = player.gameRef.map!;
    Tile? ladderTile = map.getTileFromWorldPosition(worldPosition: pos, layerName: 'ladders');
    if (ladderTile != null && !ladderTile.isEmpty) {
      return ladderTile;
    }

    // if moving down, is there a ladder below us?
    InputState state = player.getInputState();
    if (state.dir.y > 0) {
      Tile? nextLadderTile = map.getTileFromWorldPosition(worldPosition: pos, tileOffset: Int2.fromVector2(state.dir), layerName: 'ladders');
      if (nextLadderTile != null && !nextLadderTile.isEmpty) {
        return nextLadderTile;
      }
    }

    return null;
  }

  bool canTransition() {
    return getLadderTile() != null;
  }

  @override
  void update(double dt) {

    // TODO:
    // a few issues here:
    // 1. when moving down, we can move down through the floor. Shouldn't be able to go down here
    // 2. when moving up, we push out above the ladder. Shouldn't be able to leave the ground
    // 3. sliding off the side of a ladder allows the player to run in the air for a bit?!
    
    Tile? ladderTile = getLadderTile();
    if (ladderTile == null) {
      player.setState('Fall');
      return;
    }
    
    TiledMap map = player.gameRef.map!;
    Rect? ladderTileRect = map.tileRect(ladderTile);
    if (ladderTileRect != null) {
      player.gameRef.debug!.drawRect(ladderTileRect, Colors.black, PaintingStyle.fill);
    }
   
    // TODO: as we move up or down, lerp the player
    // towards the centre of the tile and make them not be able to get off
    // when there are walls to the side

    player.applyMovement(dt, gravity: false, collisionDetection: false, movementSpeed: data['movementSpeed'].toDouble());
  }
}

class Elevator extends PlayerState {
  Elevator(Player player, String name) : super(player, name);

  @override
  void update(double dt) {}
}

class Use extends PlayerState {
  Entity? usableEntity;
  bool animationComplete = false;

  Use(Player player, String name) : super(player, name);

  Entity? getUsableUnderPlayer() {
    // is there a usable the player can activate?
    List<Entity> usables = player.gameRef.getEntities<Entity>('Usable');
    final playerRect = player.position!.toRect();
    for (final usable in usables) {
      final usableRect = usable.findFirstChildByClass<Position>()!.toRect();
      if (playerRect.overlaps(usableRect)) {
        return usable;
      }
    }

    return null;
  }

  Usable? getUsable(Entity? entity) {
    if (entity == null) {
      return null;
    }

    List<Usable> usableComponents = entity.findChildrenByClass<Usable>();
    for (final usable in usableComponents) {
      Inventory? playerInventory = player.findFirstChildByClass<Inventory>();
      if (usable.requiredItem == null || (playerInventory != null && playerInventory.hasItem(usable.requiredItem, count: usable.requiredItemCount))) {
        return usable;
      }
    }

    return null;
  }

  bool canTransition() {
    return getUsable(getUsableUnderPlayer()) != null;
  }

  void enter() {
    usableEntity = getUsableUnderPlayer();
    Usable? usableComponent = getUsable(usableEntity);
    
    animationComplete = false;
    final animationName = usableComponent?.playerAnimationOnUse ?? data?.nodes['animationName']?.value ?? name;
    player.setAnimation(animationName, onComplete: onAnimationComplete);
  }

  void onAnimationComplete() {
    animationComplete = true;
  }

  @override
  void update(double dt) {
    if (animationComplete) {
      player.setState('Idle');
      // trigger the use state - how do we make this generic?
      Usable? usableComponent = getUsable(usableEntity);
      if (usableComponent != null) {
        Script? onUseScript = usableComponent.findFirstChild<Script>('OnUse');
        if (onUseScript != null) {
          onUseScript.eval({});
        }
      }
      /*
      Switch switchComponent = usableEntity.findFirstChild<Switch>('State');
      switchComponent.setActiveComponent('Open');
      */
    }
  }
}