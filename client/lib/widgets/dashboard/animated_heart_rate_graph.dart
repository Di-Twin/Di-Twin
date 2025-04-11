import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedHeartRateGraph extends StatefulWidget {
  final Color color;
  final List<double>? initialData;
  final double height;
  final double width;

  const AnimatedHeartRateGraph({
    Key? key,
    required this.color,
    this.initialData,
    this.height = 50,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  State<AnimatedHeartRateGraph> createState() => _AnimatedHeartRateGraphState();
}

class _AnimatedHeartRateGraphState extends State<AnimatedHeartRateGraph>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<double> _dataPoints;
  Timer? _dataUpdateTimer;
  final int _maxDataPoints =
      7; // Show only 7 data points (representing 35 hours)

  @override
  void initState() {
    super.initState();

    // Initialize data points
    _dataPoints = widget.initialData ?? _generateInitialData();

    // Set up animation controller with slower animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Slower animation
    );

    // Start animation
    _animationController.repeat(reverse: false);

    // Set up timer to add new data points less frequently
    _dataUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _addNewDataPoint();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dataUpdateTimer?.cancel();
    super.dispose();
  }

  // Generate initial sparse data
  List<double> _generateInitialData() {
    final List<double> data = [];

    // Generate 7 random data points (representing 35 hours of data)
    for (int i = 0; i < 7; i++) {
      // Generate random heart rate values between 60-100
      data.add(0.2 + math.Random().nextDouble() * 0.6);
    }

    return data;
  }

  // Add a new data point and remove oldest if needed
  void _addNewDataPoint() {
    if (!mounted) return;

    setState(() {
      // Add a new random data point
      _dataPoints.add(0.2 + math.Random().nextDouble() * 0.6);

      // Remove oldest data point if we exceed the maximum
      if (_dataPoints.length > _maxDataPoints) {
        _dataPoints.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            painter: AnimatedHeartRateGraphPainter(
              color: widget.color,
              dataPoints: _dataPoints,
              animationValue: _animationController.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class AnimatedHeartRateGraphPainter extends CustomPainter {
  final Color color;
  final List<double> dataPoints;
  final double animationValue;

  AnimatedHeartRateGraphPainter({
    required this.color,
    required this.dataPoints,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final linePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

    final dotPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final path = Path();

    // Calculate the offset for animation (moving from right to left)
    final pointSpacing = size.width / (dataPoints.length - 1);
    final animationOffset = animationValue * pointSpacing;

    // Draw the line connecting the data points
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i * pointSpacing) - animationOffset;
      final y = size.height - (dataPoints[i] * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw dots at each data point
      canvas.drawCircle(Offset(x, y), 3.0, dotPaint);
    }

    canvas.drawPath(path, linePaint);

    // Draw time labels (optional)
    final textStyle = TextStyle(color: color.withOpacity(0.7), fontSize: 8);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw "5h" labels under each point
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i * pointSpacing) - animationOffset;
      if (x >= 0 && x <= size.width) {
        textPainter.text = TextSpan(
          text: '${(dataPoints.length - i) * 5}h',
          style: textStyle,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height - 10),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedHeartRateGraphPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.dataPoints != dataPoints;
  }
}
