import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:jungle_jumper/game/main_gane/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamePlay extends StatefulWidget {
  const GamePlay({super.key});

  @override
  GamePlayState createState() => GamePlayState();
}

class GamePlayState extends State<GamePlay> {
  late Future<SharedPreferences> _future;

  @override
  void initState() {
    super.initState();
    _future = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('No data available')),
          );
        }

        final SharedPreferences storage = snapshot.data!;
        final MainGame mainGame = MainGame(storage);

        return Scaffold(
          body: GameWidget(
            game: mainGame,
          ),
        );
      },
    );
  }
}
