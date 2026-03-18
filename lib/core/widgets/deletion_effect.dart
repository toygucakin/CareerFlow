import 'package:flutter/material.dart';

class DeletionEffect {
  static void show(BuildContext context, Offset position) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _RippleEffect(
        position: position,
        onFinished: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _RippleEffect extends StatefulWidget {
  final Offset position;
  final VoidCallback onFinished;

  const _RippleEffect({
    required this.position,
    required this.onFinished,
  });

  @override
  State<_RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<_RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _radiusAnimation = Tween<double>(begin: 0.0, end: 60.0).animate(
      CurvedAnimation(parent: _controller, curve: EffectCurves.outShips),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) => widget.onFinished());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RipplePainter(
            position: widget.position,
            radius: _radiusAnimation.value,
            opacity: _opacityAnimation.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Offset position;
  final double radius;
  final double opacity;

  _RipplePainter({
    required this.position,
    required this.radius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final paint = Paint()
      ..color = Colors.blue.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, radius, paint);

    final borderPaint = Paint()
      ..color = Colors.blue.withOpacity(opacity * 1.5).withAlpha((opacity * 1.5 * 255).toInt().clamp(0, 255))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(position, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) => true;
}

// Custom curve for a slightly more "elastic" feel
class EffectCurves {
  static const Curve outShips = _OutShipsCurve();
}

class _OutShipsCurve extends Curve {
  const _OutShipsCurve();
  @override
  double transformInternal(double t) {
    return 1.0 - (1.0 - t) * (1.0 - t); // Simple quad out
  }
}
