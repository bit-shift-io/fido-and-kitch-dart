import 'dart:math';
import 'dart:ui';

import 'package:fido_and_kitch/tiled_map.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tiled/tiled.dart';
import 'game.dart';
import 'player_states.dart';
import 'utils.dart';
import 'input_action.dart';

class InputState {
  Vector2 dir = Vector2(0, 0);
  bool use = false;
}

class Player extends PositionComponent with HasGameRef<MyGame> {

  dynamic data;

  Map<String, SpriteAnimationComponent> animations = Map();
  SpriteAnimationComponent currentAnimation;

  Map<String, InputAction> inputActions = Map();

  Map<String, PlayerState> states = Map();
  PlayerState currentState;

  Vector2 velocity = Vector2(0, 0);

  Player() : super() {
    x = 0.0;
    y = 0.0;
    width = 32.0;
    height = 32.0;
    anchor = Anchor.bottomCenter;
    debugMode = true;
    load();
  }

  addState(PlayerState state) {
    states[state.name] = state;
  }

  addAnimation(String name, SpriteAnimationComponent animationComponent) {
    animations[name] = animationComponent;
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

  Future<void> load() async {
    data = await loadYamlFromFile('assets/player.yml');
    String dir = data['directory'];

    // replace this with using spriteAnimationComponentFromYaml
    var anims = data['animations'];
    for (var a in anims) {
      final imageName = a['imageName'] ?? a['name'];
      addAnimation(a['name'], animationComponentFromSprites(await spritesFromFilenames(anim(dir, imageName, a['frames'])), stepTime: a['stepTime'], loop: a['loop'] ?? true, reversed: a['reversed'] ?? false));
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

  void setAnimation(animationName, {OnCompleteSpriteAnimation onComplete = null}) {
    if (currentAnimation != null) {
      removeChild(currentAnimation);
    }
    currentAnimation = animations[animationName];
    if (currentAnimation != null) {
      addChild(currentAnimation);
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

    if (currentAnimation != null) {
      currentAnimation.width = width;
      currentAnimation.height = height;
    }

    super.update(dt);
  }

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
