import 'package:flutter/material.dart';

class TimelineIndicator extends StatelessWidget {
  final Widget? node;
  final bool isFirst;
  final bool isLast;
  final Color lineColor;
  final double lineThickness;
  final double nodeSize;
  final bool showLine;

  const TimelineIndicator({
    super.key,
    this.node,
    this.isFirst = false,
    this.isLast = false,
    this.lineColor = Colors.grey,
    this.lineThickness = 2.0,
    this.nodeSize = 24.0,
    this.showLine = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TimelinePainter(
        isFirst: isFirst,
        isLast: isLast,
        lineColor: lineColor,
        lineThickness: lineThickness,
        nodeSize: nodeSize,
        showLine: showLine,
      ),
      child: SizedBox(
        width: nodeSize,
        height: double.infinity,
        child: node != null ? Center(child: node) : null,
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final Color lineColor;
  final double lineThickness;
  final double nodeSize;
  final bool showLine;

  _TimelinePainter({
    required this.isFirst,
    required this.isLast,
    required this.lineColor,
    required this.lineThickness,
    required this.nodeSize,
    required this.showLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!showLine) return;

    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.3)
      ..strokeWidth = lineThickness
      ..strokeCap = StrokeCap.square; // Use square to avoid rounded gaps

    final centerX = size.width / 2;
    final nodeCenterY = size.height / 2;

    // Draw top half
    if (!isFirst) {
      canvas.drawLine(
        Offset(centerX, 0),
        Offset(centerX, nodeCenterY),
        paint,
      );
    }

    // Draw bottom half
    if (!isLast) {
      canvas.drawLine(
        Offset(centerX, nodeCenterY),
        Offset(centerX, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) {
    return oldDelegate.isFirst != isFirst ||
        oldDelegate.isLast != isLast ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.lineThickness != lineThickness ||
        oldDelegate.nodeSize != nodeSize ||
        oldDelegate.showLine != showLine;
  }
}
