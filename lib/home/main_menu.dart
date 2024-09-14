import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:jungle_jumper/ad_helper.dart';
import 'package:jungle_jumper/game/main_gane/game_manager.dart';
import 'package:jungle_jumper/leaderboard/services/authentication_checker.dart';
import 'package:jungle_jumper/leaderboard/shared/transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  SharedPreferences? _storage;
  late Future<void> _future;
  BannerAd? _bannerAd;
  bool soundOn = true;
  bool tiltOn = false;
  bool vibrateOn = true;

  @override
  void initState() {
    _future = _initializeSharedPreferences();

    // Creates and loads the ad on the screen
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    ).load();
    super.initState();
  }

  Future<void> _initializeSharedPreferences() async {
    _storage = await SharedPreferences.getInstance();
    setState(() {
      soundOn = _storage?.getBool('soundOn') ?? true;
      tiltOn = _storage?.getBool('tiltOn') ?? true;
      vibrateOn = _storage?.getBool('vibrateOn') ?? true;
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    lightVibration() {
      if (_storage!.getBool('vibrateOn') != false) {
        HapticFeedback.lightImpact();
      }
    }

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/Background.png',
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 30),
                        child: Container(
                          width: screenWidth,
                          decoration: BoxDecoration(
                            color: Colors.green.shade900.withOpacity(.8),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(3.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Forest',
                                  style: TextStyle(
                                    fontSize: screenWidth / 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Flapper',
                                  style: TextStyle(
                                    fontSize: screenWidth / 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, top: 40),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade900.withOpacity(.8),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(2.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                      Colors.green.shade800.withOpacity(0.8),
                                    ),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(1.0),
                                        side: const BorderSide(
                                            color: Colors.white, width: 2.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      PageTransition(
                                        page: const GamePlay(),
                                        transitionType: TransitionType.fade,
                                      ),
                                    );
                                    lightVibration();
                                  },
                                  child: const Text(
                                    "Play",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 70,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Highscore:${_storage!.getInt('highscore') ?? 0}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      PageTransition(
                                        page: const AuthenticationChecker(),
                                        transitionType: TransitionType.fade,
                                      ),
                                    );
                                    lightVibration();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(2.0)),
                                      backgroundColor: Colors.green),
                                  child: const Text(
                                    'Leaderboard',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 25),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(3.0)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape:
                                                  const RoundedRectangleBorder(),
                                              padding: EdgeInsets.zero,
                                            ),
                                            onPressed: () {},
                                            child: SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: Image.asset(
                                                _storage!.getString('player') ??
                                                    'assets/images/bird-blue.gif',
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              _showHatchery(context);
                                              lightVibration();
                                            },
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.0)),
                                                backgroundColor: Colors.brown),
                                            child: const Text(
                                              'Hatchery',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _showSettingsDialog(context);
                                    lightVibration();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(2.0)),
                                      backgroundColor: Colors.blueGrey),
                                  child: const Text(
                                    'Settings',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 25),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_bannerAd != null)
                    Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    )
                  else
                    const SizedBox()
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHatchery(BuildContext context) {
    // Use a StatefulBuilder to handle the state within the dialog itself
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Use a function to get the current coin count
            int getCurrentCoins() {
              return _storage?.getInt('points') ?? 0;
            }

            return AlertDialog(
              backgroundColor: Colors.brown.shade900,
              title: Text(
                "Hatchery",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width / 20,
                ),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black26,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          _buildBirdButtons(context, setState, getCurrentCoins),
                    ),
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: [
                Text(
                  'Coins:${getCurrentCoins()}',
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                )
              ],
            );
          },
        );
      },
    );
  }

// Function to build the bird buttons dynamically
  List<Widget> _buildBirdButtons(BuildContext context, StateSetter setState,
      int Function() getCurrentCoins) {
    // Bird configurations with explicit types
    final List<Map<String, dynamic>> birds = [
      {'path': 'assets/images/bird-blue.gif', 'lockKey': null, 'cost': 0},
      {
        'path': 'assets/images/bird-brown.gif',
        'lockKey': 'brown_islocked',
        'cost': 150
      },
      {
        'path': 'assets/images/bird-red.gif',
        'lockKey': 'red_islocked',
        'cost': 300
      },
    ];

    return birds.map((bird) {
      // Cast values to appropriate types
      String path = bird['path'] as String;
      String? lockKey = bird['lockKey'] as String?;
      int cost = bird['cost'] as int;

      return _buildBirdButton(
          context, path, lockKey, cost, setState, getCurrentCoins);
    }).toList();
  }

// Updated _buildBirdButton method
  Widget _buildBirdButton(
    BuildContext context,
    String assetPath,
    String? lockKey,
    int cost,
    StateSetter setState,
    int Function() getCurrentCoins,
  ) {
    bool isLocked = lockKey != null && (_storage?.getBool(lockKey) ?? true);

    return GestureDetector(
      onTap: () {
        _handleBirdSelection(
          assetPath,
          lockKey,
          cost,
          isLocked,
          setState,
          getCurrentCoins,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.transparent,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset(assetPath),
                ),
                Text(
                  cost.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          if (isLocked)
            const Icon(
              Icons.lock_outline,
              size: 40,
              color: Colors.white70,
            ),
        ],
      ),
    );
  }

// Handles the selection logic for bird skins
  void _handleBirdSelection(String assetPath, String? lockKey, int cost,
      bool isLocked, StateSetter setState, int Function() getCurrentCoins) {
    int currentPoints = getCurrentCoins();

    if (isLocked && currentPoints >= cost) {
      setState(() {
        _storage?.setBool(lockKey!, false);
        _updateSprite(assetPath, cost);
      });
    } else if (!isLocked) {
      _updateSprite(assetPath, 0);
    }
  }

// Function to update sprite path, deduct points, and unlock if applicable
  void _updateSprite(String path, int cost) {
    if (_storage == null) return;

    int currentPoints = _storage!.getInt('points') ?? 0;

    if (currentPoints >= cost) {
      _storage!.setString('player', path);
      _storage!.setInt('points', currentPoints - cost);
    }

    setState(() {});
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.blueGrey,
              title: Text(
                "Settings",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width / 20),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black26,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Sound FX",
                              style: TextStyle(color: Colors.white),
                            ),
                            Switch(
                              value: soundOn,
                              activeColor: Colors.green.shade100,
                              onChanged: (bool value) {
                                setState(() {
                                  soundOn = value;
                                });
                                _storage?.setBool('soundOn', value);
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Vibrations",
                              style: TextStyle(color: Colors.white),
                            ),
                            Switch(
                              value: vibrateOn,
                              activeColor: Colors.green.shade100,
                              onChanged: (bool value) {
                                setState(() {
                                  vibrateOn = value;
                                });
                                _storage?.setBool('vibrateOn', value);
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Pro Mode",
                              style: TextStyle(color: Colors.white),
                            ),
                            Switch(
                              value: tiltOn,
                              activeColor: Colors.green.shade100,
                              onChanged: (bool value) {
                                setState(() {
                                  tiltOn = value;
                                });
                                _storage?.setBool('tiltOn', value);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: [
                TextButton(
                  onPressed: () {
                    rateApp();
                  },
                  child: const Text(
                    "Rate App",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> rateApp() async {
    Uri url = Uri(path: 'https://play.google.com/store/games?hl=en_US');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
