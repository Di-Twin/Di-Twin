import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/weight_range_entity.dart';

class WeightChartWidget extends StatelessWidget {
  final Map<String, double> weightData;
  final WeightRangeEntity? targetRange;
  final String selectedPeriod;
  final bool isLoading;

  const WeightChartWidget({
    super.key,
    required this.weightData,
    this.targetRange,
    required this.selectedPeriod,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0066FF)),
      );
    }

    if (weightData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No weight data available',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your weight to see progress',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight Progress',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E2B3C),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          _formatDateForChart(value.toInt()),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 2,
                    reservedSize: 40,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        '${value.toInt()}kg',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              minX: 0,
              maxX: (_getChartData().length - 1).toDouble(),
              minY: _getMinWeight(),
              maxY: _getMaxWeight(),
              lineBarsData: [
                // Weight line
                LineChartBarData(
                  spots: _getChartData(),
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0066FF),
                      const Color(0xFF0066FF).withOpacity(0.7),
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: const Color(0xFF0066FF),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0066FF).withOpacity(0.1),
                        const Color(0xFF0066FF).withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Target range lines
                if (targetRange != null) ...[
                  // Min target line
                  LineChartBarData(
                    spots: [
                      FlSpot(0, targetRange!.min),
                      FlSpot((_getChartData().length - 1).toDouble(), targetRange!.min),
                    ],
                    isCurved: false,
                    color: Colors.red.withOpacity(0.7),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                  // Max target line
                  LineChartBarData(
                    spots: [
                      FlSpot(0, targetRange!.max),
                      FlSpot((_getChartData().length - 1).toDouble(), targetRange!.max),
                    ],
                    isCurved: false,
                    color: Colors.red.withOpacity(0.7),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                ],
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      if (barSpot.barIndex == 0) {
                        return LineTooltipItem(
                          '${barSpot.y.toStringAsFixed(1)} kg',
                          GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                      return null;
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Weight',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (targetRange != null) ...[
              const SizedBox(width: 24),
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: CustomPaint(painter: DashedLinePainter()),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Target Range',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  List<FlSpot> _getChartData() {
    if (weightData.isEmpty) return [];

    List<MapEntry<String, double>> sortedEntries = weightData.entries.toList()
      ..sort((a, b) => _parseDate(a.key).compareTo(_parseDate(b.key)));

    List<FlSpot> spots = [];
    for (int i = 0; i < sortedEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedEntries[i].value));
    }

    return spots;
  }

  DateTime _parseDate(String rawDate) {
    final parts = rawDate.split('-');
    final year = parts[0];
    final month = parts[1].padLeft(2, '0');
    final day = parts[2].padLeft(2, '0');
    return DateTime.parse('$year-$month-$day');
  }

  double _getMinWeight() {
    if (weightData.isEmpty) {
      return targetRange != null ? (targetRange!.min - 5).clamp(0, double.infinity) : 60.0;
    }

    double min = weightData.values.reduce((a, b) => a < b ? a : b);
    double targetRef = targetRange?.min ?? min;

    double referenceMin = [min, targetRef].reduce((a, b) => a < b ? a : b);
    return (referenceMin - 3).clamp(0, double.infinity);
  }

  double _getMaxWeight() {
    if (weightData.isEmpty) {
      return targetRange != null ? targetRange!.max + 2 : 100.0;
    }

    double max = weightData.values.reduce((a, b) => a > b ? a : b);
    double targetRef = targetRange?.max ?? max;

    return [max + 1, targetRef + 1.5].reduce((a, b) => a > b ? a : b);
  }

  String _formatDateForChart(int index) {
    if (weightData.isEmpty) return '';

    List<String> sortedDates = weightData.keys.toList()
      ..sort((a, b) => _parseDate(a).compareTo(_parseDate(b)));

    if (index >= sortedDates.length) return '';

    final date = _parseDate(sortedDates[index]);
    switch (selectedPeriod) {
      case 'Week':
        return DateFormat('E').format(date);
      case 'Month':
        return DateFormat('d').format(date);
      case '3 Month':
      case '6 Month':
        return DateFormat('MMM d').format(date);
      default:
        return DateFormat('d').format(date);
    }
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.7)
      ..strokeWidth = 2;

    const dashWidth = 3.0;
    const dashSpace = 2.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}