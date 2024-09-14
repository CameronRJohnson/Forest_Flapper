import 'package:flutter/material.dart';

class PageTransition extends PageRouteBuilder {
  final Widget page;
  final TransitionType transitionType;

  PageTransition({
    required this.page,
    this.transitionType = TransitionType.fade,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(animation, child, transitionType);
          },
        );

  static Widget _buildTransition(
      Animation<double> animation, Widget child, TransitionType type) {
    switch (type) {
      case TransitionType.fade:
        return FadeTransition(opacity: animation, child: child);
      case TransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      case TransitionType.scale:
        return ScaleTransition(scale: animation, child: child);
      default:
        return FadeTransition(opacity: animation, child: child);
    }
  }
}

enum TransitionType {
  fade,
  slide,
  scale,
}
