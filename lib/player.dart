import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart' hide SpriteAnimation;
import 'package:flame_forge2d/flame_forge2d.dart' hide Position;
import 'package:flutter/material.dart' hide Switch;

import 'components/area.dart';
import 'components/entity.dart';
import 'components/physics_body.dart';
import 'components/position.dart';
import 'components/sprite_animation.dart';
import 'components/switch.dart';
import 'tiled_map.dart';
import 'components/extensions.dart';
import 'player_states.dart';
import 'input.dart';
import 'utils/number.dart';

class InputState {
  Vector2 dir = Vector2(0, 0);
  bool use = false;
}

class Player extends Entity {
  dynamic data;
  Switch? animations;
  PhysicsBody? physicsBody;
  Position? position;
  Area? useSensor;

  Map<String, InputAction> inputActions = Map();

  // ECS sample: https://github.com/Unity-Technologies/EntityComponentSystemSamples/tree/master/ECSSamples/Assets/Use%20Case%20Samples/1.%20State%20Machine%20AI
  Map<String, PlayerState> states = Map(); // TODO: replace with Switch or StateMachineComponent
  PlayerState? currentState;

  Vector2 velocity = Vector2(0, 0);

  Player() : super() {
  }

  addState(PlayerState state) {
    states[state.name] = state;
  }

  addInputAction(String name, InputAction action) {
    inputActions[name] = action;
  }

  setState(String name) {
    PlayerState? prevState = currentState;
    PlayerState? nextState = states[name];

    if (prevState != null) {
      prevState.exit();
    }

    if (nextState != null) {
      nextState.enter();
    }

    currentState = nextState;
  }

  Future<void> fromData(dynamic yaml) async {
    await super.fromData(yaml);
    
    final c = children; // for debugging

    data = yaml;
    debugMode = yaml['debugMode'] ?? this.debugMode;

    position = findFirstChildByClass<Position>();
    if (position == null) {
      print("Couldn't find Position named 'Position'");
      return;
    }
    position!.anchor = Anchor.center;

    // pull out any named components we need
    animations = position!.findFirstChild<Switch>('Animations');
    if (animations == null) {
      print("Couldn't find SwitchComponent named 'Animations'");
      return;
    }

    physicsBody = findFirstChildByClass<PhysicsBody>();
    if (physicsBody == null) {
      print("Couldn't find PhysicsBody named 'PhysicsBody'");
      return;
    }

    useSensor = findFirstChild<Area>('UseSensor');
    if (useSensor == null) {
      print("Couldn't find Area named 'UseSensor'");
    }


    addInputAction('move_left', InputAction(keyLabel: 'ArrowLeft'));
    addInputAction('move_right', InputAction(keyLabel: 'ArrowRight'));
    addInputAction('move_up', InputAction(keyLabel: 'ArrowUp'));
    addInputAction('move_down', InputAction(keyLabel: 'ArrowDown'));
    addInputAction('use', InputAction(keyLabel: 'e'));

    // setup states
    addState(Idle(this, 'Idle'));
    addState(Walk(this, 'Walk'));
    addState(Fall(this, 'Fall'));
    addState(Dead(this, 'Dead'));
    addState(Ladder(this, 'Ladder'));
    addState(Teleport(this, 'Teleport'));
    addState(Elevator(this, 'Elevator'));
    addState(Use(this, 'Use'));

    setState('Idle');
  }

  void setAnimation(animationName, {OnCompleteSpriteAnimation? onComplete}) {
    if (animations == null) {
      return;
    }

    animations!.setActiveComponent(animationName);

    final currentAnimation = animations!.activeComponent as SpriteAnimation?;
    if (currentAnimation != null) {
      currentAnimation.width = position!.width;
      currentAnimation.height = position!.height;

      if (currentAnimation.animation != null) {
        currentAnimation.animation!.reset();
        currentAnimation.animation!.onComplete = onComplete;
      }
    }
    else {
      print("Couldn't finad animation $animationName");
    }
  }

  @override
  void update(double dt) {
    if (currentState != null) {
      currentState!.update(dt);
    }

    final pos = physicsBody!.body!.position;
    position!.position = pos;
    if (useSensor != null) {
      useSensor!.physicsBody!.body!.setPosition(pos);
    }

    super.update(dt);
  }

  // move this to a player movement component?
  void applyMovement(double dt, {bool gravity: true, double movementSpeed = 1.0, bool collisionDetection: true}) {
    InputState state = getInputState();

    final moveDt = movementSpeed * 1000.0 * dt;
    final vel = Vector2(state.dir.x * moveDt, physicsBody!.body!.linearVelocity.y);
    if (!gravity) {
      vel.y = state.dir.y * moveDt;
      //physicsBody!.body!.gravityScale = 1;
      physicsBody!.body!.setType(BodyType.kinematic);
    } else {
      physicsBody!.body!.setType(BodyType.dynamic);
      //physicsBody!.body!.gravityScale = 1;
    }
    physicsBody!.body!.linearVelocity = vel;
    /*
    Vector2 moveVec = Vector2(state.dir.x, 0);//velocity.y);
    
    // TODO: if moveVec is greater than say half the tile size, break it up
    // and do multiple collision checks to aacount for low fps
    // for now we have this to stop extreme issues while debugging:
    //dt = min(dt, 0.033);
/*
    if (gravity) {
      moveVec.y += 9.8 * dt;
    }
    else {
      moveVec.y = movementSpeed * dt * state.dir.y;
    }

    moveVec.x *= movementSpeed * dt;


    if (collisionDetection) {
      moveVec = detectCollision(moveVec);
    }

*/
    velocity = moveVec;
    move(moveVec);*/
  }

