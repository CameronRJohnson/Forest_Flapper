import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jungle_jumper/leaderboard/screens/authenticate/authenticate.dart';
import 'package:jungle_jumper/leaderboard/screens/leaderboard_screen/leaderboard_menu.dart';
import 'package:provider/provider.dart';

import '../models/player.dart';

import 'auth.dart';

class AuthenticationChecker extends StatefulWidget {
  const AuthenticationChecker({super.key});

  @override
  State<AuthenticationChecker> createState() => _AuthenticationCheckerState();
}

class _AuthenticationCheckerState extends State<AuthenticationChecker> {
  @override
  Widget build(BuildContext context) {
    // Initializing Firebase App
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check if the initialization is complete
        if (snapshot.connectionState == ConnectionState.done) {
          // Providing the Player stream using StreamProvider
          return StreamProvider<Player?>.value(
            value: AuthService().player,
            initialData: null,
            child: Consumer<Player?>(
              builder: (context, user, _) {
                // If user is null, show Authenticate screen, otherwise show Settings
                if (user == null) {
                  return const Authenticate();
                } else {
                  return const Settings();
                }
              },
            ),
          );
        }
        // Display loading indicator while Firebase initializes
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
