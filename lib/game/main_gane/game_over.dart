import 'package:flutter/material.dart';

// Builds the game over menu for this game.
class GameOverMenu extends StatefulWidget {
  // Score to display on game over menu.

  // This function will be called when restart button is pressed.
  final VoidCallback onRestartPressed;

  // Optional: Add a function for navigating to the main menu if needed
  final VoidCallback? onMainPressed;

  const GameOverMenu({
    super.key,
    required this.onRestartPressed,
    this.onMainPressed,
  });

  @override
  State<GameOverMenu> createState() => _GameOverMenuState();
}

class _GameOverMenuState extends State<GameOverMenu> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth - 40,
          maxHeight: MediaQuery.of(context).size.height / 4,
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          color: Colors.green.shade800,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Game Over',
                  style: TextStyle(
                    fontSize: screenWidth / 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1.0)),
                          backgroundColor: Colors.white),
                      onPressed: widget.onRestartPressed,
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth / 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1.0)),
                          backgroundColor: Colors.white),
                      onPressed: widget.onMainPressed,
                      child: Text(
                        'Main Menu',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth / 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
