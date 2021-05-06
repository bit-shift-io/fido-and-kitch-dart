import 'package:flame/components.dart';
import 'game.dart';
import 'player_states.dart';
import 'utils.dart';
import 'input_action.dart';

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
    data = await loadYamlFromFile('player.yml');
    String dir = data['directory'];
    var anims = data['animations'];
    for (var a in anims) {
      addAnimation(a['name'], animationComponentFromSprites(await spritesFromFilenames(anim(dir, a['name'], a['frames'])), stepTime: a['stepTime'], loop: a['loop']));
    }

    addInputAction('move_left', InputAction(keyLabel: 'ArrowLeft'));
    addInputAction('move_right', InputAction(keyLabel: 'ArrowRight'));

    // setup states
    addState(Idle(this, 'Idle'));
    addState(Walk(this, 'Walk'));
    addState(Fall(this, 'Fall'));
    addState(Dead(this, 'Dead'));

    setState('Idle');
  }

  void setAnimation(animationName) {
    if (currentAnimation != null) {
      removeChild(currentAnimation);
    }
    currentAnimation = animations[animationName];
    if (currentAnimation != null) {
      addChild(currentAnimation);
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

  void onKeyEvent(e) {
    for (var a in inputActions.values) {
      a.onKeyEvent(e);
    }
  }

  void spawn({double x, double y}) {
    this.x = x;
    this.y = y;
  }

  double getMovementDirection() {
    double m = 0.0;
    if (inputActions['move_left']?.isKeyDown ?? false) {
      m = -1.0;
    }
    if (inputActions['move_right']?.isKeyDown ?? false) {
      m = 1.0;
    }

    return m;
  }

  void move(Vector2 offset) {
    x += offset.x;
    y += offset.y;
  }
}
