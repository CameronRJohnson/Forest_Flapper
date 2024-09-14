import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:jungle_jumper/game/main_gane/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EnemyType { birdo, birdSlow, birdMow, zigzag, oscillate }

class EnemyData {
  final String imageName;
  final int textureWidth;
  final int textureHeight;
  final int nColumns;
  final int nRows;
  final bool canFly;
  final int speed;
  final bool hasSpecialMovement;

  const EnemyData({
    required this.imageName,
    required this.textureWidth,
    required this.textureHeight,
    required this.nColumns,
    required this.nRows,
    required this.canFly,
    required this.speed,
    this.hasSpecialMovement = false,
  });
}

class Enemy extends SpriteAnimationComponent with HasGameRef<MainGame> {
  final SharedPreferences storage;
  final EnemyData _enemyData;
  static final Random _random = Random();

  double _timer = 0;
  double _initialY = 0;
  static const double _oscillationAmplitude = 30;
  bool _isMovingDown = true;

  static const Map<EnemyType, EnemyData> _enemyDetails = {
    EnemyType.birdo: EnemyData(
      imageName: 'Enemy_Sprite.png',
      nColumns: 8,
      nRows: 1,
      textureHeight: 150,
      textureWidth: 150,
      canFly: true,
      speed: 300,
    ),
    EnemyType.birdSlow: EnemyData(
      imageName: 'Enemy_Sprite.png',
      nColumns: 8,
      nRows: 1,
      textureHeight: 150,
      textureWidth: 150,
      canFly: true,
      speed: 75,
    ),
    EnemyType.birdMow: EnemyData(
      imageName: 'Enemy_Sprite.png',
      nColumns: 8,
      nRows: 1,
      textureHeight: 150,
      textureWidth: 150,
      canFly: true,
      speed: 150,
    ),
    EnemyType.zigzag: EnemyData(
      imageName: 'Enemy_Sprite.png',
      nColumns: 8,
      nRows: 1,
      textureHeight: 150,
      textureWidth: 150,
      canFly: true,
      speed: 200,
      hasSpecialMovement: true,
    ),
    EnemyType.oscillate: EnemyData(
      imageName: 'Enemy_Sprite.png',
      nColumns: 8,
      nRows: 1,
      textureHeight: 150,
      textureWidth: 150,
      canFly: true,
      speed: 250,
      hasSpecialMovement: true,
    ),
  };

  Enemy(EnemyType type, this.storage)
      : _enemyData = _enemyDetails[type]!,
        super(size: Vector2.all(100)) {
    anchor = Anchor.center;

    Flame.images.load(_enemyData.imageName).then((image) {
      final spriteSheet = SpriteSheet(
        image: image,
        srcSize: Vector2(
          _enemyData.textureWidth.toDouble(),
          _enemyData.textureHeight.toDouble(),
        ),
      );
      animation = spriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        to: _enemyData.nColumns,
      );
      scale.x = -1;
    });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    int randomYPosition = _random.nextInt(size.y.toInt() - 100) + 10;

    double scaleFactor = (size.y / 4) / _enemyData.textureWidth;
    height = _enemyData.textureHeight * scaleFactor;
    width = _enemyData.textureWidth * scaleFactor;

    position = Vector2(size.x + width, randomYPosition.toDouble());
    _initialY = y;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;

    x -= _enemyData.speed * dt;

    if (_enemyData.hasSpecialMovement) {
      _applySpecialMovement(dt);
    }

    if (x < -width) {
      removeFromParent();
    }
  }

  void _applySpecialMovement(double dt) {
    if (_enemyData == _enemyDetails[EnemyType.oscillate]) {
      // Oscillate up and down in a sine wave pattern
      y = _initialY + sin(_timer * 2) * _oscillationAmplitude;
    } else if (_enemyData == _enemyDetails[EnemyType.zigzag]) {
      // Zigzag movement
      if (_isMovingDown) {
        y += 100 * dt;
        if (y > _initialY + 50) _isMovingDown = false;
      } else {
        y -= 100 * dt;
        if (y < _initialY - 50) _isMovingDown = true;
      }
    }
  }
}
