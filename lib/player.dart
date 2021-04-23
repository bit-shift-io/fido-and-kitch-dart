import 'dart:ui';
import 'package:flame/anchor.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:tiled/tiled.dart';

import 'game.dart';
import 'tiled_map.dart';
import 'utils.dart';
import 'player_animations.dart';
import 'input_action.dart';
import 'base_component.dart';

class Player extends PositionComponent with Resizable, ChildComponents, HasGameRef {

  dynamic data;
  dynamic currentStateData;

  Map<String, AnimationComponent> animations = Map();
  AnimationComponent currentAnimation;

  Map<String, InputAction> inputActions = Map();

  Player() : super() {
    x = 0.0;
    y = 0.0;
    width = 100.0;
    height = 100.0;
    anchor = Anchor.bottomCenter;
    debugMode = true;
    load();
  }

  addAnimation(String name, AnimationComponent animationComponent) {
    animations[name] = animationComponent;
  }

  addInputAction(String name, InputAction action) {
    inputActions[name] = action;
  }

  Future<void> load() async {
    data = await loadYamlFromFile('cat.yaml');
    String dir = data['directory'];
    var anims = data['animations'];
    for (var a in anims) {
      addAnimation(a['name'], animationComponentFromSprites(await spritesFromFilenames(anim(dir, a['name'], a['frames'])), stepTime: a['stepTime'], loop: a['loop']));
    }

    addInputAction('move_left', InputAction(keyLabel: 'ArrowLeft'));
    addInputAction('move_right', InputAction(keyLabel: 'ArrowRight'));

    // set currentStateData to 'Walk'
    dynamic states = data['states'];
    currentStateData = states.nodes.firstWhere((s) => s['name'] == 'Walk');
    setAnimation('Walk');
  }

  void setAnimation(animationName) {
    currentAnimation = animations[animationName];
  }

  @override
  void render(Canvas c) {
    //super.render(c);

    if (currentAnimation != null) {
      currentAnimation.render(c);
    }
  }

  @override
  void update(double dt) {
    //super.update(dt);

    if (inputActions['move_left']?.isKeyDown ?? false) {
      x -= currentStateData['movementSpeed'] * dt;
    }
    if (inputActions['move_right']?.isKeyDown ?? false) {
      x += currentStateData['movementSpeed'] * dt;
    }

    // perform collision detection
    // hrmmm
    // TODO: maybe use the players position to compute the x, y of the grid the player is on
    // then get tiles to left right, bottom, top etc, to make sure they can move
    //List<Tile> intersectingTiles = (gameRef as MyGame).map.rectIntersectingTiles(toRect());
    TiledMap map = (gameRef as MyGame).map;
    dynamic tileCoords = map.worldToTileSpace(x: x, y: y);
    Tile t = map.getTile(x: tileCoords.x, y: tileCoords.y, layerName: 'Ground');

    if (currentAnimation != null) {
      currentAnimation.x = x;
      currentAnimation.y = y;
      currentAnimation.width = width;
      currentAnimation.height = height;
      currentAnimation.update(dt);
    }
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
}
