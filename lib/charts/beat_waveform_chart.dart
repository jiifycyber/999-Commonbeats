import 'dart:math' as math;

import 'package:flutter/material.dart';

class BeatWaveformChart extends StatelessWidget {
  final bool reconstructed;
  final double progress;
  const BeatWaveformChart({
    super.key,
    this.reconstructed = false,
    this.progress = 0,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 180,
    width: double.infinity,
    child: CustomPaint(painter: _BeatPainter(reconstructed, progress)),
  );
}

class _BeatPainter extends CustomPainter {
  final bool reconstructed;
  final double progress;
  _BeatPainter(this.reconstructed, this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final color = reconstructed ? Colors.cyanAccent : Colors.deepPurpleAccent;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 120; i++) {
      final x = i * size.width / 120;
      final amplitude =
          (math.sin(i * 0.17).abs() * 0.6 + math.sin(i * 0.73).abs() * 0.4) *
          size.height *
          0.42;
      canvas.drawLine(
        Offset(x, size.height / 2 - amplitude),
        Offset(x, size.height / 2 + amplitude),
        paint,
      );
    }
    canvas.drawLine(
      Offset(size.width * progress.clamp(0.0, 1.0), 0),
      Offset(size.width * progress.clamp(0.0, 1.0), size.height),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _BeatPainter old) =>
      old.progress != progress || old.reconstructed != reconstructed;
}
