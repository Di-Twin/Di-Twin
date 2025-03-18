import 'dart:ui';
import 'package:flutter/material.dart';

// class GraphScreen extends StatelessWidget {
//   final double progressValue;

//   const GraphScreen({
//     Key? key, 
//     this.progressValue = 60,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Progress Graph'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Progress: ${progressValue.toInt()}%',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16),
//             Container(
//               height: 100,
//               width: double.infinity,
//               child: CustomPathProgressBar(
//                 percentage: progressValue,
//                 progressColor: Colors.blue,
//                 backgroundColor: Colors.black,
//                 strokeWidth: 4.0,
//               ),
//             ),
//             // Additional graph elements can be added here
//           ],
//         ),
//       ),
//     );
//   }
// }

class HeartRategraph extends StatelessWidget {
  final double percentage; // Value between 0 and 100
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  const HeartRategraph({
    super.key,
    required this.percentage,
    this.progressColor = Colors.red,
    this.backgroundColor = Colors.grey,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: PathProgressPainter(
            percentage: percentage,
            progressColor: progressColor,
            backgroundColor: backgroundColor,
            strokeWidth: strokeWidth,
          ),
        );
      },
    );
  }
}

class PathProgressPainter extends CustomPainter {
  final double percentage;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  PathProgressPainter({
    required this.percentage,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final lineHeight = size.height * 0.5;
    final smallStep = size.width / 20; // Small line size
    final mediumStep = size.width / 10; // Medium line size
    final largeStep = size.width / 5; // Large line size
    final cornerRadius = smallStep * 0.5; // Radius for the rounded corners
    
    // Create the path with rounded corners
    final path = Path();
    double x = 0;
    
    // Starting point
    path.moveTo(x, lineHeight);
    x += smallStep;
    
    // First segment: horizontal line
    path.lineTo(x, lineHeight);
    
    // First corner: rounded turn upward
    path.quadraticBezierTo(
      x + cornerRadius, lineHeight, 
      x + cornerRadius, lineHeight - cornerRadius
    );
    
    // Second segment: vertical line up
    path.lineTo(x + cornerRadius, lineHeight - mediumStep + cornerRadius);
    
    // Second corner: rounded turn to the right
    path.quadraticBezierTo(
      x + cornerRadius, lineHeight - mediumStep, 
      x + 2 * cornerRadius, lineHeight - mediumStep
    );

    x += smallStep;

    // Third segment: horizontal line to the right
    path.lineTo(x + smallStep - cornerRadius, lineHeight - mediumStep);
    
    // Third corner: rounded turn downward
    path.quadraticBezierTo(
      x + smallStep, lineHeight - mediumStep, 
      x + smallStep, lineHeight - mediumStep + cornerRadius
    );
    
    // Fourth segment: vertical line down
    path.lineTo(x + smallStep, lineHeight + largeStep - cornerRadius);
    
    // Fourth corner: rounded turn to the right
    path.quadraticBezierTo(
      x + smallStep, lineHeight + largeStep, 
      x + smallStep + cornerRadius, lineHeight + largeStep
    );
    
    x += mediumStep;
    
    // Fifth segment: horizontal line to the right
    path.lineTo(x + smallStep - cornerRadius, lineHeight + largeStep);
    
    // Fifth corner: rounded turn upward
    path.quadraticBezierTo(
      x + smallStep, lineHeight + largeStep, 
      x + smallStep, lineHeight + largeStep - cornerRadius
    );
    
    // Sixth segment: vertical line up
    path.lineTo(x + smallStep, lineHeight - largeStep + cornerRadius);
    
    // Sixth corner: rounded turn to the right
    path.quadraticBezierTo(
      x + smallStep, lineHeight - largeStep, 
      x + smallStep + cornerRadius, lineHeight - largeStep
    );
    
    x += mediumStep;
    
    // Seventh segment: horizontal line to the right
    path.lineTo(x + smallStep - cornerRadius, lineHeight - largeStep);
    
    // Seventh corner: rounded turn downward
    path.quadraticBezierTo(
      x + smallStep, lineHeight - largeStep, 
      x + smallStep, lineHeight - largeStep + cornerRadius
    );
    
    // Eighth segment: vertical line down
    path.lineTo(x + smallStep, lineHeight + largeStep - cornerRadius);
    
    // Eighth corner: rounded turn to the right
    path.quadraticBezierTo(
      x + smallStep, lineHeight + largeStep, 
      x + smallStep + cornerRadius, lineHeight + largeStep
    );
    
    x += mediumStep;
    
    // Ninth segment: horizontal line to the right
    path.lineTo(x + smallStep - cornerRadius, lineHeight + largeStep);
    
    // Ninth corner: rounded turn upward
    path.quadraticBezierTo(
      x + smallStep, lineHeight + largeStep, 
      x + smallStep, lineHeight + largeStep - cornerRadius
    );
    
    // Tenth segment: vertical line up
    path.lineTo(x + smallStep, lineHeight - mediumStep + cornerRadius);
    
    // Tenth corner: rounded turn to the right
    path.quadraticBezierTo(
      x + smallStep, lineHeight - mediumStep, 
      x + smallStep + cornerRadius, lineHeight - mediumStep
    );
    
    x += mediumStep;
    
    // Eleventh segment: horizontal line to the right
    path.lineTo(x + smallStep - cornerRadius, lineHeight - mediumStep);
    
    // Eleventh corner: rounded turn downward
    path.quadraticBezierTo(
      x + smallStep, lineHeight - mediumStep, 
      x + smallStep, lineHeight - mediumStep + cornerRadius
    );
    
    // Twelfth segment: vertical line down
    path.lineTo(x + smallStep, lineHeight - cornerRadius);
    
    // Twelfth corner: rounded turn to the right
    path.quadraticBezierTo(
      x + smallStep, lineHeight, 
      x + smallStep + cornerRadius, lineHeight
    );
    
    x += mediumStep;
    
    // Final segment: horizontal line to the end
    path.lineTo(x, lineHeight);

    // Calculate the total length of the path
    final PathMetrics pathMetrics = path.computeMetrics();
    final PathMetric pathMetric = pathMetrics.single;
    final double totalLength = pathMetric.length;

    // Calculate how much of the path should be colored with progress color
    final double progressLength = (percentage / 100) * totalLength;

    // Draw background (grey) path
    final paintBackground = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    canvas.drawPath(path, paintBackground);

    // Draw progress (red) path by extracting a portion of the path
    if (percentage > 0) {
      final progressPath = pathMetric.extractPath(0, progressLength);
      
      final paintProgress = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      
      canvas.drawPath(progressPath, paintProgress);
    }
  }

  @override
  bool shouldRepaint(PathProgressPainter oldDelegate) =>
      oldDelegate.percentage != percentage ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.strokeWidth != strokeWidth;
}