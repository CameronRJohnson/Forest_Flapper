import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:jungle_jumper/home/main_menu.dart';
import 'package:jungle_jumper/leaderboard/models/player.dart';
import 'package:jungle_jumper/leaderboard/shared/transition.dart';
import 'package:provider/provider.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  MobileAds.instance.initialize();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jungle Jumper',
      theme: ThemeData(
        fontFamily: "Joystix",
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamProvider<Player>(
        create: (_) => null,
        initialData: Player(),
        child: const SplashScreenGame(),
      ),
    );
  }
}

class SplashScreenGame extends StatefulWidget {
  const SplashScreenGame({super.key});

  @override
  SplashScreenGameState createState() => SplashScreenGameState();
}

class SplashScreenGameState extends State<SplashScreenGame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlameSplashScreen(
        theme: FlameSplashTheme.dark,
        onFinish: (context) => Navigator.of(context).pushReplacement(
          PageTransition(
            page: const MainMenu(),
            transitionType: TransitionType.fade,
          ),
        ),
      ),
    );
  }
}
