import 'dart:ui';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:fido_and_kitch/utils.dart';
import 'package:fido_and_kitch/player_animations.dart';
import 'package:fido_and_kitch/input_action.dart';

// https://github.com/flame-engine/trex-flame/blob/master/lib/game/t_rex/t_rex.dart
class Player extends PositionComponent with Resizable {

  dynamic data;
  dynamic currentStateData;

  Map<String, AnimationComponent> animations = Map();
  AnimationComponent currentAnimation;

  Map<String, InputAction> inputActions = Map();

  Player() : super() {
    onLoad();
  }

  addAnimation(String name, AnimationComponent animationComponent) {
    animations[name] = animationComponent;
  }

  addInputAction(String name, InputAction action) {
    inputActions[name] = action;
  }

  Future<void> onLoad() async {
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
    if (currentAnimation != null) {
      currentAnimation.render(c);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (inputActions['move_left']?.isKeyDown ?? false) {
      x -= currentStateData['movementSpeed'] * dt;
    }
    if (inputActions['move_right']?.isKeyDown ?? false) {
      x += currentStateData['movementSpeed'] * dt;
    }

    if (currentAnimation != null) {
      currentAnimation.x = x;
      currentAnimation.y = y;
      currentAnimation.update(dt);
    }
  }

  void onKeyEvent(e) {
    for (var a in inputActions.values) {
      a.onKeyEvent(e);
    }
  }
}