  Vector2 detectCollision(Vector2 moveVec) {

    // perform collision detection
    TiledMap map = gameRef.map!;
    Int2? tileCoords = map.worldToTileSpace(position!.position);
    if (tileCoords != null) {
      Rect playerRect = position!.toRect();

      //player.gameRef.debug.drawRect(playerRect, Colors.yellow, PaintingStyle.fill);
      

      Int2 tileCoordBelow = tileCoords + Int2(0, 1);

      //Rect belowTileRect = map.rectFromTilePostion(tileCoordBelow);
      //player.gameRef.debug.drawRect(belowTileRect, Colors.purple, PaintingStyle.fill);
      
      Tile? tileBelow = map.getTile(position: tileCoordBelow, layerName: 'ground');
      if (tileBelow != null && !tileBelow.isEmpty) {
        Rect? tileRect = map.tileRect(tileBelow);

        double playerBottom = playerRect.bottom;
        double tileTop = tileRect!.top;
        double playerDistToTile = tileTop - playerBottom;

        moveVec.y = min(moveVec.y, playerDistToTile);

        gameRef.debug!.drawRect(tileRect, Colors.blue, PaintingStyle.fill);
      }
/*
      // TODO: get the tile to the left or right
      Int2 tileCoordNextTo = tileCoords + Int2(moveVec.x as int, 0);
      Tile tileNextTo = map.getTile(position: tileCoordNextTo, layerName: 'foreground');
      if (tileNextTo != null && !tileNextTo.isEmpty) {
        Rect tileRect = map.tileRect(tileNextTo);

        player.gameRef.debug.drawRect(tileRect, Colors.green, PaintingStyle.fill);
      }*/
    }

    return moveVec;
  }

  void onKeyEvent(e) {
    for (var a in inputActions.values) {
      a.onKeyEvent(e);
    }
  }

  void onGestureEvent(e) {
    switch (e.type) {
      case GestureEventType.Drag: {
        if (e.state == GestureState.End) {
          inputActions['move_left']!.isKeyDown = false;
          inputActions['move_right']!.isKeyDown = false;
          inputActions['move_up']!.isKeyDown = false;
          inputActions['move_down']!.isKeyDown = false;
          return;
        }
        final v = e.velocity;
        if (v.x < 0.0) {
          inputActions['move_left']!.isKeyDown = true;
        }
        if (v.x > 0.0) {
          inputActions['move_right']!.isKeyDown = true;
        }
        if (v.y < 0.0) {
          inputActions['move_up']!.isKeyDown = true;
        }
        if (v.y > 0.0) {
          inputActions['move_down']!.isKeyDown = true;
        }
      } break;

      case GestureEventType.Tap: {
        if (e.state == GestureState.End) {
          inputActions['use']!.isKeyDown = false;
          return;
        }

        inputActions['move_left']!.isKeyDown = true;
      } break;
    }
  }

  void spawn(Vector2 position) {
    this.position!.position = position;
    if (physicsBody != null) {
      physicsBody!.body!.setPosition(position);
    }
  }

  // move to a player input component
  InputState getInputState() {
    InputState state = InputState();

    if (inputActions['move_left']?.isKeyDown ?? false) {
      state.dir.x = -1.0;
    }
    if (inputActions['move_right']?.isKeyDown ?? false) {
      state.dir.x = 1.0;
    }

    if (inputActions['move_up']?.isKeyDown ?? false) {
      state.dir.y = -1.0;
    }
    if (inputActions['move_down']?.isKeyDown ?? false) {
      state.dir.y = 1.0;
    }

    if (inputActions['use']?.isKeyDown ?? false) {
      state.use = true;
    }

    return state;
  }

  void move(Vector2 offset) {
    physicsBody!.body!.applyLinearImpulse(offset);
    //position!.position += offset;
  }

  Vector2 get positionBottomCenter {
    return position!.getPosition(Anchor.bottomCenter);
  }
  
  Vector2 get positionBottomLeft {
    //Vector2 c = position!.position;
    Vector2 bl = physicsBody!.body!.position + Vector2(physicsBody!.aabb.lowerBound.x, physicsBody!.aabb.upperBound.y) + Vector2(-1, 0);
    //Vector2 bl2 = position!.getPosition(Anchor.bottomLeft);
    return bl;
  }

  Vector2 get positionBottomRight {
    Vector2 br = physicsBody!.body!.position + physicsBody!.aabb.upperBound + Vector2(1, 0);
    return br;
    //return position!.getPosition(Anchor.bottomRight);
  }

  // Return the tile under the player or null if not on the ground
  Tile? getGroundTile() {

    TiledMap map = gameRef.map!;
    final groundDistVec = Vector2(0, 5.0);
    // what tile is at the players feet?
    Vector2 pos = positionBottomLeft + groundDistVec;

    gameRef.debug!.drawRect(Rect.fromCircle(center: pos.toOffset(), radius: 5), Colors.black, PaintingStyle.fill);
    
    Tile? tile = map.getTileFromWorldPosition(worldPosition: pos, layerName: 'ground');
    if (tile != null && !tile.isEmpty) {
      return tile;
    }

    pos = positionBottomRight + groundDistVec;

    gameRef.debug!.drawRect(Rect.fromCircle(center: pos.toOffset(), radius: 5), Colors.black, PaintingStyle.fill);
    

    tile = map.getTileFromWorldPosition(worldPosition: pos, layerName: 'ground');
    if (tile != null && !tile.isEmpty) {
      return tile;
    }

    return null;
  }

  bool get isOnGround {
    return getGroundTile() != null;
  }
}

Future<Player> playerComponentFromData(dynamic yaml) async {
  final comp = new Player();
  await comp.fromData(yaml);
  return comp;
}
