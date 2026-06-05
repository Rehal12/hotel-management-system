import 'package:flutter/material.dart';

class FadeSlideTransition extends StatefulWidget {
  final Widget child;
  final double slideOffset;
  final Duration duration;
  final Duration delay;
  final Axis direction;

  const FadeSlideTransition({
    Key? key,
    required this.child,
    this.slideOffset = 40.0,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.direction = Axis.vertical,
  }) : super(key: key);

  @override
  State<FadeSlideTransition> createState() => _FadeSlideTransitionState();
}

class _FadeSlideTransitionState extends State<FadeSlideTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    final offsetBegin = widget.direction == Axis.vertical
        ? Offset(0.0, widget.slideOffset / 100.0)
        : Offset(widget.slideOffset / 100.0, 0.0);

    _slideAnimation = Tween<Offset>(
      begin: offsetBegin,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
