import 'dart:math';
import 'dart:ui';

import 'package:fido_and_kitch/components/entity.dart';
import 'package:fido_and_kitch/components/inventory_component.dart';

import 'components/switch_component.dart';
import 'tiled_map.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tiled/tiled.dart';
import 'components/mixins.dart';
import 'components/extensions.dart';
import 'factory.dart';
import 'game.dart';
import 'player_states.dart';
import 'input_action.dart';
import 'utils/number.dart';

class InputState {
  Vector2 dir = Vector2(0, 0);
  bool use = false;
}

class Player extends Entity {
  dynamic data;
  SwitchComponent animations;

  Map<String, InputAction> inputActions = Map();

  // ECS sample: https://github.com/Unity-Technologies/EntityComponentSystemSamples/tree/master/ECSSamples/Assets/Use%20Case%20Samples/1.%20State%20Machine%20AI
  Map<String, PlayerState> states = Map(); // TODO: replace with SwitchComponent or StateMachineComponent
  PlayerState currentState;

  Vector2 velocity = Vector2(0, 0);

  Player() : super() {
    x = 0.0;
    y = 0.0;
    width = 32.0;
    height = 32.0;
    anchor = Anchor.bottomCenter;
  }

  addState(PlayerState state) {
    states[state.name] = state;
  }

  addInputAction(String name, InputAction action) {
    inputActions[name] = action;
  }

  setState(String name) {
    PlayerState prevState = currentState;
    PlayerState nextState = states[name];

    if (prevState != null) {
      prevState.exit();
    }

    if (nextState != null) {
      nextState.enter();
    }

    currentState = nextState;
  }

  Future<void> fromYaml(dynamic yaml) async {
    await super.fromYaml(yaml);
    
    data = yaml;
    debugMode = yaml['debugMode'] ?? false;

    // pull out any named components we need
    animations = findFirstChild<SwitchComponent>('Animations');
    if (animations == null) {
      print("Couldn't find SwitchComponend named 'Animations'");
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

    setState('Idle');
  }

  void setAnimation(animationName, {OnCompleteSpriteAnimation onComplete}) {
    if (animations == null) {
      return;
    }

    animations.setActiveComponent(animationName);

    var currentAnimation = animations.activeComponent as SpriteAnimationComponent;
    if (currentAnimation != null) {
      currentAnimation.width = width;
      currentAnimation.height = height;

      currentAnimation.animation.reset();
      currentAnimation.animation.onComplete = onComplete;
    }
    else {
      print("Couldn't finad animation $animationName");
    }
  }

  @override
  void update(double dt) {
    if (currentState != null) {
      currentState.update(dt);
    }

    super.update(dt);
  }

  // move this to a player movement component?
  void applyMovement(double dt, {bool gravity: true, double movementSpeed = 1.0, bool collisionDetection: true}) {
    InputState state = getInputState();
    Vector2 moveVec = Vector2(state.dir.x, velocity.y);
    
    if (gravity) {
      moveVec.y += 9.8 * dt;
    }
    else {
      moveVec.y = movementSpeed * dt * state.dir.y;
    }

    if (collisionDetection) {
      moveVec = detectCollision(moveVec);
    }

    moveVec.x *= movementSpeed * dt;

    velocity = moveVec;
    move(moveVec);
  }

  Vector2 detectCollision(Vector2 moveVec) {

    // perform collision detection
    TiledMap map = gameRef.map;
    Int2 tileCoords = map.worldToTileSpace(position);
    if (tileCoords != null) {
      Rect playerRect = toRect();

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

        gameRef.debug.drawRect(tileRect, Colors.blue, PaintingStyle.fill);
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

    return moveVec;
  }

  void onKeyEvent(e) {
    for (var a in inputActions.values) {
      a.onKeyEvent(e);
    }
  }

  void spawn({double x, double y}) {
    this.x = x;
    this.y = y;
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

    return state;
  }

  void move(Vector2 offset) {
    x += offset.x;
    y += offset.y;
  }
}

Future<Player> playerComponentFromYaml(dynamic yaml) async {
  final comp = new Player();
  await comp.fromYaml(yaml);
  return comp;
}
