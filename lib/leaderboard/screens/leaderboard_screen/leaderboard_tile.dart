import 'package:flutter/material.dart';
import 'package:jungle_jumper/leaderboard/models/highscore_data.dart';

class PlayerHighscoreTile extends StatelessWidget {
  final HighscoreData highscoreData;

  const PlayerHighscoreTile({super.key, required this.highscoreData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text(highscoreData.name),
          trailing: Text(highscoreData.score.toString()),
        ),
      ),
    );
  }
}
