import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:jungle_jumper/game/main_gane/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CoinType { coin }

class CoinData {
  final String imageName;
  final int textureWidth;
  final int textureHeight;
  final int nColumns;
  final int nRows;
  final bool canFly;
  final int speed;

  const CoinData({
    required this.imageName,
    required this.textureWidth,
    required this.textureHeight,
    required this.nColumns,
    required this.nRows,
    required this.canFly,
    required this.speed,
  });
}

class Coin extends SpriteAnimationComponent with HasGameRef<MainGame> {
  static const Size coinSize = Size(16, 16);

  final SharedPreferences storage;
  final CoinData _myData;
  static final Random _random = Random();

  static const Map<CoinType, CoinData> _coinDetails = {
    CoinType.coin: CoinData(
      imageName: 'Money.png',
      nColumns: 5,
      nRows: 1,
      textureHeight: 16,
      textureWidth: 16,
      canFly: true,
      speed: 150,
    ),
  };

  final double _oscillationSpeed = 2;
  final double _oscillationAmplitude = 20;
  double _initialYPosition = 0;
  double _localTimer = 0;

  Coin(CoinType coinType, this.storage)
      : _myData = _coinDetails[coinType]!,
        super(
          size: Vector2(
            coinSize.width.toDouble(),
            coinSize.height.toDouble(),
          ),
        ) {
    anchor = Anchor.center;

    Flame.images.load(_myData.imageName).then((image) {
      final spriteSheet = SpriteSheet(
        image: image,
        srcSize: Vector2(
          _myData.textureWidth.toDouble(),
          _myData.textureHeight.toDouble(),
        ),
      );

      animation = spriteSheet.createAnimation(
        row: 0,
        stepTime: 0.1,
        to: _myData.nColumns,
      );

      scale.x = -1;
    });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    double scaleFactor = (size.y / 50) / _myData.textureWidth;

    height = coinSize.height * scaleFactor;
    width = coinSize.width * scaleFactor;

    double maxHeight = size.y - 100;

    int randomNumber = _random.nextInt(maxHeight.toInt() - height.toInt());

    position = Vector2(size.x + width, randomNumber.toDouble());
    _initialYPosition = y;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _localTimer += dt;

    x -= _myData.speed * dt;

    y = _initialYPosition +
        sin(_localTimer * _oscillationSpeed) * _oscillationAmplitude;

    if (x < -width) {
      removeFromParent();
    }
  }
}
