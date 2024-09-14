import 'dart:math';
import 'package:flame/components.dart';
import 'package:jungle_jumper/game/enemy/side_enemy.dart';
import 'package:jungle_jumper/game/main_gane/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnemyManager extends Component with HasGameRef<MainGame> {
  late Random _random;
  late Timer _timer;
  final SharedPreferences storage;
  int _spawnLevel;
  double _spawnInterval;

  EnemyManager(this.storage)
      : _spawnLevel = 0,
        _spawnInterval = 20.0 {
    _random = Random();
    _timer = Timer(_spawnInterval, repeat: true, onTick: spawnRandomEnemy);
  }

  void spawnRandomEnemy() {
    final randomNumber = _random.nextInt(EnemyType.values.length);
    final randomEnemyType = EnemyType.values[randomNumber];
    final newEnemy = Enemy(randomEnemyType, storage);
    gameRef.add(newEnemy);
  }

  void destroy() {
    _timer.stop();
    removeFromParent();
  }

  @override
  void onMount() {
    super.onMount();
    _timer.start();
  }

  @override
  void update(double dt) {
    _timer.update(dt);

    int newSpawnLevel = (log(gameRef.score + 1) / log(1.5)).toInt();

    if (_spawnLevel < newSpawnLevel) {
      _spawnLevel = newSpawnLevel;

      _spawnInterval = max(0.1, 6.0 * pow(0.8, _spawnLevel));

      _timer.stop();
      _timer = Timer(_spawnInterval, repeat: true, onTick: spawnRandomEnemy);
      _timer.start();
    }
  }

  void reset() {
    _spawnLevel = 0;
    _spawnInterval = 8.0;
    _timer.stop();
    _timer = Timer(_spawnInterval, repeat: true, onTick: spawnRandomEnemy);
    _timer.start();
  }
}
