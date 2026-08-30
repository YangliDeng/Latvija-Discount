import 'dart:math' as math;
import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color waveColor;

  WavePainter(this.animationValue, this.waveColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      paint,
    );

    final wavePaint = Paint()
      ..color = waveColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final path = Path();

    final baseHeight = size.height * 0.72;

    path.moveTo(0, baseHeight);

    for (double x = 0; x <= size.width; x++) {
      final y = baseHeight +
          math.sin(
            (x / size.width * 2 * math.pi * 2) +
                (animationValue * 2 * math.pi),
          ) *
              20;

      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.waveColor != waveColor;
  }
}