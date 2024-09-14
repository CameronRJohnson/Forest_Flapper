import 'package:flutter/material.dart';
import 'package:jungle_jumper/home/main_menu.dart';
import 'package:jungle_jumper/leaderboard/models/highscore_data.dart';
import 'package:jungle_jumper/leaderboard/models/player.dart';
import 'package:jungle_jumper/leaderboard/services/auth.dart';
import 'package:jungle_jumper/leaderboard/services/database.dart';
import 'package:jungle_jumper/leaderboard/shared/costs.dart';
import 'package:jungle_jumper/leaderboard/shared/loadings.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsFormState extends StatefulWidget {
  final HighscoreData? highscoreData;

  const SettingsFormState({super.key, this.highscoreData});

  @override
  State<SettingsFormState> createState() => _SettingsFormStateState();
}

class _SettingsFormStateState extends State<SettingsFormState> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  SharedPreferences? _storage;
  String? _currentName;
  Future<void>? _future;

  Future<void> _compute() async {
    _storage = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _future = _compute();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    Player? player = Provider.of<Player?>(context);

    logoutScreen(UserData userData) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.green.shade900,
            title: const Text(
              "Do You Really Want To Log Out?",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: screenHeight / 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'If you logout your phone\'s highscore will be reset to zero. Your account\'s highscore will however stay as it is.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth / 25,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1.0)),
                          backgroundColor: Colors.white),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () async {
                        await _storage?.setInt('highscore', 0);
                        await _auth.signOut();

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MainMenu(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return StreamBuilder<UserData>(
          stream: DatabaseService(uid: player?.uid).userData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserData userData = snapshot.data!;
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight / 15),
                        child: const Text(
                          'Update Your Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: screenHeight / 50, left: 10),
                            child: const Text(
                              'Username',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight / 30),
                        child: TextFormField(
                          initialValue: userData.name,
                          decoration: textDecoration,
                          validator: (val) =>
                              val!.isEmpty ? 'Please enter a name' : null,
                          onChanged: (val) =>
                              setState(() => _currentName = val),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Your Score: ${userData.score}',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight / 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(1.0)),
                                backgroundColor: Colors.white),
                            child: const Text(
                              'Update',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 10),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                int highscore =
                                    _storage?.getInt('highscore') ?? 0;
                                int? currentScore = userData.score;

                                if (highscore >= currentScore!) {
                                  await DatabaseService(uid: player?.uid)
                                      .updateUserData(
                                    _currentName ?? userData.name!,
                                    highscore,
                                  );
                                } else {
                                  await DatabaseService(uid: player?.uid)
                                      .updateUserData(
                                    _currentName ?? userData.name!,
                                    currentScore,
                                  );
                                  _storage?.setInt('highscore', currentScore);
                                }
                                Navigator.pop(context);
                              }
                            },
                          ),
                          SizedBox(width: screenWidth / 30),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(1.0)),
                                backgroundColor: Colors.white),
                            child: const Text(
                              'Logout',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 10),
                            ),
                            onPressed: () => logoutScreen(userData),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Loading();
            }
          },
        );
      },
    );
  }
}
