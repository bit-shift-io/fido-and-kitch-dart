import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';

import 'package:fido_and_kitch/game.dart';
import 'package:fido_and_kitch/player_animations.dart';

void main() {
  runApp(MaterialApp(
    title: 'Fido & Kitch',
    color: Colors.white,
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: GameWrapper(),
    ),
  ));

  Flame.util.fullScreen();
}

class GameWrapper extends StatefulWidget {
  @override
  GameWrapperState createState() => GameWrapperState();
}


class GameWrapperState extends State<GameWrapper> {
  bool splashGone = false;
  MyGame game;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    Flame.images.loadAll(walk('cat')).then((images) => {
      setState(() {
        game = MyGame();
        _focusNode.requestFocus();
        splashGone = true; // remove this line to make the user wait till saplsh anim is complete!
        print("Images loaded");
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return splashGone
        ? _buildGame(context)
        : FlameSplashScreen(
      theme: FlameSplashTheme.white,
      onFinish: (context) {
        setState(() {
          splashGone = true;
        });
      },
    );
  }

/*
  void _onRawKeyEvent(RawKeyEvent event) {
    if(event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.space) {
      game.onAction();
    }
  }
*/

  Widget _buildGame(BuildContext context) {

    if (game == null) {
      return const Center(
        child: Text("Loading"),
      );
    }
    return Container(
      color: Colors.white,
      constraints: const BoxConstraints.expand(),
      child: Container(
          child: RawKeyboardListener(
            key: ObjectKey("neh"),
            child: game.widget,
            focusNode: _focusNode,
            //onKey: _onRawKeyEvent,
          )
      ),
    );
  }
}
