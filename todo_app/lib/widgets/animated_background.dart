import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _BackgroundPainter(
                animation: _controller,
              ),
              child: Container(),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final Animation<double> animation;

  _BackgroundPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Gradiente de fundo base
    final rect = Offset.zero & size;
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF1a1a2e),
        const Color(0xFF16213e),
        const Color(0xFF0f3460),
      ],
    ).createShader(rect);

    canvas.drawRect(rect, paint);

    // Desenhar ondas cibernéticas
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.blue.withOpacity(0.3);

    for (var i = 0; i < 5; i++) {
      final path = Path();
      final waveHeight = size.height / 8;
      final frequency = 2 * math.pi / size.width * (1 + i * 0.5);
      final phase = animation.value * 2 * math.pi + i * math.pi / 3;

      path.moveTo(0, size.height / 2);

      for (var x = 0.0; x < size.width; x += 5) {
        final y = size.height / 2 +
            math.sin(frequency * x + phase) * waveHeight * math.cos(phase);
        path.lineTo(x, y);
      }

      canvas.drawPath(path, wavePaint);
    }

    // Adicionar pontos brilhantes
    final random = math.Random(42);
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.1);

    for (var i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 1;
      
      final opacity = (math.sin(animation.value * 2 * math.pi + i) + 1) / 2;
      dotPaint.color = Colors.white.withOpacity(opacity * 0.1);
      
      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}