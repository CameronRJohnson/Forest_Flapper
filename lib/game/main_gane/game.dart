import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jungle_jumper/game/coin/coin.dart';
import 'package:jungle_jumper/game/coin/coin_spawner.dart';
import 'package:jungle_jumper/game/enemy/enemy_spawner.dart';
import 'package:jungle_jumper/game/enemy/side_enemy.dart';
import 'package:jungle_jumper/game/main_gane/game_over.dart';
import 'package:jungle_jumper/game/player/player.dart';
import 'package:jungle_jumper/home/main_menu.dart';
import 'package:jungle_jumper/leaderboard/shared/transition.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainGame extends FlameGame with TapDetector {
  final SharedPreferences storage;
  Random rand = Random();
  late final ParallaxComponent _parallaxComponent;
  late final GamePlayer _mainplayer;
  TextComponent? _scoreText;
  int allowedDistance = 10;
  late final EnemyManager _enemyManager;
  late final CoinManager _coinManager;
  int score = 0;
  bool _isGameOver = false;
  GyroscopeEvent? _gyroscopeEvent;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  bool _soundOn = true;
  bool _vibrateOn = true;
  bool _tiltOn = true;

  MainGame(this.storage);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    FlameAudio.bgm.initialize();
    _soundOn = storage.getBool('soundOn') ?? true;
    _vibrateOn = storage.getBool('vibrateOn') ?? true;
    _tiltOn = storage.getBool('tiltOn') ?? false;

    if (_soundOn) {
      FlameAudio.bgm.play('game_audio.mp3', volume: 0.8);
    }

    overlays.addEntry(
      'GameOverMenu',
      (context, game) => GameOverMenu(
        onRestartPressed: () {
          reset();
          overlays.remove('GameOverMenu');
        },
        onMainPressed: () {
          Navigator.of(context).pushReplacement(
            PageTransition(
              page: const MainMenu(),
              transitionType: TransitionType.fade,
            ),
          );
        },
      ),
    );

    await _initializeParallax();
    _initializeMainPlayer();
    _initializeEnemyManager();
    _initializeScoreText();
    _initializeGyroscope();
    _initalizeCoinManager();

    add(_parallaxComponent);
    add(_mainplayer);
    add(_coinManager);
    add(_enemyManager);
    add(_scoreText!);

    _setScoreTextPosition();
  }

  void _initializeMainPlayer() {
    _mainplayer = GamePlayer();
  }

  Future<void> _initializeParallax() async {
    _parallaxComponent = await ParallaxComponent.load(
      [
        ParallaxImageData('Layer_0010_1.png'),
        ParallaxImageData('Layer_0009_2.png'),
        ParallaxImageData('Layer_0008_3.png'),
        ParallaxImageData('Layer_0006_4.png'),
        ParallaxImageData('Layer_0005_5.png'),
        ParallaxImageData('Layer_0003_6.png'),
        ParallaxImageData('Layer_0002_7.png'),
        ParallaxImageData('Layer_0001_8.png'),
        ParallaxImageData('Layer_0000_9.png'),
      ],
      baseVelocity: Vector2(100, 0),
      velocityMultiplierDelta: Vector2(1.2, 0),
    );
  }

  void _initalizeCoinManager() {
    _coinManager = CoinManager(storage);
  }

  void _initializeEnemyManager() {
    _enemyManager = EnemyManager(storage);
  }

  void _initializeScoreText() {
    _scoreText = TextComponent(
      text: score.toString(),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Joystix',
          fontSize: 60,
        ),
      ),
    );
  }

  void _initializeGyroscope() {
    _gyroscopeSubscription =
        gyroscopeEventStream().listen((GyroscopeEvent event) {
      _gyroscopeEvent = event;
    });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _setScoreTextPosition();
  }

  void _setScoreTextPosition() {
    if (_scoreText != null) {
      _scoreText!.anchor = Anchor.center;
      _scoreText!.position = Vector2(size.x / 2, size.y / 8);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _scoreText!.text = score.toString();
    if (_gyroscopeEvent != null && _tiltOn) {
      _mainplayer.x -= _gyroscopeEvent!.z * 5;
    } else {
      _mainplayer.x = size.x / 2;
    }

    // Check for collision with bottom
    if (_mainplayer.y >= size.y - _mainplayer.height * 2) {
      _mainplayer.hit();
      gameOver();
    }

    // Check for collisions with enemies
    for (var enemy in children.whereType<Enemy>()) {
      if (_mainplayer.distance(enemy) < 37) {
        _mainplayer.hit();
        enemy.removeFromParent();
      }
    }

    for (var coin in children.whereType<Coin>()) {
      if (_mainplayer.distance(coin) < 37) {
        addCoin();
        if (_soundOn) {
          FlameAudio.play('coin.mp3');
        }
        coin.removeFromParent();
      }
    }

    if (_mainplayer.life <= 0) {
      gameOver();
    }
  }

  void addCoin() {
    // Retrieve the current points, defaulting to 0 if null
    int currentPoints = storage.getInt('points') ?? 0;

    // Increment the points
    if (storage.getString('player') == 'assets/images/bird-brown.gif') {
      storage.setInt('points', currentPoints + 5);
    } else {
      storage.setInt('points', currentPoints + 1);
    }
    if (score > (storage.getInt('highscore') ?? 0)) {
      storage.setInt('highscore', score);
    }
    score += 1;
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    jump();
  }

  void reset() {
    score = 0;
    _mainplayer.speedY = 0;
    if (storage.getString('player') == 'assets/images/bird-red.gif') {
      _mainplayer.life = 2;
    } else {
      _mainplayer.life = 1;
    }
    _coinManager.reset();
    _enemyManager.reset();
    _isGameOver = false;
    add(_mainplayer);
    add(_scoreText!);

    overlays.remove('GameOverMenu');
    resumeEngine();
    if (_soundOn = storage.getBool('soundOn') ?? true) {
      FlameAudio.bgm.play('game_audio.mp3');
    }

    // Remove all enemies from the game
    for (var enemy in children.whereType<Enemy>()) {
      enemy.removeFromParent();
    }

    // Remove all coins from the game
    for (var coin in children.whereType<Coin>()) {
      coin.removeFromParent();
    }
  }

  void jump() async {
    if (_isGameOver) return;
    super.onTap();
    _mainplayer.jump();
    if (_vibrateOn) {
      HapticFeedback.mediumImpact();
    }
    if (_soundOn) {
      FlameAudio.play('wing.mp3');
    }
  }

  void gameOver() {
    FlameAudio.bgm.stop();

    if (_soundOn) {
      FlameAudio.play('womp_womp.mp3', volume: 0.5);
    }

    // Ensure that the player and score text are removed from the screen
    if (_mainplayer.isMounted) {
      _mainplayer.removeFromParent();
    }

    _isGameOver = true;
    pauseEngine();

    if (_vibrateOn) {
      HapticFeedback.heavyImpact();
    }

    // Display the Game Over menu overlay
    overlays.add('GameOverMenu');
  }

  @override
  void onRemove() {
    FlameAudio.bgm.stop();

    _gyroscopeSubscription
        ?.cancel(); // Cancel the subscription when the game is removed
    super.onRemove();
  }
}
