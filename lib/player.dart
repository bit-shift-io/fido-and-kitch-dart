import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart' hide SpriteAnimation;
import 'package:flutter/material.dart' hide Switch;

import 'components/entity.dart';
import 'components/physics_body.dart';
import 'components/position.dart';
import 'components/sprite_animation.dart';
import 'components/switch.dart';
import 'tiled_map.dart';
import 'components/extensions.dart';
import 'player_states.dart';
import 'input_action.dart';
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

    position!.position = physicsBody!.body!.position;

    super.update(dt);
  }

  // move this to a player movement component?
  void applyMovement(double dt, {bool gravity: true, double movementSpeed = 1.0, bool collisionDetection: true}) {
    InputState state = getInputState();

    physicsBody!.body!.gravityScale = gravity ? 1.0 : 0.0;

    final vel = Vector2(state.dir.x * 2000.0 * dt, physicsBody!.body!.linearVelocity.y);
    if (!gravity) {
      vel.y = state.dir.y * 2000.0 * dt;
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
}

Future<Player> playerComponentFromData(dynamic yaml) async {
  final comp = new Player();
  await comp.fromData(yaml);
  return comp;
}
