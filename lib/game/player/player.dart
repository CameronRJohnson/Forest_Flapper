import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double gravity = 800;
const double maxTiltAngle = 1.0; // Maximum angle for downward tilt (in radians)
const double minTiltAngle = 0.8; // Maximum angle for upward tilt (in radians)
const double tiltThresholdUp = -400; // Speed threshold for tilting upwards
const double tiltThresholdDown = 400; // Speed threshold for tilting downwards

class GamePlayer extends SpriteAnimationComponent with HasGameRef {
  SharedPreferences? _storage;
  late String sprite;

  GamePlayer() : super(size: Vector2.all(100)) {
    anchor = Anchor.center;
  }

  int life = 1;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    _storage = await SharedPreferences.getInstance();

    sprite = 'BirdSpriteBlue.png';

    if (_storage!.getString('player') == 'assets/images/bird-blue.gif') {
      sprite = 'BirdSpriteBlue.png';
    } else if (_storage!.getString('player') ==
        'assets/images/bird-brown.gif') {
      sprite = 'BirdSpriteBrown.png';
    } else if (_storage!.getString('player') == 'assets/images/bird-red.gif') {
      life = 2;
      sprite = 'BirdSpriteRed.png';
    }

    // Load the image
    await Flame.images.load(sprite);

    final fallSpriteSheet = SpriteSheet(
      image: Flame.images.fromCache(sprite),
      srcSize: Vector2(160, 160),
    );

    _fallAnimation = fallSpriteSheet.createAnimation(
      row: 1,
      stepTime: 0.075,
      to: 8,
    );

    animation = _fallAnimation;

    scale.x = -1;
  }

  double speedY = 0.0;
  double yMax = 0.0;
  double xMax = 0.0;
  double xMin = 0.0;
  double yMin = 0.0;
  late SpriteAnimation _fallAnimation;
  late Rect playerRect;

  void jump() {
    speedY = -size.y * 7;
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = Vector2(gameSize.y / 20, gameSize.y / 20);
    x = gameSize.x / 2;
    y = gameSize.y / 2;
    yMax = gameSize.y - size.y;
    yMin = size.y / 6;
    xMax = gameSize.x - size.x;
    xMin = size.x;
    playerRect = Rect.fromLTWH(x, y, size.x, size.y);
  }

  @override
  void update(double dt) {
    super.update(dt);
    speedY += gravity * dt;
    y += speedY * dt;

    // Adjust rotation based on speed
    if (speedY > tiltThresholdDown) {
      // Tilt downwards
      angle = maxTiltAngle;
    } else if (speedY < tiltThresholdUp) {
      // Tilt upwards
      angle = minTiltAngle;
    } else {
      // Interpolate angle based on speed
      angle = (speedY / tiltThresholdDown) * maxTiltAngle;
    }

    if (isOnGround()) {
      y = yMax;
      speedY = 0;
    } else if (isOnTop()) {
      y = yMin;
      speedY = 0;
    }

    if (xisOnGround()) {
      x = xMax;
    } else if (xisOnTop()) {
      x = xMin;
    }

    playerRect = Rect.fromLTWH(x, y, size.x, size.y);
  }

  bool isOnGround() {
    return y >= yMax;
  }

  bool isOnTop() {
    return y <= yMin;
  }

  bool xisOnGround() {
    return x >= xMax;
  }

  bool xisOnTop() {
    return x <= xMin;
  }

  void hit() {
    life -= 1;
  }
}
