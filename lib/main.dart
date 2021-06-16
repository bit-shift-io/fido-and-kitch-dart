import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
//import 'package:flame_splash_screen/flame_splash_screen.dart';

import 'game.dart';

const bool SKIP_SPLASH = true; // set to false to get a properloading screen

void main() {
  runApp(MaterialApp(
    title: 'Fido & Kitch',
    color: Colors.white,
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: GameWrapper(),
    ),
  ));

  //Flame.util.fullScreen();
}

class GameWrapper extends StatefulWidget {
  @override
  GameWrapperState createState() => GameWrapperState();
}

class GameWrapperState extends State<GameWrapper> {
  //bool splashGone = false;
  MyGame? game;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    preload();
/*
    if (SKIP_SPLASH) {
      startGame();
    }*/
  }

  void preload() async {
    // TODO: format these into proper paths... do we load all or let the game.yml determine what dirs to preload?
    /*
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('images/'))
        .where((String key) => key.contains('.png'))
        .toList();
    */

    final imagePaths = List<String>.empty();
    await Flame.images.loadAll(imagePaths);
    startGame();
  }

  void startGame() {
    if (game != null) {
      // already started
      return;
    }

    setState(() {
        game = MyGame();
        _focusNode.requestFocus();
        //splashGone = SKIP_SPLASH ? true : splashGone;
      });
  }

  @override
  Widget build(BuildContext context) {
    return _buildGame(context);
    /*
    return splashGone
        ? _buildGame(context)
        : FlameSplashScreen(
      theme: FlameSplashTheme.white,
      onFinish: (context) {
        setState(() {
          splashGone = true;
        });
      },
    );*/
  }

  

  Widget _buildGame(BuildContext context) {
    if (game == null) {
      return const Center(
        child: Text("Loading"),
      );
    }

    return GameWidget<MyGame>(game: game!);
    /*
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
    );*/
  }
}
