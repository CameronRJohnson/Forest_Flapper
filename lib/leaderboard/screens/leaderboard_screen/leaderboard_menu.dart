import 'package:flutter/material.dart';
import 'package:jungle_jumper/home/main_menu.dart';
import 'package:jungle_jumper/leaderboard/models/highscore_data.dart';
import 'package:jungle_jumper/leaderboard/models/player.dart';
import 'package:jungle_jumper/leaderboard/screens/leaderboard_screen/user_settings.dart';
import 'package:jungle_jumper/leaderboard/services/auth.dart';
import 'package:jungle_jumper/leaderboard/services/database.dart';
import 'package:jungle_jumper/leaderboard/shared/loadings.dart';
import 'package:jungle_jumper/leaderboard/shared/transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'leaderboard_list.dart';

class Settings extends StatefulWidget {
  final HighscoreData? highscoreData;

  const Settings({super.key, this.highscoreData});

  @override
  State<Settings> createState() => _HomeState();
}

class _HomeState extends State<Settings> {
  String? _currentName;
  SharedPreferences? _storage;
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
    Player player = Provider.of<Player>(context);

    void showSettingsPanel() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.green.shade900,
            contentPadding: const EdgeInsets.all(50.0),
            content: StreamProvider<Player?>.value(
              value: AuthService().player,
              initialData: Player(),
              child: const SettingsFormState(),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          );
        },
      );
    }

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return StreamBuilder<UserData>(
          stream: DatabaseService(uid: player.uid).userData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int highscore = _storage!.getInt('highscore') ?? 0;
              int? currentScore = snapshot.data!.score;

              // Check and update highscore
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (_storage != null) {
                  if (currentScore != null) {
                    if (highscore >= currentScore) {
                      await DatabaseService(uid: player.uid).updateUserData(
                        _currentName ?? snapshot.data!.name!,
                        highscore,
                      );
                    } else {
                      await DatabaseService(uid: player.uid).updateUserData(
                        _currentName ?? snapshot.data!.name!,
                        currentScore,
                      );
                      highscore = currentScore;
                    }
                  }
                }
              });

              if (currentScore! >= highscore) {
                _storage?.setInt('highscore', currentScore);
              }

              return StreamProvider<List<HighscoreData>>.value(
                value: DatabaseService().highscoreData,
                initialData: const [],
                child: Scaffold(
                  backgroundColor: Colors.green.shade900,
                  body: GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      PageTransition(
                        page: const MainMenu(),
                        transitionType: TransitionType.fade,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background Image
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/Background.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 50.0),
                            child: Center(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade900.withOpacity(.7),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5.0)),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 40.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            'Leaderboard',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Expanded(
                                      child: LeaderboardList(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20.0),
                                      child: ElevatedButton(
                                        onPressed: showSettingsPanel,
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1.0)),
                                            backgroundColor: Colors.white),
                                        child: const Text('Profile',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
