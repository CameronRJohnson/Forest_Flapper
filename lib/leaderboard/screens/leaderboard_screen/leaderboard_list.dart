import 'package:flutter/material.dart';
import 'package:jungle_jumper/leaderboard/models/highscore_data.dart';
import 'package:jungle_jumper/leaderboard/screens/leaderboard_screen/leaderboard_tile.dart';
import 'package:provider/provider.dart';

class LeaderboardList extends StatefulWidget {
  const LeaderboardList({super.key});

  @override
  LeaderboardListState createState() => LeaderboardListState();
}

class LeaderboardListState extends State<LeaderboardList> {
  @override
  Widget build(BuildContext context) {
    final differentHighScores = Provider.of<List<HighscoreData>>(context);

    return ListView.builder(
      itemCount: differentHighScores.length,
      itemBuilder: (BuildContext context, int index) {
        return PlayerHighscoreTile(highscoreData: differentHighScores[index]);
      },
    );
  }
}
