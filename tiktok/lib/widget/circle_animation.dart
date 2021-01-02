import "package:flutter/material.dart";

class CircleAnimation extends StatefulWidget {
  final Widget child;
  CircleAnimation(this.child);
  @override
  _CircleAnimationState createState() => _CircleAnimationState();
}

class _CircleAnimationState extends State<CircleAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5000),
    );
    _controller.forward();
    _controller.repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(_controller),
      child: widget.child,
    );
  }
}
