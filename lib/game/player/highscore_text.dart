import 'package:flutter/material.dart';
import 'package:jungle_jumper/game/main_gane/game.dart';

class HighscoreText {
  final MainGame mainGame;
  late TextPainter painter;
  late Offset position;

  HighscoreText(this.mainGame) {
    painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    position = Offset.zero;
  }

  void render(Canvas canvas) {
    painter.paint(canvas, position);
  }

  void update(double t) {
    int highscore = mainGame.storage.getInt('highscore') ?? 0;
    painter.text = TextSpan(
      text: 'Highscore: $highscore',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 40.0,
      ),
    );
    painter.layout();
  }
}
