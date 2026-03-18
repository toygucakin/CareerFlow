import 'dart:math';
import 'package:flutter/material.dart';

class DeletionEffect {
  static void show(BuildContext context, Offset position) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ParticleBurst(
        position: position,
        onFinished: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _ParticleBurst extends StatefulWidget {
  final Offset position;
  final VoidCallback onFinished;

  const _ParticleBurst({
    required this.position,
    required this.onFinished,
  });

  @override
  State<_ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<_ParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Create 15-20 random particles
    for (int i = 0; i < 18; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 1.5 + _random.nextDouble() * 2.5;
      final size = 4.0 + _random.nextDouble() * 8.0;
      final color = Colors.blue.withOpacity(0.4 + _random.nextDouble() * 0.5);
      
      _particles.add(_Particle(
        angle: angle,
        speed: speed,
        size: size,
        color: color,
      ));
    }

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
          painter: _ParticlePainter(
            position: widget.position,
            particles: _particles,
            progress: _controller.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final Offset position;
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({
    required this.position,
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final distance = progress * particle.speed * 80.0;
      final x = position.dx + cos(particle.angle) * distance;
      final y = position.dy + sin(particle.angle) * distance;
      
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()..color = particle.color.withOpacity(particle.color.opacity * opacity);
      
      // Draw a "bubble" (circle)
      canvas.drawCircle(Offset(x, y), particle.size * (1.0 + progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
